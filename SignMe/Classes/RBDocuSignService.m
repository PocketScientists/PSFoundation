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
#import "NSUserDefaults+RBAdditions.h"


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

+ (void)reloadCredentials {
    // set up credentials for DocuSign-Service
    [docuSign logout];
    docuSign.username = [NSUserDefaults standardUserDefaults].docuSignUserName;
    docuSign.password = [NSUserDefaults standardUserDefaults].docuSignPassword;
}

+ (void)sendDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        NSString *result = nil;
        if (docuSign.account == nil) {
            result = [docuSign login];
        }
        
        if (docuSign.account != nil) {
            int noPages = [RBDocuSignService numberOfPDFPages:document.filledPDFURL];
            
            // dictionary holding the PDF data and name
            NSDictionary *documentDictionary = XDICT(document.name, @"name", document.filledPDFData, @"pdf");
            // all the recipients of the PDF
            NSArray *recipients = [document recipientsAsDictionary];
            NSArray *tabs = [document.form tabsForRecipients:recipients];
            for (NSMutableDictionary *tab in tabs) {
                id page = [tab objectForKey:kRBFormKeyTabPage];
                if ([page isKindOfClass:[NSString class]]) {
                    if ([page isEqualToString:@"last"]) {
                        [tab setObject:[NSNumber numberWithInt:noPages] forKey:kRBFormKeyTabPage];
                    }
                }
            }
            NSString *subject = !IsEmpty(document.subject) ? document.subject : @"Sign this Red Bull Document";
            BOOL routingOrder = document.obeyRoutingOrder ? [document.obeyRoutingOrder boolValue] : NO;
            
            DDLogInfo(@"DocuSign: Will send document '%@' of client '%@' with Subject '%@': %d Recipients, %d Tabs", document.name, document.client.name, subject, recipients.count, tabs.count);
            [MTApplicationDelegate showLoadingMessage:@"Sending to DocuSign"];
            
            NSError *error;
            DSAPIService_EnvelopeStatus *status = [docuSign createAndSendEnvelopeWithDocuments:[NSArray arrayWithObject:documentDictionary] 
                                                                                    recipients:recipients
                                                                                          tabs:tabs
                                                                                       subject:subject
                                                                                  routingOrder:routingOrder 
                                                                                         error:&error];
            
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
                [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Error finalizing document: %@. Please try again, otherwise contact your IT-support team.", [error localizedDescription]]];
                DDLogError(@"Wasn't able to send document: %d", status.Status);
            }
        } else {
            [MTApplicationDelegate showErrorMessage:result];
        }
    });
}


+ (void)cancelDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        NSString *result = [docuSign login];
        
        if (docuSign.account != nil) {
            [MTApplicationDelegate showLoadingMessage:@"Voiding Envelope @ DocuSign"];
            
            NSError *error;
            if ([docuSign cancelEnvelope:document.docuSignEnvelopeID reason:@"Voided by the sender" error:&error]) {
                document.lastDocuSignStatus = $I(DSAPIService_EnvelopeStatusCode_Voided);
              //  dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [MTApplicationDelegate showSuccessMessage:@"Envelope voided succesfully"];
                    //[MTApplicationDelegate.homeViewController updateUI];
                //});

                [[NSManagedObjectContext defaultContext] save];
                
                // update document status after 5 seconds
                [self performSelector:@selector(updateStatusOfDocuments)];
            } else {
                [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Error voiding envelope: %@. Please contact your IT-support team.", [error localizedDescription]]];
                DDLogError(@"Wasn't able to void document: %@", [error localizedDescription]);
            }
        } else {
            [MTApplicationDelegate showErrorMessage:result];
        }
    });
}

+ (void)previewDocument:(RBDocument *)document { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        NSString *result = [docuSign login];
        
        if (docuSign.account != nil) {
            //            [MTApplicationDelegate showLoadingMessage:@"Signing Envelope @ DocuSign"];
            
            NSError *error;
            NSString *token = [docuSign authenticationToken:document.docuSignEnvelopeID error:&error];
            if (token) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    RBDocuSigningViewController *vc = [[RBDocuSigningViewController alloc] initWithURL:token];
                    
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
                    navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
                    navigationController.navigationBar.barStyle = UIBarStyleBlack;
                    
                    [MTApplicationDelegate.homeViewController presentModalViewController:navigationController animated:YES];
                });
            } else {
                [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Eror initiating document viewing: %@. Please contact your IT-support team if the error persists.", [error localizedDescription]]];
                DDLogError(@"Error retrieving token from DocuSign for initiating viewing: %@", [error localizedDescription]);
            }
        } else {
            [MTApplicationDelegate showErrorMessage:result];
        }
    });
}

+ (void)signDocument:(RBDocument *)document recipient:(NSDictionary *)recipient { 
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^(void) {
        NSString *result = [docuSign login];
        
        if (docuSign.account != nil) {
//            [MTApplicationDelegate showLoadingMessage:@"Signing Envelope @ DocuSign"];
            
//            NSString *token = [docuSign authenticationToken:document.docuSignEnvelopeID];
//            NSString *token = [docuSign senderToken:document.docuSignEnvelopeID];
            NSError *error;
            NSString *token = [docuSign recipientToken:document.docuSignEnvelopeID recipient:recipient error:&error];
            if (token) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    RBDocuSigningViewController *vc = [[RBDocuSigningViewController alloc] initWithURL:token];
                    
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
                    navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
                    navigationController.navigationBar.barStyle = UIBarStyleBlack;
                    
                    [MTApplicationDelegate.homeViewController presentModalViewController:navigationController animated:YES];
                });
            } else {
                if ([[error localizedDescription] containsString:@"out of sequence"]) {
                    [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Signing by %@ is not allowed yet, since it is out of sequence as required by the document.", [recipient objectForKey:@"name"]]];
                }
                else {
                    [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Error initiating signing process: %@. Please contact your IT-support team if the error persists.", [error localizedDescription]]];
                }
                DDLogError(@"Error initiating signing process: %@. Please contact IT-Support.", [error localizedDescription]);
            }
        } else {
            [MTApplicationDelegate showErrorMessage:result];
        }
    });
}

+ (void)updateStatusOfDocuments {
    RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
    NSArray *documents = [persistenceManager unfinishedDocumentsAlreadySentToDocuSign];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    DDLogInfo(@"DocuSign: %d documents to update status.", documents.count);
    
    dispatch_async(queue, ^(void) {
        BOOL documentGotSigned = NO;
        
        NSString *result = nil;
        if (docuSign.account == nil) {
            result = [docuSign login];
        }
        
        if (docuSign.account != nil) {
            
            NSError *error;
            NSDate *lastUpdateDate = [NSUserDefaults standardUserDefaults].docuSignUpdateDate;
            lastUpdateDate = [lastUpdateDate earlierDate:[NSDate dateYesterday]];
            DSAPIService_FilteredEnvelopeStatusChanges *statusChanges = [docuSign requestStatusChangesSince:lastUpdateDate error:&error];
            
            if (statusChanges == nil) {
                DDLogError(@"Error updating document status: %@", [error localizedDescription]);
                return;
            }

            [NSUserDefaults standardUserDefaults].docuSignUpdateDate = [NSDate date];

            NSArray *envelopeStatusChanges = statusChanges.EnvelopeStatusChanges.EnvelopeStatusChange;
            for (DSAPIService_EnvelopeStatusChange *change in envelopeStatusChanges) {
                for (RBDocument *document in documents) {
                    if ([document.docuSignEnvelopeID isEqualToString:change.EnvelopeID]) {
                        DSAPIService_EnvelopeStatusCode status = change.Status;
                        DSAPIService_EnvelopeStatusCode previousStatus = [document.lastDocuSignStatus intValue];
                        
                        DDLogInfo(@"DocuSign: Document '%@' of Client '%@' has status '%@'.", document.name, document.client.name, DSAPIService_EnvelopeStatusCode_stringFromEnum(status));
                        
                        // update new docuSign-status
                        document.lastDocuSignStatus = $I(status);
                        
                        // Is document finished? -> update status
                        if (status == DSAPIService_EnvelopeStatusCode_Completed) {
                            document.status = $I(RBFormStatusSigned);
                            documentGotSigned = YES;
                            
                            // if status has changed to completed, delete old files from box.net folder pre-signature
                            if (previousStatus != DSAPIService_EnvelopeStatusCode_Completed) {
                                DDLogInfo(@"Will delete old files from Pre-Signature folder for document %@", document.fileURL);
                            //    [RBBoxService deleteDocument:document
                            //                fromFolderAtPath:RBPathToPreSignatureFolderForClientWithName(document.client.name)];
                            }
                        }
                        
                        // update saved PDF
                        if (status == DSAPIService_EnvelopeStatusCode_Signed || 
                            status == DSAPIService_EnvelopeStatusCode_Completed) {
                            NSData *signedPDFData = [docuSign requestPDF:document.docuSignEnvelopeID error:&error];
                            if (signedPDFData) {
                                NSURL *pdfFileURL = document.filledPDFURL;
                                NSLog(@"Document Signed id: %@",document.docuSignEnvelopeID);
                                // write to disk (overwrite previous PDF)
                                [signedPDFData writeToURL:pdfFileURL atomically:YES];
                                
                                //Sent E-Mail with fully signed document
                                if(status == DSAPIService_EnvelopeStatusCode_Completed){
                                    dispatch_async(queue, ^(void) {
                                        [MTApplicationDelegate.homeViewController sendEMailMessageInBackgroundWithPDFAttachment:signedPDFData
                                                                                                                   contractName:document.name
                                                                                                                         client:document.client.name];
                                    });
                                }
                                // Sent to Box.net
                               // NSString *folderPath = RBPathToFolderForStatusAndClientWithName([document.status intValue], document.client.name);
                               // [RBBoxService uploadDocument:document toFolderAtPath:folderPath];
                            }
                            else {
                                DDLogError(@"Cannot download signed PDF. Please download it manually: %@", [error localizedDescription]);
                                [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Cannot download signed PDF: %@. Please download it manually or contact your IT-support team.", [error localizedDescription]]];
                            }
                        }
                        break;
                    }
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
            [MTApplicationDelegate showErrorMessage:result];
        }
    });
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PDF Handling
////////////////////////////////////////////////////////////////////////

+ (int)numberOfPDFPages:(NSURL *)url {
    CGPDFDocumentRef myDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    
    if (myDocument == NULL) {
        return 0;
    }
    
    if (CGPDFDocumentIsEncrypted(myDocument)) {
        CGPDFDocumentRelease(myDocument);
        return 0;
    }
    
    if (!CGPDFDocumentIsUnlocked(myDocument)) {
        NSLog(@"cannot unlock PDF %@", url);
        CGPDFDocumentRelease(myDocument);
        return 0;
    }
    
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(myDocument);
    CGPDFDocumentRelease(myDocument);
    
    return numberOfPages;
}


@end
