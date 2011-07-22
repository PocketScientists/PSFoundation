//
//  RBClient.h
//  SignMe
//
//  Created by Tretter Matthias on 22.07.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RBDocument;

@interface RBClient : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSSet *documents;
@end

@interface RBClient (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(RBDocument *)value;
- (void)removeDocumentsObject:(RBDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;
@end
