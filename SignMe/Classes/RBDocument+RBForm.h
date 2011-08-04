//
//  RBDocument+RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 02.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBDocument.h"
#import "RBForm.h"

@interface RBDocument (RBDocument_RBForm)

@property (nonatomic, readonly) RBForm *form;
// return recipients in the form DocuSign needs them (as dictionary with name, e-mail)
@property (nonatomic, readonly) NSArray *recipientsAsDictionary;

@property (nonatomic, readonly) NSURL *filledPlistURL;
@property (nonatomic, readonly) NSData *filledPlistData;

@property (nonatomic, readonly) NSURL *filledPDFURL;
@property (nonatomic, readonly) NSData *filledPDFData;

@end
