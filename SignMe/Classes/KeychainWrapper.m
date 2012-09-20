//
//  KeychainWrapper.m
//  SignMe
//
//  Created by Michael Schwarz on 20.08.12.
//

#import "KeychainWrapper.h"

//Keychain values
/*
 kSecAttrAccessGroup = 5HPAW9M6JM.com.us.redbull.MIB2012PreStage || 5HPAW9M6JM.com.us.redbull.MIB2012Stage || 5HPAW9M6JM.com.us.redbull.MIB2012 ++
 kSecClass = kSecClassGenericPassword ++
 kSecAttrGeneric = "Authentication" ++
 kSecValueData = ''token'' 
 kSecAttrAccount = ''username''
 kSecAttrDescribtion = last_auth_date
 */



@interface KeychainWrapper ()
+ (NSDate *)dateFromTimeStamp:(NSString *)timestamp;
//Creates the DateFormatter for the timestamp
+(NSDateFormatter *)getNSDateFormatterForTimestamp;
//Creates a timestamp String
+ (NSString *)createTimeStamp;
//Sets up a dictionary with the default search values
+ (NSMutableDictionary *)setupSearchDirectory;
@end



@implementation KeychainWrapper

//Sets the default search values in the dictionary
+ (NSMutableDictionary *)setupSearchDirectory{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [searchDictionary setObject:[@"Authentication" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric];
    
#if TARGET_IPHONE_SIMULATOR
    // Ignore the access group if running on the iPhone simulator.
    //
    // Apps that are built for the simulator aren't signed, so there's no keychain access group
    // for the simulator to check. This means that all apps can see all keychain items when run
    // on the simulator.
    //
    // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
    // simulator will return -25243 (errSecNoAccessForItem).
#else
  //  [searchDictionary setObject:[@"5HPAW9M6JM.com.us.redbull.MIB2012PreStage || 5HPAW9M6JM.com.us.redbull.MIB2012Stage || 5HPAW9M6JM.com.us.redbull.MIB2012"
    //                             dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccessGroup];
#endif
    
    return searchDictionary;
}
 
+ (NSDictionary *)getKeychainDictionaryForUser:(NSString *) user
{
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *searchDictionary = [self setupSearchDirectory];
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [searchDictionary setObject:[user dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
    
    //Search
    NSDictionary *result = nil;
    NSData *resdata;
    CFTypeRef foundDict=NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    if(status == noErr){
        result = (__bridge_transfer NSDictionary *)foundDict;
        
        resdata = [result valueForKey:(__bridge id)kSecValueData];
        NSString *ergstr =[[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding];
        if(ergstr){
            [returnDictionary setObject:ergstr forKey:@"Token"];}
        
        resdata = [result valueForKey:(__bridge id)kSecAttrAccount];
        ergstr =[[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding];
        if(ergstr){
            [returnDictionary setObject:ergstr forKey:@"Username"];}
        
        /*resdata = [result valueForKey:(__bridge id)kSecAttrComment];
        ergstr =[[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding];
        if(ergstr){
            [returnDictionary setObject:[[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding] forKey:@"UserXML"];}*/
        
        resdata = [result valueForKey:(__bridge id)kSecAttrDescription];
        NSString *auth_date = [[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding];
        NSDate *date = [self dateFromTimeStamp:auth_date];
        if(date)
        { [returnDictionary setObject:date forKey:@"last_auth_date"]; }
        
        //If all entries are in the dictionary
        if(returnDictionary.count >= 4){
            return returnDictionary;    }
        else{
                return nil;
            }
    }else{
        return nil;}
}


+ (BOOL)createKeychainValueWithUser:(NSString *)username Token:(NSString *)tokenID
{
    NSMutableDictionary *dictionary = [self setupSearchDirectory];
    
    [dictionary setObject:[username dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
    [dictionary setObject:[tokenID dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
   // [dictionary setObject:[xmlStr dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrComment];
    
    //Create Timestamp
    NSString * time_stamp = [self createTimeStamp];
    [dictionary setObject:[time_stamp dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrDescription];
    
    //Add
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if(status == errSecSuccess){
        return YES;
    }else if (status == errSecDuplicateItem){
        return [self updateKeychainValueWithUser:username Token:tokenID ];
    }else{
        return NO;
        
    }
}

+ (BOOL)updateKeychainValueWithUser:(NSString *)username Token:(NSString *)tokenID
{
    NSMutableDictionary *searchdictionary = [self setupSearchDirectory];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    
    [searchdictionary setObject:[username dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
    [updateDictionary setObject:[username dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
    [updateDictionary setObject:[tokenID dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
   // [updateDictionary setObject:[xmlStr dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrComment];
    
    //Create Timestamp
    NSString * time_stamp = [self createTimeStamp];
    [updateDictionary setObject:[time_stamp dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrDescription];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchdictionary, (__bridge CFDictionaryRef)updateDictionary);
    
    if(status == errSecSuccess){
        return YES;
    }else{
        return NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////////////


+(NSDateFormatter *)getNSDateFormatterForTimestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    return dateFormatter;
}

+ (NSString *)createTimeStamp{
    NSString *date_str =[[self getNSDateFormatterForTimestamp] stringFromDate:[NSDate date]];
    return date_str;
}

+ (NSDate *)dateFromTimeStamp:(NSString *)timestamp{
    NSDate *date =[[self getNSDateFormatterForTimestamp] dateFromString:timestamp];
    return date;
}

@end
