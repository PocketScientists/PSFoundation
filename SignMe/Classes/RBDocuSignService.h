//
//  RBDocuSignService.h
//  SignMe
//
//  Created by Tretter Matthias on 04.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBDocument.h"

@interface RBDocuSignService : NSObject

+ (void)previewDocument:(RBDocument *)document;
+ (void)sendDocument:(RBDocument *)document;
+ (void)cancelDocument:(RBDocument *)document;
+ (void)signDocument:(RBDocument *)document recipient:(NSDictionary *)recipient;
+ (void)updateStatusOfDocuments;

@end
