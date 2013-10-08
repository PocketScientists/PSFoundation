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
        NSUserDefaults *standardUserDefaults = [self standardUserDefaults];
        NSString *val = nil;
        
        if (standardUserDefaults) 
            val = [standardUserDefaults objectForKey:@"kRBMailConfigFromEmail"];
        
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
                NSLog(@"key: %@ %@",keyValue,defaultValue);
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

-(void)setLoggedInOnce:(BOOL)loggedInOnce{
    [self setBool:loggedInOnce forKey:@"kLoggedInOnceKey"];
    [self synchronize];
}

-(BOOL)loggedInOnce{
    return [self boolForKey:@"kLoggedInOnceKey"];
}

-(void)setOfflineMode:(BOOL)offlineMode{
    [self setBool:offlineMode forKey:@"kOfflineModeKey"];
    [self synchronize];
}

-(BOOL)offlineMode{
    return [self boolForKey:@"kOfflineModeKey"];
}

-(void)setAddressBookAccess:(BOOL)granted{
    [self setBool:granted forKey:kRBSettingsAddressBookAccess];
    [self synchronize];
}

-(BOOL)addressBookAccess{
    return [self boolForKey:kRBSettingsAddressBookAccess];
}

- (void)setWebserviceUpdateDate:(NSDate *)webserviceUpdateDate {
    [self setObject:webserviceUpdateDate forKey:kRBSettingsWebserviceUpdateDateKey];
    [self synchronize];
}

- (NSDate *)webserviceUpdateDate {
    return [self objectForKey:kRBSettingsWebserviceUpdateDateKey];
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

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Objects
////////////////////////////////////////////////////////////////////////

- (NSArray *)allStoredObjectNames {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[[dictionary allKeys] pathsMatchingExtensions:XARRAY(kRBFormDataType)]];    
    
    for (NSUInteger i=0;i < keys.count;i++) {
        NSString *key = [keys objectAtIndex:i];
        
        key = [key substringToIndex:[key rangeOfString:kRBFormExtension].location];
        [keys replaceObjectAtIndex:i withObject:key];
    }
    
    return [keys copy];
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

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Additional Form objects for loading via Webservice
////////////////////////////////////////////////////////////////////////
-(void)setFormName:(NSString *)formname forObjectWithNameIncludingExtension:(NSString *)name {
    [self setObject:formname forKey:name];
    [self synchronize];
}


@end
