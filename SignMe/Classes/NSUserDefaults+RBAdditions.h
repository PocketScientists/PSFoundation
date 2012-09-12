//
//  NSUserDefaults+RBAdditions.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (NSUserDefaults_RBAdditions)

@property (nonatomic, assign) NSInteger folderID;
@property (nonatomic, assign) BOOL shouldLogOutOfBox;
@property (nonatomic, retain) NSDate *formsUpdateDate;
@property (nonatomic, retain) NSDate *webserviceUpdateDate;
@property (nonatomic, retain) NSString *docuSignUserName;
@property (nonatomic, retain) NSString *docuSignPassword;
@property (nonatomic, retain) NSDate *docuSignUpdateDate;
@property (nonatomic, retain) NSString *boxUserName;
@property (nonatomic, retain) NSString *boxPassword;

- (NSArray *)allStoredObjectNames;
- (void)deleteStoredObjectNames;

- (void)setObjectID:(NSNumber *)objectID forObjectWithNameIncludingExtension:(NSString *)name;
- (NSNumber *)objectIDForObjectWithNameIncludingExtension:(NSString *)name;

- (void)setObjectID:(NSNumber *)objectID forPlistWithName:(NSString *)name;
- (NSNumber *)objectIDForPlistWithName:(NSString *)name;

- (void)setObjectID:(NSNumber *)objectID forPDFWithName:(NSString *)name;
- (NSNumber *)objectIDForPDFWithName:(NSString *)name;

-(void)setFormName:(NSString *)formname forObjectWithNameIncludingExtension:(NSString *)name ;

@end
