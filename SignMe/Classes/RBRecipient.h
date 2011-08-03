//
//  RBRecipient.h
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBDocument;

@interface RBRecipient : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * addressBookPersonID;
@property (nonatomic, retain) RBDocument *document;

@end
