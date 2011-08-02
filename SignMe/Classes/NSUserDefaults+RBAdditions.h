//
//  NSUserDefaults+RBAdditions.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (NSUserDefaults_RBAdditions)

@property (nonatomic, assign) NSInteger folderID;

- (NSArray *)allStoredObjectNames;

- (void)setObjectID:(NSNumber *)objectID forObjectWithNameIncludingExtension:(NSString *)name;
- (NSNumber *)objectIDForObjectWithNameIncludingExtension:(NSString *)name;

- (void)setObjectID:(NSNumber *)objectID forPlistWithName:(NSString *)name;
- (NSNumber *)objectIDForPlistWithName:(NSString *)name;

- (void)setObjectID:(NSNumber *)objectID forPDFWithName:(NSString *)name;
- (NSNumber *)objectIDForPDFWithName:(NSString *)name;

@end
