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
#import "AppDelegate.h"
#import "BoxFolderXMLBuilder.h"


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

+ (BOOL)shouldSyncFolder {
    // TODO:
    // somehow my intention didn't work, so as a quick-fix box.net gets synced everythime
    return YES;
  
    /*
    // download once per day
    if (![[NSUserDefaults standardUserDefaults].formsUpdateDate isToday]) {
        return YES;
    }
    
    // download if not logged in -> to get login-view
    if (![[BoxUser savedUser] loggedIn]) {
        return YES;
    }
    
    // check if download works (by getting root-folder), if not download to get login-view
    BoxFolderDownloadResponseType responseType = 0;
    [BoxFolderXMLBuilder folderForId:[NSNumber numberWithInt:0]
                               token:[BoxUser savedUser].authToken 
                     responsePointer:&responseType basePathOrNil:nil];
    
    if (responseType != boxFolderDownloadResponseTypeFolderSuccessfullyRetrieved) {
        return YES;
    }
    
    
    return NO; */
}

+ (void)syncFolderWithID:(NSInteger)folderID 
             startedFrom:(PSBaseViewController *)viewController
            successBlock:(void (^)(id boxObject))successBlock
            failureBlock:(void (^)(BoxResponseType response))failureBlock {
    
    __block RBBoxLoginViewController *loginViewController = nil;
    
    // start indicating loading
    [viewController showLoadingMessage:@"Updating box.net"];
    
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
              
              [viewController hideMessage];
              
              if (response == BoxResponseSuccess) {
                  successBlock(boxObject);
                  [viewController showSuccessMessage:@"Update successful"];
              } else {
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  if (failureBlock != nil) {
                      failureBlock(response);
                  }
                  
                  [viewController showErrorMessage:@"Error updating box.net"];
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
            [box uploadFile:[document.fileURL stringByAppendingString:kRBPDFExtension]
                       data:savedPDFData
                contentType:@"application/pdf" 
                   inFolder:folder
            completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
                if (resultType == BoxResponseSuccess) {
                    document.uploadedToBox = $B(YES);
                } else {
                    DDLogError(@"Error uploading PDF %@: %d", document.fileURL, resultType);
                    [MTApplicationDelegate showErrorMessage:@"Error uploading PDF to box.net"];
                }
            }];
        }
        
        // upload
        if (savedPlistData != nil) {
            [box uploadFile:[document.fileURL stringByAppendingString:kRBFormExtension]
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
        [box createFolder:path
                 inFolder:box.rootFolder
          completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
              if (resultType == BoxResponseSuccess) {
                  [RBBoxService uploadDocument:document toFolder:(BoxFolder *)boxObject];
              } else {
                  DDLogError(@"Error creating folder at path: %@, %d", path, resultType);
                  [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Error creating folder %@ on box.net", folder.objectName]];
              }
          }];
    } 
    
    // folder exists, upload files directly
    else {
        [RBBoxService uploadDocument:document toFolder:folder];
    }
}

+ (void)deleteDocument:(RBDocument *)document fromFolderAtPath:(NSString *)path {
    NSString *pdfPath = [path stringByAppendingPathComponent:[document.fileURL stringByAppendingString:kRBPDFExtension]];
    NSString *plistPath = [path stringByAppendingPathComponent:[document.fileURL stringByAppendingString:kRBFormExtension]];
    BoxObject *pdfObject = [box.rootFolder objectAtFilePath:pdfPath];
    BoxObject *plistObject = [box.rootFolder objectAtFilePath:plistPath];
    
    if (pdfObject != nil) {
        [box deleteObject:pdfObject completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
            if (resultType != BoxResponseSuccess) {
                DDLogError(@"Error deleting object at path: %@", pdfPath);
            }
        }];
    } else {
        DDLogError(@"PDF file at path %@ is nil, can't delete document %@", pdfPath, document.fileURL);
    }
    
    if (plistObject != nil) {
        [box deleteObject:plistObject completionBlock:^(BoxResponseType resultType, NSObject *boxObject) {
            if (resultType != BoxResponseSuccess) {
                DDLogError(@"Error deleting object at path: %@", plistPath);
            }
        }];
    } else {
        DDLogError(@"Plist file at path %@ is nil, can't delete document %@", plistPath, document.fileURL);
    }
}

@end
