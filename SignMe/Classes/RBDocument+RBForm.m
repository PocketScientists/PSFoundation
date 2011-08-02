//
//  RBDocument+RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 02.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBDocument+RBForm.h"
#import "PSIncludes.h"

@implementation RBDocument (RBDocument_RBForm)

- (RBForm *)form {
    return [[[RBForm alloc] initWithPath:RBPathToPlistWithName(self.fileURL) name:self.name] autorelease];
}

@end
