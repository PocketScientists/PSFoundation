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
#import "RBDocuSigningViewController.h"


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
            [MTApplicationDelegate showLoadingMessage:@"Sending to DocuSign"];
            
            DSAPIService_EnvelopeStatus *status = [docuSign createAndSendEnvelopeWithDocuments:[NSArray arrayWithObject:documentDictionary] 
                                                                                    recipients:recipients
                                                                                          tabs:tabs
                                                                                       subject:subject];
            
            document.lastDocuSignStatus = $I(status.Status);
            
            if (status.Status == DSAPIService_EnvelopeStatusCode_Sent) {
                document.docuSignEnvelopeID = status.EnvelopeID;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [MTApplicationDelegate showSuccessMessage:@"Sending succesful"];
                    [MTApplicationDelegate.homeViewController updateUI];
                });
                
                // update document status after 10 seconds
                [self performSelector:@selector(updateStatusOfDocuments) afterDelay:10.];
            } else {
                [MTApplicationDelegate showErrorMessage:@"Error sending to DocuSign"];
                DDLogError(@"Wasn't able to send document: %d", status.Status);
            }
        } else {
            [MTApplicationDelegate showErrorMessage:@"Error logging in to DocuSign"];
            DDLogError(@"Error logging in to DocuSign Service!");
        }
    });
}


+ (void)cancelDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        [docuSign login];
        
        if (docuSign.account != nil) {
            [MTApplicationDelegate showLoadingMessage:@"Voiding Envelope @ DocuSign"];
            
            if ([docuSign cancelEnvelope:document.docuSignEnvelopeID reason:@"Voided by the sender"]) {
                document.lastDocuSignStatus = $I(DSAPIService_EnvelopeStatusCode_Voided);
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [MTApplicationDelegate showSuccessMessage:@"Envelope voided succesfully"];
                    [MTApplicationDelegate.homeViewController updateUI];
                });

                [[NSManagedObjectContext defaultContext] save];
                
                // update document status after 10 seconds
                [self performSelector:@selector(updateStatusOfDocuments) afterDelay:10.];
            } else {
                [MTApplicationDelegate showErrorMessage:@"Error voiding envelope @ DocuSign"];
                DDLogError(@"Wasn't able to void document");
            }
        } else {
            [MTApplicationDelegate showErrorMessage:@"Error logging in to DocuSign"];
            DDLogError(@"Error logging in to DocuSign Service!");
        }
    });
}

+ (void)previewDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        [docuSign login];
        
        if (docuSign.account != nil) {
            //            [MTApplicationDelegate showLoadingMessage:@"Signing Envelope @ DocuSign"];
            
            NSString *token = [docuSign authenticationToken:document.docuSignEnvelopeID];
            if (token) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    RBDocuSigningViewController *vc = [[RBDocuSigningViewController alloc] initWithNibName:nil bundle:nil];
                    
                    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
                    navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
                    navigationController.navigationBar.barStyle = UIBarStyleBlack;
                    
                    [MTApplicationDelegate.homeViewController presentModalViewController:navigationController animated:YES];
                    
                    [vc loadURL:token];
                    
                    MCReleaseNil(vc);
                });
            } else {
                [MTApplicationDelegate showErrorMessage:@"Error retrieving token from DocuSign for initiating viewing!"];
                DDLogError(@"Wasn't able to void document");
            }
        } else {
            [MTApplicationDelegate showErrorMessage:@"Error logging in to DocuSign"];
            DDLogError(@"Error logging in to DocuSign Service!");
        }
    });
}

+ (void)signDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        [docuSign login];
        
        if (docuSign.account != nil) {
//            [MTApplicationDelegate showLoadingMessage:@"Signing Envelope @ DocuSign"];
            
//            NSString *token = [docuSign authenticationToken:document.docuSignEnvelopeID];
//            NSString *token = [docuSign senderToken:document.docuSignEnvelopeID];
            NSString *token = [docuSign recipientToken:document.docuSignEnvelopeID recipient:[[document recipientsAsDictionary] firstObject] recipientId:0];
            if (token) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    RBDocuSigningViewController *vc = [[RBDocuSigningViewController alloc] initWithNibName:nil bundle:nil];
                    
                    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
                    navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
                    navigationController.navigationBar.barStyle = UIBarStyleBlack;
                    
                    [MTApplicationDelegate.homeViewController presentModalViewController:navigationController animated:YES];
                    
                    [vc loadURL:token];
                    
                    MCReleaseNil(vc);
                });
            } else {
                [MTApplicationDelegate showErrorMessage:@"Error retrieving token from DocuSign for initiating signing process!"];
                DDLogError(@"Wasn't able to void document");
            }
        } else {
            [MTApplicationDelegate showErrorMessage:@"Error logging in to DocuSign"];
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
        BOOL documentGotSigned = NO;
        
        [docuSign login];
        
        if (docuSign.account != nil) {
            for (RBDocument *document in documents) {
                DSAPIService_EnvelopeStatus *status = [docuSign statusForEnvelope:document.docuSignEnvelopeID];
                DSAPIService_EnvelopeStatusCode previousStatus = [document.lastDocuSignStatus intValue];
                
                DDLogInfo(@"DocuSign: Document '%@' of Client '%@' has status '%@'.", document.name, document.client.name, DSAPIService_EnvelopeStatusCode_stringFromEnum(status.Status));
                
                // update new docuSign-status
                document.lastDocuSignStatus = $I(status.Status);
                
                // Is document finished? -> update status
                if (status.Status == DSAPIService_EnvelopeStatusCode_Completed) {
                    document.status = $I(RBFormStatusSigned);
                    documentGotSigned = YES;
                    
                    // if status has changed to completed, delete old files from box.net folder pre-signature
                    if (previousStatus != DSAPIService_EnvelopeStatusCode_Completed) {
                        DDLogInfo(@"Will delete old files from Pre-Signature folder for document %@", document.fileURL);
                        [RBBoxService deleteDocument:document 
                                    fromFolderAtPath:RBPathToPreSignatureFolderForClientWithName(document.client.name)];
                    }
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
                }
            }
            
            // call main thread to update UI and CoreData
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (documentGotSigned) {
                    [MTApplicationDelegate showSuccessMessage:@"A document was fully signed!"];
                }
                
                [[NSManagedObjectContext defaultContext] save];
                [MTApplicationDelegate.homeViewController updateUI];
            });
        } else {
            DDLogError(@"Error logging in to DocuSign Service!");
        }
    });
}

@end
