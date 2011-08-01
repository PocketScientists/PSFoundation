//
//  RBClient+RBProperties.h
//  SignMe
//
//  Created by Tretter Matthias on 29.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBClient.h"

@interface RBClient (RBClient_RBProperties)

+ (NSArray *)propertyNamesForMapping;

- (void)setStringValue:(NSString *)stringValue forKey:(NSString *)key;

@end
