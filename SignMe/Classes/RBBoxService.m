//
//  RBBoxService.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBBoxService.h"
#import "Box.h"
#import "RBBoxLoginViewController.h"
#import "PSIncludes.h"

static Box *box = nil;

@implementation RBBoxService

+ (void)initialize {
    if (self == [RBBoxService class]) {
        box = [[Box alloc] init];
    }
}

+ (void)syncFolderWithID:(NSInteger)folderID 
             startedFrom:(PSBaseViewController *)viewController
            successBlock:(void (^)(void))successBlock
            failureBlock:(void (^)(BoxResponseType response))failureBlock {
    __block RBBoxLoginViewController *loginViewController = [[RBBoxLoginViewController alloc] initWithNibName:nil bundle:nil];
    
    loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    NSLog(@"Just to make sure view is loaded: %@", loginViewController.view);
    
    // start indicating loading
    [viewController beginLoadingShowingProgress:NO];
    
    [box syncFolderWithId:[NSUserDefaults standardUserDefaults].folderID
                    loginBlock:^UIWebView *(void) {
                        [viewController presentModalViewController:loginViewController animated:YES];
                        
                        return loginViewController.webView;
                    } 
                 progressBlock:^(BoxResponseType response, NSObject *boxObject) {
                     if (loginViewController != nil) {
                         [viewController dismissModalViewControllerAnimated:YES];
                         MCReleaseNil(loginViewController);
                     }
                     
                     NSLog(@"progress box object: %@", [(BoxObject *)boxObject objectToString]);
                 } 
               completionBlock:^(BoxResponseType response, NSObject *boxObject) {
                   if (loginViewController != nil) {
                       [viewController dismissModalViewControllerAnimated:YES];
                       MCReleaseNil(loginViewController);
                   }
                   
                   [viewController finishLoading];
                   
                   if (response == BoxResponseSuccess) {
                       successBlock();
                   } else if (failureBlock != nil) {
                       failureBlock(response);
                   }
               }];
}


@end
