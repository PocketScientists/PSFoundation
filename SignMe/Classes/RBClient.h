//
//  RBClient.h
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBDocument;

@interface RBClient : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *documents;
@end

@interface RBClient (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(RBDocument *)value;
- (void)removeDocumentsObject:(RBDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;
@end
