//
//  NSUserDefaults+RBAdditions.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NSUserDefaults+RBAdditions.h"
#import "PSIncludes.h"

@implementation NSUserDefaults (NSUserDefaults_RBAdditions)

- (void)setFolderID:(NSInteger)folderID {
    [self setInteger:folderID forKey:kRBSettingsFolderIDKey];
}

- (NSInteger)folderID {
    return [self integerForKey:kRBSettingsFolderIDKey];
}

- (NSArray *)allStoredObjectNames {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[[dictionary allKeys] pathsMatchingExtensions:XARRAY(kRBFormDataType)]];    
    
    for (NSUInteger i=0;i < keys.count;i++) {
        NSString *key = [keys objectAtIndex:i];
        
        key = [key substringToIndex:[key rangeOfString:kRBFormExtension].location];
        [keys replaceObjectAtIndex:i withObject:key];
    }
    
    return [[keys copy] autorelease];
}

- (void)setObjectID:(NSNumber *)objectID forObjectWithNameIncludingExtension:(NSString *)name {
    [self setObject:objectID forKey:name];
}
- (NSNumber *)objectIDForObjectWithNameIncludingExtension:(NSString *)name {
    return [self objectForKey:name];
}

- (void)setObjectID:(NSNumber *)objectID forPlistWithName:(NSString *)name {
    [self setObjectID:objectID forObjectWithNameIncludingExtension:[name stringByAppendingString:kRBFormExtension]];
}

- (NSNumber *)objectIDForPlistWithName:(NSString *)name {
    return [self objectIDForObjectWithNameIncludingExtension:[name stringByAppendingString:kRBFormExtension]];
}

- (void)setObjectID:(NSNumber *)objectID forPDFWithName:(NSString *)name {
    [self setObjectID:objectID forObjectWithNameIncludingExtension:[name stringByAppendingString:kRBPDFExtension]];
}

- (NSNumber *)objectIDForPDFWithName:(NSString *)name {
    return [self objectIDForObjectWithNameIncludingExtension:[name stringByAppendingString:kRBPDFExtension]];
}

@end
