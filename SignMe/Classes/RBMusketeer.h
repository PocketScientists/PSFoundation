//
//  RBClient.h
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBMusketeer : NSObject {
@private
}
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;

+ (RBMusketeer *)loadEntity;
- (void)saveEntity;

@end
