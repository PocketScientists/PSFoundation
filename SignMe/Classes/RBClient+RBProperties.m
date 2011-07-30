//
//  RBClient+RBProperties.m
//  SignMe
//
//  Created by Tretter Matthias on 29.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBClient+RBProperties.h"
#import <objc/runtime.h>

@implementation RBClient (RBClient_RBProperties)

+ (NSArray *)propertyNamesForMapping {
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:propertyCount];
    
    for (int i=0;i<propertyCount;i++) {
        const char *propertyName = property_getName(propertyList[i]);
        
        [properties addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    
    return [[properties copy] autorelease];
}

@end
