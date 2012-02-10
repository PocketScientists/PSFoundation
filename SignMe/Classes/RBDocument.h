//
//  RBDocument.h
//  SignMe
//
//  Created by Tretter Matthias on 04.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBClient, RBRecipient;

@interface RBDocument : NSManagedObject {
@private
}
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * docuSignEnvelopeID;
@property (nonatomic, strong) NSString * fileURL;
@property (nonatomic, strong) NSNumber * lastDocuSignStatus;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSNumber * uploadedToBox;
@property (nonatomic, strong) NSNumber * obeyRoutingOrder;
@property (nonatomic, strong) RBClient *client;
@property (nonatomic, strong) NSSet *recipients;
@end

@interface RBDocument (CoreDataGeneratedAccessors)

- (void)addRecipientsObject:(RBRecipient *)value;
- (void)removeRecipientsObject:(RBRecipient *)value;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;
@end
