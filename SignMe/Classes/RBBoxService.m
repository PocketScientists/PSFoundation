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
#import "RBDocument+RBForm.h"


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

+ (void)uploadDocument:(RBDocument *)document toFolder:(BoxFolder *)folder {
    if (folder && [folder isKindOfClass:[BoxFolder class]]) {
        NSData *savedPDFData = document.filledPDFData;
        NSData *savedPlistData = document.filledPlistData;
        
        // upload pdf
        if (savedPDFData != nil) {
            [[RBBoxService box] uploadFile:[document.fileURL stringByAppendingString:kRBPDFExtension]
                                      data:savedPDFData
                               contentType:@"application/pdf" 
                                  inFolder:folder
                           completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
                               if (resultType == BoxResponseSuccess) {
                                   document.uploadedToBox = $B(YES);
                               } else {
                                   DDLogError(@"Error uploading PDF %@: %d", document.fileURL, resultType);
                               }
                           }];
        }
        
        // upload
        if (savedPlistData != nil) {
            [[RBBoxService box] uploadFile:[document.fileURL stringByAppendingString:kRBFormExtension]
                                      data:savedPlistData
                               contentType:@"application/plist" 
                                  inFolder:folder
                           completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
                               if (resultType != BoxResponseSuccess) {
                                   DDLogError(@"Error uploading Plist %@: %d", document.fileURL, resultType);
                               }
                           }];
        }
    }
}

+ (void)uploadDocument:(RBDocument *)document toFolderAtPath:(NSString *)path {
    BoxFolder *folder = (BoxFolder *)[box.rootFolder objectAtFilePath:path];
    
    // folder doesn't exist yet, create it
    if (folder == nil) {
        [[RBBoxService box] createFolder:path
                                inFolder:box.rootFolder
                         completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
                             if (resultType == BoxResponseSuccess) {
                                 [RBBoxService uploadDocument:document toFolder:(BoxFolder *)boxObject];
                             } else {
                                 DDLogError(@"Error creating folder at path: %@, %d", path, resultType);
                             }
                         }];
    } 
    
    // folder exists, upload files directly
    else {
        [RBBoxService uploadDocument:document toFolder:folder];
    }
}


@end
