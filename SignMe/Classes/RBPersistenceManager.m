//
//  RBPersistenceManager.m
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBPersistenceManager.h"
#import "RBDocument.h"
#import "PSIncludes.h"
#import "RBPDFWriter.h"

@interface RBPersistenceManager ()

- (void)createPDFForDocument:(RBDocument *)document form:(RBForm *)form;

@end

@implementation RBPersistenceManager

- (void)persistDocumentUsingForm:(RBForm *)form client:(RBClient *)client {
    RBDocument *document = [RBDocument createEntity];
    
    // set form
    if ([form saveAsDocument]) {
        DDLogInfo(@"Saved form with name: %@", form.fileName);
        document.name = form.name;
        document.fileURL = form.fileName;
        document.status = $I(RBFormStatusPreSignature);
        document.date = [NSDate date];
        // set client
        document.client = client;
 
        [self createPDFForDocument:document form:form];
        [[NSManagedObjectContext defaultContext] saveOnMainThread];
    } else {
        DDLogError(@"Couldn't save form with name: %@", form.fileName);
    }
}

- (void)updateDocument:(RBDocument *)document usingForm:(RBForm *)form {
    document.date = [NSDate date];
    
    // update Form Plist
    [form saveAsDocumentWithName:document.fileURL];
    // update PDF Document
    [self createPDFForDocument:document form:form];
    
    [[NSManagedObjectContext defaultContext] saveOnMainThread];
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

- (NSDate *)updateDateForClient:(RBClient *)client {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"client = %@ AND date = client.documents.@max.date", client];
    // RBDocument *lastUpdatedDocument = [RBDocument findFirstWithPredicate:predicate];
    
    //return lastUpdatedDocument.date;
    
    return [NSDate date];
}

- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d",(NSInteger)formStatus];
    return [[RBDocument numberOfEntitiesWithPredicate:predicate] intValue];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)createPDFForDocument:(RBDocument *)document form:(RBForm *)form {
    // create PDF
    RBPDFWriter *pdfWriter = [[[RBPDFWriter alloc] init] autorelease];
    NSURL *urlToEmptyPDF = [NSURL fileURLWithPath:[kRBBoxNetDirectoryPath stringByAppendingPathComponent:RBFileNameForPDFWithName(document.name)]];
    CGPDFDocumentRef pdfRef = [pdfWriter openDocument:urlToEmptyPDF];
    NSString *pdfFileURL = [kRBPDFSavedDirectoryPath stringByAppendingPathComponent:[document.fileURL stringByAppendingString:kRBPDFExtension]];
    
    [pdfWriter writePDFDocument:pdfRef
                   withFormData:form.PDFDictionary 
                         toFile:pdfFileURL];
}

@end
