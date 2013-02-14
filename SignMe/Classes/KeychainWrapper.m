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

+ (NSDictionary *)getKeychainDictionaryForUser:(NSString *) user
{
    NSLog(@"Try to read Keychain Entries for user %@",user);
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
        
        resdata = [result valueForKey:(__bridge id)kSecAttrDescription];
        NSString *auth_date = [[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding];
        NSDate *date = [self dateFromTimeStamp:auth_date];
        if(date)
        { [returnDictionary setObject:date forKey:@"last_auth_date"]; }
        
        resdata = [result valueForKey:(__bridge id)kSecAttrLabel];
        
        if(resdata && [resdata isKindOfClass:[NSData class]] ) {
            NSString *outletJSON = [[NSString alloc] initWithData:resdata encoding:NSUTF8StringEncoding];
            if (outletJSON) {
                [returnDictionary setObject:outletJSON forKey:@"outlet_json"];
            }
        }
        
        //If all entries are in the dictionary
        if(returnDictionary.count >= 3){
            return returnDictionary;    }
        else{
            return nil;
        }
    }else{
        return nil;}
}

+ (NSString *)readOutletJSONFromKeychain {
    RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
    if (rbmusketeer.uid &&rbmusketeer.uid.length > 0) {
        NSDictionary *reqInfo =  [KeychainWrapper getKeychainDictionaryForUser:rbmusketeer.uid];
        return [reqInfo valueForKey:@"outlet_json"];
    }
    return nil;
}

+ (void)clearOutletJSONFromKeychain:(NSString *)outletID {
    NSMutableDictionary *searchdictionary = [self setupSearchDirectory];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];

    RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
    if (rbmusketeer.uid && rbmusketeer.uid.length > 0) {
        NSDictionary *reqInfo =  [KeychainWrapper getKeychainDictionaryForUser:rbmusketeer.uid];
        NSString *keychainOutlets = [reqInfo valueForKey:@"outlet_json"];
        NSData* data = [keychainOutlets dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *jsonArray = nil;
        if (data) {
            jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:nil];
        }
        
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        for(NSDictionary *item in jsonArray) {
            NSString *identifier = [item valueForKey:@"id"];
            if (![identifier isEqualToString:outletID]) {
                [newArray addObject:item];
            }
        }

        
        NSData *newKeychainContent = [NSJSONSerialization dataWithJSONObject:newArray options:nil error:nil];
        if (!newKeychainContent) {
            newKeychainContent = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        [searchdictionary setObject:[rbmusketeer.uid dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
        [updateDictionary setObject:[rbmusketeer.uid dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
        [updateDictionary setObject:[rbmusketeer.token dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        [updateDictionary setObject:newKeychainContent forKey:(__bridge id)kSecAttrLabel];
        
        SecItemUpdate((__bridge CFDictionaryRef)searchdictionary, (__bridge CFDictionaryRef)updateDictionary);
    }
}


+ (BOOL)createKeychainValueWithUser:(NSString *)username Token:(NSString *)tokenID
{
    NSMutableDictionary *dictionary = [self setupSearchDirectory];
    
    [dictionary setObject:[username dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrAccount];
    [dictionary setObject:[tokenID dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
    
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
        [[[UIAlertView alloc] initWithTitle:@"SignMe-Keychain" message:[NSString stringWithFormat:@"%@ %d",@"Error writing in shared Keychain: code %d",(int)status] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    
    //Create Timestamp
    NSString * time_stamp = [self createTimeStamp];
    [updateDictionary setObject:[time_stamp dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrDescription];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchdictionary, (__bridge CFDictionaryRef)updateDictionary);
    
    if(status == errSecSuccess){
        return YES;
    }else{
        [[[UIAlertView alloc] initWithTitle:@"SignMe-Keychain" message:[NSString stringWithFormat:@"%@ %d",@"Error updating shared Keychain: code %d",(int)status] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sets the default search values in the dictionary
+ (NSMutableDictionary *)setupSearchDirectory{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [searchDictionary setObject:[@"Authentication" dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecAttrGeneric];
    //Written to the entitlement file as default
    [searchDictionary setObject:@"5HPAW9M6JM.redbull" forKey:(__bridge id)kSecAttrAccessGroup];
    return searchDictionary;
}

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
