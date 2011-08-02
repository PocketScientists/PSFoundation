//
//  NGPDFManager.m
//  NOUSGuide
//
//  Created by Jürgen Falb on 21.07.11.
//  Copyright 2011 NOUSGuide Inc. All rights reserved.
//

#import "RBPDFManager.h"
#import "RBForm.h"


@implementation RBPDFManager

@synthesize password;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [password release], password = nil;
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PDF Handling
////////////////////////////////////////////////////////////////////////

- (CGPDFDocumentRef)openDocument:(NSURL *)url {
    CGPDFDocumentRef myDocument = CGPDFDocumentCreateWithURL((CFURLRef)url);
    
    if (myDocument == NULL) {
        return NULL;
    }
    
    if (CGPDFDocumentIsEncrypted(myDocument)) {
        if (!CGPDFDocumentUnlockWithPassword (myDocument, "")) {
            if (self.password != NULL) {
                if (!CGPDFDocumentUnlockWithPassword(myDocument, [self.password cStringUsingEncoding:NSUTF8StringEncoding])) {
                    NSLog(@"error invalid password");
                    CGPDFDocumentRelease(myDocument);
                    return NULL;
                }
            }
        }
    }
   
    if (!CGPDFDocumentIsUnlocked(myDocument)) {
        NSLog(@"cannot unlock PDF %@", url);
        CGPDFDocumentRelease(myDocument);
        return NULL;
    }

    if (CGPDFDocumentGetNumberOfPages(myDocument) == 0) {
        CGPDFDocumentRelease(myDocument);
        return NULL;
    }

    return myDocument;
}

- (NSDictionary *)annotsForPDFDocument:(CGPDFDocumentRef)document {
    NSMutableDictionary *annotationDict = [NSMutableDictionary dictionary];
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(document);
    NSMutableArray *sectionsArray = [NSMutableArray arrayWithCapacity:numberOfPages];
    NSDictionary *sampleTab1 = [NSDictionary dictionaryWithObjectsAndKeys:@"1", kRBFormKeyTabPage,
                                @"100", kRBFormKeyTabX,
                                @"120", kRBFormKeyTabY,
                                @"SignHere", kRBFormKeyTabType, nil];
    NSDictionary *sampleTab2 = [NSDictionary dictionaryWithObjectsAndKeys:@"2", kRBFormKeyTabPage,
                                @"200", kRBFormKeyTabX,
                                @"140", kRBFormKeyTabY,
                                @"InitialHere", kRBFormKeyTabType, nil];
    NSArray *tabsArray = [NSArray arrayWithObjects:sampleTab1, sampleTab2, nil];
    
    // we create a dictionary with one section for each page
    [annotationDict setObject:sectionsArray forKey:kRBFormKeySection];
    // pre-defined display name, could use fileName instead but am too lazy ;)
    [annotationDict setObject:@"PDF Form" forKey:kRBFormKeyDisplayName];
    // we create two sample-tabs so that the user sees how to create those
    [annotationDict setObject:tabsArray forKey:kRBFormKeyTabs];
    
    for (int pageIndex = 1; pageIndex <= numberOfPages; pageIndex++) {        
        //Draw the page onto the new context
        CGPDFPageRef page = CGPDFDocumentGetPage(document, pageIndex);
        CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(page);
        
        // retrieve the annotations dictionary
        CGPDFArrayRef annots;
        CGPDFDictionaryGetArray(pageDict, "Annots", &annots);
        
        if (annots) {
            NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:CGPDFArrayGetCount(annots)];
            
            for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
                NSMutableDictionary *fieldDict = [NSMutableDictionary dictionaryWithCapacity:2];
                
                // retrieve a field from the annotations
                CGPDFDictionaryRef field;
                CGPDFArrayGetDictionary(annots, i, &field);
                
                // retrieve the field name
                CGPDFStringRef name;
                CGPDFDictionaryGetString(field, "T", &name);
                CFStringRef nameString = CGPDFStringCopyTextString(name);
                
                // retreive the data type
                const char *datatype;
                CGPDFDictionaryGetName(field, "FT", &datatype);
                
                // set dictionary for field
                [fieldDict setObject:(NSString*)nameString forKey:kRBFormKeyID];
                [fieldDict setObject:(NSString*)nameString forKey:kRBFormKeyLabel];
                [fieldDict setObject:[NSString stringWithCString:datatype encoding:NSUTF8StringEncoding] forKey:kRBFormKeyDatatype];
                [fieldDict setObject:kRBFormKeyMappingNone forKey:kRBFormKeyMapping];
                
                [pageArray addObject:fieldDict];
                
                CFRelease(nameString);
            }
            
            [sectionsArray addObject:pageArray];
        }
    }
    
    return [[annotationDict copy] autorelease];
}


@end
