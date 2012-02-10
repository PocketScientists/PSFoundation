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

+ (RBMusketeer *)loadEntity;
+ (RBMusketeer *)reloadEntity;
- (void)saveEntity;

@end
