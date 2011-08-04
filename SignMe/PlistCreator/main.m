//
//  main.m
//  PlistCreator
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import "RBPDFManager.h"
#import "RBForm.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (argc < 2) {
        NSLog(@"You must specify a minimum of one pdf names, example-usage: ./PlistCreator fw9");
        [pool drain];
        return 0;
    }
    
    // create a plist for each specified pdf-name in params
    for (int i=1;i<argc;i++) {
        NSString *pdfName = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
        RBPDFManager *manager = [[RBPDFManager alloc] init];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@.pdf", pdfName]];
        CGPDFDocumentRef document = [manager newOpenDocument:url];
        NSMutableDictionary *annoationDictionary = [manager annotsForPDFDocument:document];
        
        [annoationDictionary setValue:pdfName forKey:kRBFormKeyDisplayName];
        
        [annoationDictionary writeToFile:[NSString stringWithFormat:@"%@.plist", pdfName] atomically:YES];
        CFRelease(document);
        
        NSLog(@"Created %@.plist", pdfName);
    }
    
    [pool drain];
    
    return 0;
}

