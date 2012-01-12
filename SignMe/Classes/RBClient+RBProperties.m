//
//  RBClient+RBProperties.m
//  SignMe
//
//  Created by Tretter Matthias on 29.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBClient+RBProperties.h"
#import <objc/runtime.h>
#import "PSIncludes.h"

static char clientCreatedKey;

@implementation RBClient (RBClient_RBProperties)

- (void)setClientCreatedForEditing:(BOOL)clientCreatedForEditing {
    [self associateValue:[NSNumber numberWithBool:clientCreatedForEditing] withKey:&clientCreatedKey];
}

- (BOOL)clientCreatedForEditing {
    return [[self associatedValueForKey:&clientCreatedKey] boolValue];
}

+ (NSArray *)propertyNamesForMapping {
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:propertyCount];
    
    for (int i=0;i<propertyCount;i++) {
        const char *propertyName = property_getName(propertyList[i]);
        const char *propertyAttributes = property_getAttributes(propertyList[i]);
        
        // do not return relationship-properties
        if (strstr(propertyAttributes, "NSSet") == NULL && strcmp(propertyName, "visible") != 0 && strcmp(propertyName, "company") != 0) {
            [properties addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        }
    }
    
    return [[properties copy] autorelease];
}

- (void)setStringValue:(NSString *)stringValue forKey:(NSString *)key {
    objc_property_t property = class_getProperty([self class], [key cStringUsingEncoding:NSUTF8StringEncoding]);
    const char* propertyAttributes = property_getAttributes(property);
    
    if (strstr(propertyAttributes, "NSString") != NULL) {
        [self setValue:stringValue forKey:key];
    } else if (strstr(propertyAttributes, "NSNumber") != NULL) {
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        [self setValue:[f numberFromString:stringValue] forKey:key];
    } else {
        DDLogWarn(@"No method specified for key '%@' with attributes '%s'", key, propertyAttributes);
    }
}

@end
