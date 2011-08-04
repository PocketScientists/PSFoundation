//
//  RBDocuSignService.m
//  SignMe
//
//  Created by Tretter Matthias on 04.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBDocuSignService.h"
#import "PSIncludes.h"
#import "DocuSignService.h"
#import "RBDocument+RBForm.h"

@implementation RBDocuSignService

+ (void)sendDocument:(RBDocument *)document { 
    // DocuSign object for sending request
    DocuSignService *docuSign = [[[DocuSignService alloc] init] autorelease];
    
    // set up credentials for DocuSign-Service
    docuSign.username = [NSUserDefaults standardUserDefaults].docuSignUserName;
    docuSign.password = [NSUserDefaults standardUserDefaults].docuSignPassword;
    [docuSign login];
    
    if (docuSign.account != nil) {
        // dictionary holding the PDF data and name
        NSDictionary *documentDictionary = XDICT(document.name, @"name", document.filledPDFData, @"pdf");
        // all the recipients of the PDF
        NSArray *recipients = [document recipientsAsDictionary];
        NSArray *tabs = document.form.tabs;
        NSString *subject = @"Sign this Red Bull Document"; //document.subject != nil ? document.subject : @"Sign this Red Bull Document";
        
        
        [docuSign createAndSendEnvelopeWithDocuments:[NSArray arrayWithObject:documentDictionary] 
                                          recipients:recipients
                                                tabs:tabs
                                             subject:subject];
    } else {
        DDLogError(@"Error logging in to DocuSign Service!");
    }
}

@end
