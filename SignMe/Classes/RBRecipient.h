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

@property (nonatomic, retain) NSNumber * addressBookPersonID;
@property (nonatomic, retain) NSNumber * emailPropertyID;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * idcheck;
@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) RBDocument *document;

@end
