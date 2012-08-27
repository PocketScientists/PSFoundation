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


@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *country_iso;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *postalcode;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSString *classification1;
@property (nonatomic, strong) NSString *classification2;
@property (nonatomic, strong) NSString *classification3;
@property (nonatomic, strong) NSString *updated_at;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *logo_url;
@property (nonatomic, strong) NSString * company;
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
