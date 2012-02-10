//
//  NGPDFManager.m
//  NOUSGuide
//
//  Created by Jürgen Falb on 21.07.11.
//  Copyright 2011 NOUSGuide Inc. All rights reserved.
//

#import "RBPDFManager.h"
#import "RBForm.h"


void GetButtonStateName(const char *key, CGPDFObjectRef object, void *info) {
    if (strcmp(key, "Off") != 0) {
        *(char **)info = (char *)key;
    }
}

@implementation RBPDFManager

@synthesize password;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    password = nil;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PDF Handling
////////////////////////////////////////////////////////////////////////

- (CGPDFDocumentRef)newOpenDocument:(NSURL *)url {
    CGPDFDocumentRef myDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    
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

- (NSMutableDictionary *)annotsForPDFDocument:(CGPDFDocumentRef)document {
    NSMutableDictionary *annotationDict = [NSMutableDictionary dictionary];
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(document);
    NSMutableArray *sectionsArray = [NSMutableArray arrayWithCapacity:numberOfPages];
    NSDictionary *sampleTab1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], kRBFormKeyTabPage,
                                [NSNumber numberWithInt:100], kRBFormKeyTabX,
                                [NSNumber numberWithInt:120], kRBFormKeyTabY,
                                @"SignHere", kRBFormKeyTabType, 
                                @"Signer", kRBFormKeyTabLabel, nil];
    NSDictionary *sampleTab2 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], kRBFormKeyTabPage,
                                [NSNumber numberWithInt:200], kRBFormKeyTabX,
                                [NSNumber numberWithInt:140], kRBFormKeyTabY,
                                @"InitialHere", kRBFormKeyTabType, nil];
    NSArray *recipientArray = [NSArray arrayWithObjects:sampleTab1, sampleTab2, nil];
    NSArray *tabsArray = [NSArray arrayWithObject:recipientArray];
    
    NSMutableArray *displayArray = [NSMutableArray arrayWithCapacity:numberOfPages];
    
    NSArray *exampleListItems = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    NSDictionary *exampleList = [NSDictionary dictionaryWithObjectsAndKeys:@"example_list_points", kRBFormKeyListID, exampleListItems, kRBFormKeyItems, nil];
    NSArray *listsArray = [NSArray arrayWithObject:exampleList];

    // we create a dictionary with one section for each page
    [annotationDict setObject:sectionsArray forKey:kRBFormKeySection];
    // pre-defined display name, could use fileName instead but am too lazy ;)
    [annotationDict setObject:@"PDF Form" forKey:kRBFormKeyDisplayName];
    // we create two sample-tabs so that the user sees how to create those
    [annotationDict setObject:tabsArray forKey:kRBFormKeyTabs];
    // add display infos
    [annotationDict setObject:displayArray forKey:kRBFormKeySectionInfos];
    // add an example list
    [annotationDict setObject:listsArray forKey:kRBFormKeyLists];
    
    for (int pageIndex = 1; pageIndex <= numberOfPages; pageIndex++) {        
        //Draw the page onto the new context
        CGPDFPageRef page = CGPDFDocumentGetPage(document, pageIndex);
        CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(page);
        
        // retrieve the annotations dictionary
        CGPDFArrayRef annots = NULL;
        CGPDFDictionaryGetArray(pageDict, "Annots", &annots);
        
        if (annots) {
            NSMutableArray *pageArray = [NSMutableArray arrayWithCapacity:CGPDFArrayGetCount(annots)];
            NSMutableDictionary *pageDisplayDict = [NSMutableDictionary dictionaryWithCapacity:2];
            
            [pageDisplayDict setObject:[NSString stringWithFormat:@"Page %d", pageIndex] forKey:kRBFormKeyDisplayName];
            
            [displayArray addObject:pageDisplayDict];
            
            NSMutableString *fields = [[NSMutableString alloc] initWithCapacity:100];
            for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
                NSMutableDictionary *fieldDict = [NSMutableDictionary dictionaryWithCapacity:2];
                
                // retrieve a field from the annotations
                CGPDFDictionaryRef field;
                CGPDFArrayGetDictionary(annots, i, &field);
                
                // Check if the annotation is a widget otherwise we ignore it
                const char *subtype = NULL;
                CGPDFDictionaryGetName(field, "Subtype", &subtype);
                if (subtype == NULL || strcmp(subtype, "Widget") != 0) {
                    continue;
                }
                
                // retrieve the data type
                const char *datatype = NULL;
                const char *btnType = NULL;
                const char *btnValue = NULL;
                CGPDFDictionaryGetName(field, "FT", &datatype);
                if (datatype == NULL) {
                    // this might be a radio button. Check for a parent object
                    CGPDFObjectRef parent = NULL;
                    CGPDFDictionaryRef parentType;

                    if (!CGPDFDictionaryGetObject(field, "Parent", &parent)) continue;
                    if (!CGPDFObjectGetValue(parent, kCGPDFObjectTypeDictionary, &parentType)) continue;
                    if (!CGPDFDictionaryGetName(parentType, "FT", &datatype)) continue;
                    
                    if (strcmp(datatype, "Btn") == 0) {
                        CGPDFInteger btnFlags;
                        if (!CGPDFDictionaryGetInteger(parentType, "Ff", &btnFlags)) continue;
                        if (btnFlags & kPDFRadioButton) {
                            btnType = "radio";
                            CGPDFDictionaryRef radioDict = NULL;
                            CGPDFDictionaryGetDictionary(field, "AP", &radioDict);
                            CGPDFDictionaryGetDictionary(radioDict, "N", &radioDict);
                            CGPDFDictionaryApplyFunction(radioDict, GetButtonStateName, &btnValue);
                        }
                        else if (btnFlags & kPDFPushButton) {
                            btnType = "push";
                        }
                        else {
                            btnType = "unknown";
                        }

                        // change or field to the parent field for further processing
                        field = parentType;
                    }
                    else {
                        continue;
                    }
                }
                else if (strcmp(datatype, "Btn") == 0) {
                    CGPDFInteger btnFlags = 0;
                    CGPDFDictionaryGetInteger(field, "Ff", &btnFlags);
                    if (btnFlags == 0 || (!(btnFlags & kPDFRadioButton) && !(btnFlags & kPDFPushButton))) {
                        btnType = "checkbox";
                        CGPDFDictionaryRef radioDict = NULL;
                        CGPDFDictionaryGetDictionary(field, "AP", &radioDict);
                        CGPDFDictionaryGetDictionary(radioDict, "N", &radioDict);
                        CGPDFDictionaryApplyFunction(radioDict, GetButtonStateName, &btnValue);
                    }
                    else {
                        btnType = "unknown";
                    }
                }
                
                // retrieve the field name
                CGPDFStringRef name;
                NSString *idString;
                if (!CGPDFDictionaryGetString(field, "T", &name)) continue;
                CFStringRef nameString = CGPDFStringCopyTextString(name);
                if (strcmp(datatype, "Btn") == 0 && strcmp(btnType, "radio") == 0) {
                    idString = [NSString stringWithFormat:@"%@ %s", nameString, btnValue];
                }
                else {
                    idString = (__bridge NSString *)nameString;
                }

                [fields appendString:idString];
                if (i < CGPDFArrayGetCount(annots) - 1) {
                    [fields appendString:@";"];
                }
                
                // set dictionary for field
                [fieldDict setObject:(NSString*)idString forKey:kRBFormKeyID];
                [fieldDict setObject:[NSString stringWithCString:datatype encoding:NSUTF8StringEncoding] forKey:kRBFormKeyDatatype];
                if (strcmp(datatype, "Btn") == 0) {
                    [fieldDict setObject:[NSString stringWithCString:btnValue encoding:NSUTF8StringEncoding] forKey:kRBFormKeyLabel];
                    [fieldDict setObject:[NSString stringWithCString:btnType encoding:NSUTF8StringEncoding] forKey:kRBFormKeySubtype];
                    [fieldDict setObject:(__bridge NSString*)nameString forKey:kRBFormKeyButtonGroup];
                    if (btnValue) {
                        [fieldDict setObject:[NSString stringWithCString:btnValue encoding:NSUTF8StringEncoding] forKey:kRBFormKeyValue];
                    }
                }
                else {
                    [fieldDict setObject:(__bridge NSString*)nameString forKey:kRBFormKeyLabel];
                }
                [fieldDict setObject:kRBFormKeyMappingNone forKey:kRBFormKeyMapping];
                [fieldDict setObject:kRBFieldPositionRight forKey:kRBFormKeyPosition];
                [fieldDict setObject:[NSNumber numberWithFloat:1.0f] forKey:kRBFormKeySize];
                [fieldDict setObject:[NSNumber numberWithInt:0] forKey:kRBFormKeyColumn];
                [fieldDict setObject:[NSNumber numberWithInt:i] forKey:kRBFormKeyRow];
                [fieldDict setObject:[NSNumber numberWithInt:1] forKey:kRBFormKeyColumnSpan];
                [fieldDict setObject:[NSNumber numberWithInt:1] forKey:kRBFormKeyRowSpan];
                
                [pageArray addObject:fieldDict];
                
                CFRelease(nameString);
            }

            NSDictionary *subsectionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Section 1", kRBFormKeyDisplayName, fields, kRBFormKeyFields, nil];
            NSArray *subsectionArray = [NSArray arrayWithObject:subsectionDict];
            [pageDisplayDict setObject:subsectionArray forKey:kRBFormKeySubsections];
            
            [sectionsArray addObject:pageArray];
        }
    }
    
    return annotationDict;
}


@end
