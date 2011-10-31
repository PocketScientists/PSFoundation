//
//  RBMusketeer+RBProperties.h
//  SignMe
//
//  Created by Tretter Matthias on 29.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBMusketeer.h"

@interface RBMusketeer (RBMusketeer_RBProperties)

// states whether a musketeer was just created for editing (it then gets removed if you press abort)
- (BOOL)musketeerCreatedForEditing;
- (void)setMusketeerCreatedForEditing:(BOOL)musketeerCreatedForEditing;

+ (NSArray *)propertyNamesForMapping;

- (void)setStringValue:(NSString *)stringValue forKey:(NSString *)key;

@end
