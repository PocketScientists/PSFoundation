//
//  RBPersistenceManager.m
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBPersistenceManager.h"
#import "RBDocument.h"
#import "PSIncludes.h"

@implementation RBPersistenceManager

- (void)persistDocumentUsingForm:(RBForm *)form client:(RBClient *)client {
    RBDocument *document = [RBDocument createEntity];
    
    // set form
    [form saveAsDocument];
    document.name = form.name;
    document.fileURL = form.filePath;
    document.status = $I(RBFormStatusPreSignature);
    document.date = [NSDate date];
    
    // set client
    document.client = client;
}

@end
