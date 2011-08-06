//
//  RBBoxService.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSBaseViewController.h"
#import "Box.h"
#import "RBDocument.h"

@interface RBBoxService : NSObject

+ (Box *)box;

+ (BOOL)shouldSyncFolder;

+ (void)syncFolderWithID:(NSInteger)folderID 
             startedFrom:(PSBaseViewController *)viewController
            successBlock:(void (^)(id boxObject))successBlock
            failureBlock:(void (^)(BoxResponseType response))failureBlock;


+ (void)uploadDocument:(RBDocument *)document toFolder:(BoxFolder *)folder;
+ (void)uploadDocument:(RBDocument *)document toFolderAtPath:(NSString *)path;

+ (void)deleteDocument:(RBDocument *)document fromFolderAtPath:(NSString *)path;

@end
