//
//  RBPersistenceManager.m
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBPersistenceManager.h"
#import "RBDocument.h"
#import "RBRecipient.h"
#import "PSIncludes.h"
#import "RBPDFWriter.h"
#import "AppDelegate.h"
#import "NCPDFCreator.h"

@interface RBPersistenceManager ()

- (void)createPDFForDocument:(RBDocument *)document form:(RBForm *)form;

@end

@implementation RBPersistenceManager

- (RBDocument *)persistedDocumentUsingForm:(RBForm *)form client:(RBClient *)client recipients:(NSArray *)recipients subject:(NSString *)subject obeyRoutingOrder:(BOOL)obeyRoutingOrder {
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    RBDocument *document = [RBDocument createEntity];
    
    // set form
    if ([form saveAsDocument]) {
        DDLogInfo(@"Saved form with name: %@", form.fileName);
        document.name = form.name;
        document.fileURL = form.fileName;
        document.status = $I(RBFormStatusPreSignature);
        document.date = [NSDate date];
        document.subject = subject;
        // set client
        document.client = client;
        document.obeyRoutingOrder = [NSNumber numberWithBool:obeyRoutingOrder];
        
        // add recipients of document
        int order = 1;
        for (NSDictionary *recipientDict in recipients) {
            RBRecipient *recipient = [RBRecipient createEntity];
            
            for (NSString *key in [recipientDict allKeys]) {
                [recipient setValue:[recipientDict valueForKey:key] forKey:key];
            }
            
            recipient.order = [NSNumber numberWithInt:order];
            recipient.document = document;
            order++;
        }
        
//        dispatch_async(queue, ^(void) {
            [self createPDFForDocument:document form:form];
//        });
        
        [[NSManagedObjectContext defaultContext] saveOnMainThread];
        
        return document;
    } else {
        DDLogError(@"Couldn't save form with name: %@", form.fileName);
        return nil;
    }
}

- (void)updateDocument:(RBDocument *)document usingForm:(RBForm *)form recipients:(NSArray *)recipients subject:(NSString *)subject obeyRoutingOrder:(BOOL)obeyRoutingOrder {
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    document.date = [NSDate date];
    document.subject = subject;
    document.obeyRoutingOrder = [NSNumber numberWithBool:obeyRoutingOrder];
    
//    dispatch_async(queue, ^(void) {
        // update Form Plist
        [form saveAsDocumentWithName:document.fileURL];
        // update PDF Document
        [self createPDFForDocument:document form:form];
//    });
    
    // update recipients
    // delete old ones 
    document.recipients = nil;
    [RBRecipient truncateAllMatchingPredicate:[NSPredicate predicateWithFormat:@"document = %@", document]];
    // add new ones
    int order = 1;
    for (NSDictionary *recipientDict in recipients) {
        RBRecipient *recipient = [RBRecipient createEntity];
        
        for (NSString *key in [recipientDict allKeys]) {
            [recipient setValue:[recipientDict valueForKey:key] forKey:key];
        }
        
        recipient.order = [NSNumber numberWithInt:order];
        recipient.document = document;
        order++;
    }
    
    [[NSManagedObjectContext defaultContext] saveOnMainThread];
}

- (NSArray *)unfinishedDocumentsAlreadySentToDocuSign {
    return [RBDocument findAllWithPredicate:[NSPredicate predicateWithFormat:@"docuSignEnvelopeID != nil AND status != %d", RBFormStatusSigned]];
}

- (RBClient *)clientWithName:(NSString *)name {
    RBClient *existingClient = [RBClient findFirstByAttribute:@"name" withValue:name];
    
    if (existingClient == nil) {
        existingClient = [RBClient createEntity];
        existingClient.name = name;
        [[NSManagedObjectContext defaultContext] saveOnMainThread];
    }
    
    return existingClient;
}


- (RBClient *)clientWithIdentifier:(NSString *)identifier {
    RBClient *existingClient = [RBClient findFirstByAttribute:@"identifier" withValue:identifier];
    
    if (existingClient == nil) {
        existingClient = [RBClient createEntity];
        existingClient.identifier = identifier;
        [[NSManagedObjectContext defaultContext] saveOnMainThread];
    }
    
    return existingClient;
}

- (NSDate *)updateDateForClient:(RBClient *)client {
    NSArray *allDocuments = [RBDocument findAllSortedBy:@"date" 
                                              ascending:NO 
                                          withPredicate:[NSPredicate predicateWithFormat:@"client = %@", client]];
    
    return [[allDocuments firstObject] valueForKey:@"date"];
}

- (NSDate *)updateDateForFormStatus:(RBFormStatus)formStatus {
    NSArray *allDocuments = [RBDocument findAllSortedBy:@"date" 
                                              ascending:NO 
                                          withPredicate:[NSPredicate predicateWithFormat:@"status = %d", formStatus]];
    
    return [[allDocuments firstObject] valueForKey:@"date"];
}

- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d",(NSInteger)formStatus];
    return [[RBDocument numberOfEntitiesWithPredicate:predicate] intValue];
}

- (void)deleteDocument:(RBDocument *)document {
    [document deleteEntity];
    [[NSManagedObjectContext defaultContext] save];
}

- (void)deleteClient:(RBClient *)client{
    [client deleteEntity];
    [[NSManagedObjectContext defaultContext] save];
}

- (void)deleteAllSavedData {
    // delete CoreData entities
    [RBDocument truncateAll];
    [RBClient truncateAll];
    [RBRecipient truncateAll];
    [[NSManagedObjectContext defaultContext] save];
    
    // delete files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:kRBBoxNetDirectoryPath]) {
        [fileManager removeItemAtPath:kRBBoxNetDirectoryPath error:nil];
    }

    if ([fileManager fileExistsAtPath:kRBPDFSavedDirectoryPath]) {
        [fileManager removeItemAtPath:kRBPDFSavedDirectoryPath error:nil];
    }
    
    if ([fileManager fileExistsAtPath:kRBFormSavedDirectoryPath]) {
        [fileManager removeItemAtPath:kRBFormSavedDirectoryPath error:nil];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)createPDFForDocument:(RBDocument *)document form:(RBForm *)form {
    NSLog(@"documentname: %@",document.name);
   // if ([document.name isEqualToString:@"PA"] || [document.name isEqualToString:@"PFP_PA"]) {
        NSString *pdfFileURL = RBPathToPDFWithName(document.fileURL);
    //    NSDictionary *template = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:document.name ofType:@"plist"]];
 //NSDictionary *template = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Bar_Battle_Concept_PA_PDF" ofType:@"plist"]];
    NSString * fullpath = [NSString stringWithFormat:@"%@/%@%@",kRBFolderUserEmptyForms,@"Bar_Battle_Concept_PA_PDF",kRBFormExtension];
    NSLog(@"search for dict on path %@",fullpath);
    //NSDictionary *template = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:fullpath]];
         NSDictionary *template = [[NSMutableDictionary alloc] initWithContentsOfFile:fullpath];
        NSMutableDictionary *data = [form.PDFDictionary mutableCopy];
        [data addEntriesFromDictionary:[form optionalSectionsDictionary]];
        
        NCPDFCreator *creator = [[NCPDFCreator alloc] init];
        [creator createDocumentAtURL:[NSURL fileURLWithPath:pdfFileURL] withFormData:data andTemplate:template];
   /* }
    else {
        // create PDF
        RBPDFWriter *pdfWriter = [[RBPDFWriter alloc] init];
        
        NSString *emptyDocName = document.name;
        NSString *discriminator = [form discriminator];
        if (discriminator && [discriminator length] > 0) {
            emptyDocName = [NSString stringWithFormat:@"%@_%@", document.name, discriminator];
        }
        NSLog(@"Name of PDF template used: %@", emptyDocName);
       // NSURL *urlToEmptyPDF = [NSURL fileURLWithPath:[kRBBoxNetDirectoryPath stringByAppendingPathComponent:RBFileNameForPDFWithName(emptyDocName)]];
        emptyDocName = @"Bar_Battle_Concept_PA_PDF.plist";
        NSURL *urlToEmptyPDF = [NSURL fileURLWithPath:[kRBFolderUserEmptyForms stringByAppendingPathComponent:emptyDocName]];
        CGPDFDocumentRef pdfRef = [pdfWriter newOpenDocument:urlToEmptyPDF];
        if (pdfRef) {
            NSString *pdfFileURL = RBPathToPDFWithName(document.fileURL);
            
            [pdfWriter writePDFDocument:pdfRef
                           withFormData:form.PDFDictionary 
                                 toFile:pdfFileURL];
            
            CFRelease(pdfRef);
        }
        else {
            [self performBlock:^{
                [MTApplicationDelegate showErrorMessage:[NSString stringWithFormat:@"Error creating PDF file. Cannot find template %@.pdf", emptyDocName]];
            } afterDelay:1];
            DDLogInfo(@"Error creating PDF file %@", [urlToEmptyPDF absoluteString]);
        }
    }*/
}

@end
