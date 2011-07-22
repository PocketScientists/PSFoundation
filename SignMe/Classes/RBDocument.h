//
//  RBDocument.h
//  SignMe
//
//  Created by Tretter Matthias on 22.07.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBClient;

@interface RBDocument : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) RBClient *client;

@end
