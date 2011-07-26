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

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (argc == 2) {
        NSString *pdfName = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        RBPDFManager *manager = [[RBPDFManager alloc] init];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@.pdf", pdfName]];
        CGPDFDocumentRef document = [manager openDocument:url];
        NSDictionary *annoationDictionary = [manager annotsForPDFDocument:document];
        
        [annoationDictionary writeToFile:[NSString stringWithFormat:@"%@.plist", pdfName] atomically:YES];
    }
    
    else {
        NSLog(@"Wrong number of parameters, example-usage: ./PlistCreator fw9");
    }
    
    [pool drain];
    
    return 0;
}

