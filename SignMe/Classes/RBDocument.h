//
//  RBDocument.h
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBClient, RBRecipient;

@interface RBDocument : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uploadedToBox;
@property (nonatomic, retain) RBClient *client;
@property (nonatomic, retain) NSSet *recipients;
@end

@interface RBDocument (CoreDataGeneratedAccessors)

- (void)addRecipientsObject:(RBRecipient *)value;
- (void)removeRecipientsObject:(RBRecipient *)value;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;
@end
