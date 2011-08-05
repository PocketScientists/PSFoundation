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
#import "AppDelegate.h"
#import "RBPersistenceManager.h"

static DocuSignService *docuSign = nil;

@implementation RBDocuSignService

+ (void)initialize {
    if (self == [RBDocuSignService class]) {
        docuSign = [[DocuSignService alloc] init];
        
        // set up credentials for DocuSign-Service
        docuSign.username = [NSUserDefaults standardUserDefaults].docuSignUserName;
        docuSign.password = [NSUserDefaults standardUserDefaults].docuSignPassword;
    }
}

+ (void)sendDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        [docuSign login];
        
        if (docuSign.account != nil) {
            // dictionary holding the PDF data and name
            NSDictionary *documentDictionary = XDICT(document.name, @"name", document.filledPDFData, @"pdf");
            // all the recipients of the PDF
            NSArray *recipients = [document recipientsAsDictionary];
            NSArray *tabs = [document.form tabsForNumberOfRecipients:recipients.count];
            NSString *subject = !IsEmpty(document.subject) ? document.subject : @"Sign this Red Bull Document";
            
            DDLogInfo(@"DocuSign: Will send document '%@' of client '%@' with Subject '%@': %d Recipients, %d Tabs", document.name, document.client.name, subject, recipients.count, tabs.count);
            
            DSAPIService_EnvelopeStatus *status = [docuSign createAndSendEnvelopeWithDocuments:[NSArray arrayWithObject:documentDictionary] 
                                                                                    recipients:recipients
                                                                                          tabs:tabs
                                                                                       subject:subject];
            
            document.lastDocuSignStatus = $I(status.Status);
            
            if (status.Status == DSAPIService_EnvelopeStatusCode_Sent) {
                document.docuSignEnvelopeID = status.EnvelopeID;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [MTApplicationDelegate.homeViewController updateUI];
                });
            } else {
                DDLogError(@"Wasn't able to send document: %d", status.Status);
            }
        } else {
            DDLogError(@"Error logging in to DocuSign Service!");
        }
    });
}

+ (void)updateStatusOfDocuments {
    RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
    NSArray *documents = [persistenceManager unfinishedDocumentsAlreadySentToDocuSign];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    DDLogInfo(@"DocuSign: %d documents to update status.", documents.count);
    
    dispatch_async(queue, ^(void) {
        [docuSign login];
        
        if (docuSign.account != nil) {
            for (RBDocument *document in documents) {
                DSAPIService_EnvelopeStatus *status = [docuSign statusForEnvelope:document.docuSignEnvelopeID];
                
                DDLogInfo(@"DocuSign: Document '%@' of Client '%@' has status '%@'.", document.name, document.client.name, DSAPIService_EnvelopeStatusCode_stringFromEnum(status.Status));
                
                // update new docuSign-status
                document.lastDocuSignStatus = $I(status.Status);
                
                // Is document finished? -> update status
                if (status.Status == DSAPIService_EnvelopeStatusCode_Completed) {
                    document.status = $I(RBFormStatusSigned);
                }
                
                // update saved PDF
                if (status.Status == DSAPIService_EnvelopeStatusCode_Signed || 
                    status.Status == DSAPIService_EnvelopeStatusCode_Completed) {
                    NSData *signedPDFData = [docuSign requestPDF:document.docuSignEnvelopeID];
                    NSURL *pdfFileURL = document.filledPDFURL;
                    
                    // write to disk (overwrite previous PDF)
                    [signedPDFData writeToURL:pdfFileURL atomically:YES];
                    // Sent to Box.net
                    NSString *folderPath = RBPathToFolderForStatusAndClientWithName([document.status intValue], document.client.name);
                    [RBBoxService uploadDocument:document toFolderAtPath:folderPath];
                    // TODO: Delete pre-signature PDF and PList from Box if status has changed from Pre-Signature to Signed
                }
            }
            
            // call main thread to update UI and CoreData
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSManagedObjectContext defaultContext] save];
                [MTApplicationDelegate.homeViewController updateUI];
            });
        } else {
            DDLogError(@"Error logging in to DocuSign Service!");
        }
    });
}

@end
