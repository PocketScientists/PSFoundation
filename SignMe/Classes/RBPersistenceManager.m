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

@implementation RBPersistenceManager

- (void)persistDocumentUsingForm:(RBForm *)form client:(RBClient *)client {
    RBDocument *document = [RBDocument createEntity];
    
    // set form
    if ([form saveAsDocument]) {
        DDLogInfo(@"Saved form at path: %@", form.filePath);
        document.name = form.name;
        document.fileURL = form.filePath;
        document.status = $I(RBFormStatusPreSignature);
        document.date = [NSDate date];
        
        // set client
        document.client = client;
        
        // create PDF
#pragma message("This will not work yet!!")
        /*RBPDFWriter *pdfWriter = [[[RBPDFWriter alloc] init] autorelease];
         NSURL *urlToEmptyPDF = [NSURL fileURLWithPath:[NSDocumentsFolder() stringByAppendingPathComponent:document.name]];
         CGPDFDocumentRef pdfRef = [pdfWriter openDocument:urlToEmptyPDF];
         
         [pdfWriter writePDFDocument:pdfRef
         withFormData:form.PDFDictionary 
         toFile:[kRBFormPDFDirectoryPath stringByAppendingPathComponent:document.name]];*/
    } else {
        DDLogError(@"Couldn't save form at path: %@", form.filePath);
    }
}

- (RBClient *)clientWithName:(NSString *)name {
    RBClient *existingClient = [RBClient findFirstByAttribute:@"name" withValue:name];
    
    if (existingClient == nil) {
        existingClient = [RBClient createEntity];
        existingClient.name = name;
    }
    
    return existingClient;
}

- (NSDate *)updateDateForClient:(RBClient *)client {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"client = %@ AND date = client.documents.@max.date", client];
    RBDocument *lastUpdatedDocument = [RBDocument findFirstWithPredicate:predicate];
    
    return lastUpdatedDocument.date;
}

- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d",(NSInteger)formStatus];
    return [[RBDocument numberOfEntitiesWithPredicate:predicate] intValue];
}

@end
