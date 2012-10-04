//
//  RBClient.h
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBMusketeer : NSObject

@property (nonatomic, strong) NSString * firstname;
@property (nonatomic, strong) NSString * lastname;
@property (nonatomic, strong) NSString * role;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;

//added new properties from session.xml
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *auth_string;
@property (nonatomic, strong) NSString *application_url;
@property (nonatomic, strong) NSString *country_iso;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *sign_me_limit_1;
@property (nonatomic, strong) NSString *sign_me_limit_2;


+ (RBMusketeer *)loadEntity;
+ (RBMusketeer *)reloadEntity;
- (void)saveEntity;

@end
