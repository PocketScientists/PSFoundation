//
//  RBPDFWriter.m
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBPDFWriter.h"
#import <CoreText/CoreText.h>


@implementation RBPDFWriter

@synthesize font;
@synthesize textColor;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)init {
    if ((self = [super init])) {
        self.font = [UIFont systemFontOfSize:12];
        self.textColor = [UIColor blackColor];
    }
    
    return self;
}

- (void)dealloc {
    font = nil;
    textColor = nil;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PDF Writing
////////////////////////////////////////////////////////////////////////

- (void)writePDFDocument:(CGPDFDocumentRef)document withFormData:(NSDictionary *)formData toFile:(NSString *)path {       
    NSDictionary *fontMap = [NSDictionary dictionaryWithObjectsAndKeys:@"Helvetica", @"/Helv", 
                             @"Helvetica-Bold", @"/Helv,Bold",
                             @"Verdana", @"/Verdana", 
                             @"Verdana-Bold", @"/Verdana,Bold", nil];
    //Create the pdf context
    CGPDFPageRef page = CGPDFDocumentGetPage(document, 1); //Pages are numbered starting at 1
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CFMutableDataRef mutableData = CFDataCreateMutable(NULL, 0);
    
    CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData(mutableData);
    CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, &pageRect, NULL);
    
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(document);
    
    for (int pageIndex = 1; pageIndex <= numberOfPages; pageIndex++) {       
        //Draw the page onto the new context
        page = CGPDFDocumentGetPage(document, pageIndex);
        
        CGPDFContextBeginPage(pdfContext, NULL);
        CGContextDrawPDFPage(pdfContext, page);
        
        CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(page);
        
        // retrieve the annotations dictionary
        CGPDFArrayRef annots = NULL;
        CGPDFDictionaryGetArray(pageDict, "Annots", &annots);
        
        if (annots) {
            for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
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
                CGPDFArrayRef rectArr;
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
                        
                        CGPDFDictionaryGetArray(field, "Rect", &rectArr);
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
                    CGPDFDictionaryGetArray(field, "Rect", &rectArr);
                }
                else {
                    CGPDFDictionaryGetArray(field, "Rect", &rectArr);
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
                
                // retrieve font information
                CFStringRef fontName = (__bridge CFStringRef)self.font.fontName;
                CGFloat fontsize = self.font.pointSize;
                
                CGPDFStringRef fontspec;
                CFStringRef fontspecString = NULL;
                if (CGPDFDictionaryGetString(field, "DA", &fontspec)) {
                    fontspecString = CGPDFStringCopyTextString(fontspec);
                    NSLog(@"font: %@", fontspecString);
                    NSArray *ftComp = [(__bridge NSString *)fontspecString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    fontName = (__bridge CFStringRef)[fontMap objectForKey:[ftComp objectAtIndex:0]];
                    if (!fontName) {
                        fontName = (__bridge CFStringRef)self.font.fontName;
                    }
                    fontsize = [[ftComp objectAtIndex:1] floatValue];
                }
                
                // retrieve justification
                CGPDFInteger quadding = 0;
                CGPDFDictionaryGetInteger(field, "Q", &quadding);

                // write the form data
                NSString *text = [formData objectForKey:(NSString *)idString];
                if (strcmp(datatype, "Btn") == 0) {
                    text = [text boolValue] ? @"●" : @"○";
                }
                
                NSLog(@"used font: %@, %f", fontName, fontsize);
                if (text) {
                    // retrieve the field's rectangle
                    CGRect rect;
                    CGPDFArrayGetNumber(rectArr, 0, &rect.origin.x);
                    CGPDFArrayGetNumber(rectArr, 1, &rect.origin.y);
                    CGPDFArrayGetNumber(rectArr, 2, &rect.size.width);
                    CGPDFArrayGetNumber(rectArr, 3, &rect.size.height);
                    rect.size.width -= rect.origin.x;
                    rect.size.height -= rect.origin.y;
                    
                    CTFontRef ctFont = CTFontCreateWithName(fontName, fontsize, NULL);
                    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    (__bridge id)ctFont, (id)kCTFontAttributeName,
                                                    self.textColor.CGColor, (id)kCTForegroundColorAttributeName, nil];
                    
                    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDict];
                    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)aStr);
                    CGRect lineRect = CTLineGetImageBounds(line, pdfContext);
                    CGFloat x = rect.origin.x + 5;
                    if (quadding == 1) {
                        x += (rect.size.width - lineRect.size.width) / 2;
                    }
                    else if (quadding == 2) {
                        x += rect.size.width - lineRect.size.width;
                    }
                    CGContextSetTextPosition(pdfContext, x, rect.origin.y + (rect.size.height - lineRect.size.height)/2); 
                    CTLineDraw(line, pdfContext);
                    CFRelease(line);
                    CFRelease(ctFont);
                }
                
                if (fontspecString) {
                    CFRelease(fontspecString);
                }
                
                CFRelease(nameString);
            }
        }
        
        CGPDFContextEndPage(pdfContext);
    }
    
    CGContextRelease(pdfContext); //Release before writing data to disk.
    
    //Write to disk
    [(__bridge NSData *)mutableData writeToFile:path atomically:YES];
    
    //Clean up
    CGDataConsumerRelease(dataConsumer);
    CFRelease(mutableData);
}

@end
