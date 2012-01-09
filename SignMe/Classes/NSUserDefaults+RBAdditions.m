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
//        // Setting Defaults for Settings
//        NSDictionary *appDefaults = XDICT($B(NO), kRBSettingsBoxLogoutKey, $I(162865479), kRBSettingsBoxFolderIDKey, [NSDate date], kRBSettingsDocuSignUpdateDateKey);
//        [[self standardUserDefaults] registerDefaults:appDefaults];
//        [[self standardUserDefaults] synchronize];

        NSUserDefaults *standardUserDefaults = [self standardUserDefaults];
        NSString *val = nil;
        
        if (standardUserDefaults) 
            val = [standardUserDefaults objectForKey:kRBSettingsBoxFolderIDKey];
        
        // TODO: / apparent Apple bug: if user hasn't opened Settings for this app yet (as if?!), then
        // the defaults haven't been copied in yet.  So do so here.  Adds another null check
        // for every retrieve, but should only trip the first time
        if (val == nil) { 
            NSLog(@"user defaults may not have been loaded from Settings.bundle ... doing that now ...");
            //Get the bundle path
            NSString *bPath = [[NSBundle mainBundle] bundlePath];
            NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
            NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
            
            //Get the Preferences Array from the dictionary
            NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
            NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
            
            //Loop through the array
            NSDictionary *item;
            for(item in preferencesArray) {
                //Get the key of the item.
                NSString *keyValue = [item objectForKey:@"Key"];
                
                //Get the default value specified in the plist file.
                id defaultValue = [item objectForKey:@"DefaultValue"];
                
                if (keyValue && defaultValue) {				
                    [standardUserDefaults setObject:defaultValue forKey:keyValue];
                }
            }
            [standardUserDefaults synchronize];
        }
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

- (void)setDocuSignUpdateDate:(NSDate *)docuSignUpdateDate {
    [self setObject:docuSignUpdateDate forKey:kRBSettingsDocuSignUpdateDateKey];
    [self synchronize];
}

- (NSDate *)docuSignUpdateDate {
    NSDate *updateDate = [self objectForKey:kRBSettingsDocuSignUpdateDateKey];
    if (updateDate == nil) {
        updateDate = [NSDate dateWithDaysBeforeNow:7];
    }
    return updateDate;
}

- (void)setBoxUserName:(NSString *)boxUserName {
    [self setObject:boxUserName forKey:kRBSettingsBoxUsernameKey];
    [self synchronize];
}

- (NSString *)boxUserName {
    return [self stringForKey:kRBSettingsBoxUsernameKey];
}

- (void)setBoxPassword:(NSString *)boxPassword {
    [self setObject:boxPassword forKey:kRBSettingsBoxPasswordKey];
    [self synchronize];
}

- (NSString *)boxPassword {
    return [self stringForKey:kRBSettingsBoxPasswordKey];
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
    NSArray *keys = [[[self dictionaryRepresentation] allKeys] pathsMatchingExtensions:XARRAY(kRBFormDataType, kRBPDFDataType)];
    
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
