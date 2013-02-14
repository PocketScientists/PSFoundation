//
//  KeychainWrapper.h
//  SignMe
//
//  Created by Michael Schwarz on 20.08.12.
//
//

#import <Foundation/Foundation.h>
#import "PSDefines.h"



@interface KeychainWrapper : NSObject




//Method returns the Dictionary with Token, Username, Userxml for a passed in Username
+ (NSDictionary *)getKeychainDictionaryForUser:(NSString *) user;

//Default initializer to store value in keychain - If Keychain Entries already exists - Update is called automatically
+ (BOOL)createKeychainValueWithUser:(NSString *)username Token:(NSString *)tokenID;

//Update a value in the keychain - is called automatically from createKeychainValue... if entry already exists.
+ (BOOL)updateKeychainValueWithUser:(NSString *)username Token:(NSString *)tokenID;

//Returns a string consisting offline created Outlets from the M.I.B app.
+ (NSString *)readOutletJSONFromKeychain;

//Clears the offline created Outlet with id from the keychain.
+ (void)clearOutletJSONFromKeychain:(NSString *)outletID;



@end
