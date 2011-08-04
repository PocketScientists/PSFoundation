//
//  RBDocument+RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 02.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBDocument+RBForm.h"
#import "PSIncludes.h"
#import "RBRecipient.h"
#import "RBRecipient+RBDocuSign.h"

@implementation RBDocument (RBDocument_RBForm)

- (RBForm *)form {
    return [[[RBForm alloc] initWithPath:RBPathToPlistWithName(self.fileURL) name:self.name] autorelease];
}

- (NSArray *)recipientsAsDictionary {
    NSMutableArray *recipientsArray = [NSMutableArray arrayWithCapacity:self.recipients.count];
    
    for (RBRecipient *recipient in self.recipients) {
        [recipientsArray addObject:[recipient dictionaryRepresentation]];
    }
    
    return [[recipientsArray copy] autorelease];
}

- (NSURL *)filledPlistURL {
    return [NSURL fileURLWithPath:RBPathToPlistWithName(self.fileURL)];
}

- (NSData *)filledPlistData {
    return [NSData dataWithContentsOfURL:self.filledPlistURL];
}


- (NSURL *)filledPDFURL {
    return [NSURL fileURLWithPath:RBPathToPDFWithName(self.fileURL)];
}

- (NSData *)filledPDFData {
    return [NSData dataWithContentsOfURL:self.filledPDFURL];
}

@end
