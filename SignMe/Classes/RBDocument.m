//
//  RBDocument.m
//  SignMe
//
//  Created by Tretter Matthias on 04.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBDocument.h"
#import "RBClient.h"
#import "RBRecipient.h"


@implementation RBDocument
@dynamic date;
@dynamic fileURL;
@dynamic name;
@dynamic status;
@dynamic subject;
@dynamic uploadedToBox;
@dynamic docuSignEnvelopeID;
@dynamic lastDocuSignStatus;
@dynamic client;
@dynamic recipients;

@end
