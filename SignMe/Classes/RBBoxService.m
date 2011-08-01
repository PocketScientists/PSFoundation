//
//  RBBoxService.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBBoxService.h"
#import "RBBoxLoginViewController.h"
#import "PSIncludes.h"

static Box *box = nil;

@implementation RBBoxService

+ (void)initialize {
    if (self == [RBBoxService class]) {
        box = [[Box alloc] init];
    }
}

+ (Box *)box {
    return box;
}

+ (void)syncFolderWithID:(NSInteger)folderID 
             startedFrom:(PSBaseViewController *)viewController
            successBlock:(void (^)(id boxObject))successBlock
            failureBlock:(void (^)(BoxResponseType response))failureBlock {
    
    __block RBBoxLoginViewController *loginViewController = nil;
    
    // start indicating loading
    [viewController beginLoadingShowingProgress:NO];
    
    [box syncFolderWithId:[NSUserDefaults standardUserDefaults].folderID
                    loginBlock:^UIWebView *(void) {
                        loginViewController = [[RBBoxLoginViewController alloc] initWithNibName:nil bundle:nil];
                        
                        NSLog(@"Just to make sure view is loaded: %@", loginViewController.view);
                        
                        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:loginViewController] autorelease];
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                        navigationController.navigationBar.barStyle = UIBarStyleBlack;
                        
                        [viewController presentModalViewController:navigationController animated:YES];
                        
                        return loginViewController.webView;
                    } 
                 progressBlock:^(BoxResponseType response, NSObject *boxObject) {
                     if (loginViewController != nil && response != BoxResponseLoginError) {
                         [viewController dismissModalViewControllerAnimated:YES];
                         MCReleaseNil(loginViewController);
                     }
                     
                     NSLog(@"progress box object: %@", [(BoxObject *)boxObject objectToString]);
                 } 
               completionBlock:^(BoxResponseType response, NSObject *boxObject) {
                   if (loginViewController != nil  && response != BoxResponseLoginError) {
                       [viewController dismissModalViewControllerAnimated:YES];
                       MCReleaseNil(loginViewController);
                   }
                   
                   [viewController finishLoading];
                   
                   if (response == BoxResponseSuccess) {
                       successBlock(boxObject);
                   } else {
                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                       if (failureBlock != nil) {
                           failureBlock(response);
                       }
                       
                       DDLogError(@"Error syncing box.net folder: %d, %@", response, boxObject);
                   }
               }];
}


@end
