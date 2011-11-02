//
//  RBRecipient+RBDocuSign.m
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBRecipient+RBDocuSign.h"
#import "ABAddressBook.h"
#import "ABPerson+RBMail.h"

@implementation RBRecipient (RBDocuSign)

- (NSDictionary *)dictionaryRepresentation {
    ABPerson *person = [[ABAddressBook sharedAddressBook] personWithRecordID:[self.addressBookPersonID intValue]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:person.fullName, @"name", [person emailForID:self.emailPropertyID], @"email", self.type, @"type", self.addressBookPersonID, @"id", self.order, @"order", self.idcheck, @"idcheck", self.code, @"code", nil];
}

@end
