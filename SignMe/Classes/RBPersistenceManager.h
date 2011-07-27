//
//  RBPersistenceManager.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBForm.h"
#import "RBClient.h"

@interface RBPersistenceManager : NSObject

- (void)persistDocumentUsingForm:(RBForm *)form client:(RBClient *)client;

@end
