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

+ (void)sendDocument:(RBDocument *)document;

@end
