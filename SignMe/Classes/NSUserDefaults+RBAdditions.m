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

+ (void)initialize {
    if (self == [NSUserDefaults class]) {
        // Setting Defaults for Settings
        NSDictionary *appDefaults = XDICT($B(NO), kRBSettingsBoxLogoutKey, $I(77561782), kRBSettingsBoxFolderIDKey);
        [[self standardUserDefaults] registerDefaults:appDefaults];
        [[self standardUserDefaults] synchronize];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General UserDefaults
////////////////////////////////////////////////////////////////////////

- (void)setFolderID:(NSInteger)folderID {
    [self setInteger:folderID forKey:kRBSettingsBoxFolderIDKey];
    [self synchronize];
}

- (NSInteger)folderID {
    return [self integerForKey:kRBSettingsBoxFolderIDKey];
}

- (void)setShouldLogOutOfBox:(BOOL)shouldLogOutOfBox {
    [self setBool:shouldLogOutOfBox forKey:kRBSettingsBoxLogoutKey];
    [self synchronize];
}

- (BOOL)shouldLogOutOfBox {
    return [self boolForKey:kRBSettingsBoxLogoutKey];
}

- (void)setFormsUpdateDate:(NSDate *)formsUpdateDate {
    [self setObject:formsUpdateDate forKey:kRBSettingsFormsUpdateDateKey];
    [self synchronize];
}

- (NSDate *)formsUpdateDate {
    return [self objectForKey:kRBSettingsFormsUpdateDateKey];
}

- (void)setDocuSignUserName:(NSString *)docuSignUserName {
    [self setObject:docuSignUserName forKey:kRBSettingsDocuSignUserNameKey];
    [self synchronize];
}

- (NSString *)docuSignUserName {
    return [self stringForKey:kRBSettingsDocuSignUserNameKey];
}

- (void)setDocuSignPassword:(NSString *)docuSignPassword {
    [self setObject:docuSignPassword forKey:kRBSettingsDocuSignPasswordKey];
    [self synchronize];
}

- (NSString *)docuSignPassword {
    return [self stringForKey:kRBSettingsDocuSignPasswordKey];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Box.net objects
////////////////////////////////////////////////////////////////////////

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

- (void)deleteStoredObjectNames {
    NSArray *keys = [[[self dictionaryRepresentation] allKeys] pathsMatchingExtensions:XARRAY(kRBFormDataType)];
    
    for (NSString *key in keys) {
        [self removeObjectForKey:key];
    }
}

- (void)setObjectID:(NSNumber *)objectID forObjectWithNameIncludingExtension:(NSString *)name {
    [self setObject:objectID forKey:name];
    [self synchronize];
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
