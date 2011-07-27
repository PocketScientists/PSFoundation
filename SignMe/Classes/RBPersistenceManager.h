//
//  RBPersistenceManager.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBForm.h"
#import "RBClient.h"

@interface RBPersistenceManager : NSObject

// saves a plist for the from and creates a document in CoreData
- (void)persistDocumentUsingForm:(RBForm *)form client:(RBClient *)client;

// returns either a given client with the name or a new client with the given name
- (RBClient *)clientWithName:(NSString *)name;

// last update date of a client (= last update date of the client's documents)
- (NSDate *)updateDateForClient:(RBClient *)client;

// returns the document count with a specific formStatus
- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus;
@end
