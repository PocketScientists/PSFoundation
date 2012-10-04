//
//  RBRecipient.h
//  SignMe
//
//  Created by Jürgen Falb on 13.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBDocument;

@interface RBRecipient : NSManagedObject

@property (nonatomic, strong) NSNumber * addressBookPersonID;
@property (nonatomic, strong) NSNumber * emailPropertyID;
@property (nonatomic, strong) NSNumber * type;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSNumber * idcheck;
@property (nonatomic, strong) NSNumber * code;
@property (nonatomic, strong) NSString * kind;
@property (nonatomic, strong) RBDocument *document;
@property (nonatomic, strong) NSNumber * neededSigner;

@end
