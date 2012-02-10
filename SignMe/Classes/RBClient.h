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
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSNumber * visible;
@property (nonatomic, strong) NSSet *documents;
@end

@interface RBClient (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(RBDocument *)value;
- (void)removeDocumentsObject:(RBDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;
@end
