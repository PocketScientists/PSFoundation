//
//  NGPDFManager.m
//  NOUSGuide
//
//  Created by Jürgen Falb on 21.07.11.
//  Copyright 2011 NOUSGuide Inc. All rights reserved.
//

#import "NGPDFManager.h"
#import <CoreText/CoreText.h>


@implementation NGPDFManager

@synthesize password;
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
    [password release], password = nil;
    [font release], font = nil;
    [textColor release], textColor = nil;
    
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


- (void)writePDFDocument:(CGPDFDocumentRef)document withFormData:(NSDictionary *)formData toFile:(NSString *)path {       
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
        CGPDFArrayRef annots;
        CGPDFDictionaryGetArray(pageDict, "Annots", &annots);
        
        if (annots) {
            for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
                // retrieve a field from the annotations
                CGPDFDictionaryRef field;
                CGPDFArrayGetDictionary(annots, i, &field);
                
                // retrieve the field name
                CGPDFStringRef name;
                CGPDFDictionaryGetString(field, "T", &name);
                CFStringRef nameString = CGPDFStringCopyTextString(name);
                NSLog(@"field %d name: %@", i, nameString);
                
                // write the form data
                NSString *text = [formData objectForKey:(NSString *)nameString];
               
                if (text) {
                    // retrieve the field's rectangle
                    CGPDFArrayRef rectArr;
                    CGPDFDictionaryGetArray(field, "Rect", &rectArr);
                    CGRect rect;
                    CGPDFArrayGetNumber(rectArr, 0, &rect.origin.x);
                    CGPDFArrayGetNumber(rectArr, 1, &rect.origin.y);
                    CGPDFArrayGetNumber(rectArr, 2, &rect.size.width);
                    CGPDFArrayGetNumber(rectArr, 3, &rect.size.height);
                    NSLog(@"%f, %f", rect.origin.x, rect.origin.y);
                    
                    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
                    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    (id)ctFont, (id)kCTFontAttributeName,
                                                    self.textColor.CGColor, (id)kCTForegroundColorAttributeName, nil];
                    
                    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDict];
                    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)aStr);
                    CGContextSetTextPosition(pdfContext, rect.origin.x, rect.origin.y); 
                    CTLineDraw(line, pdfContext);
                    CFRelease(line);
                    [aStr release];
                    CFRelease(ctFont);
                }
                
                CFRelease(nameString);
            }
        }
        
        CGPDFContextEndPage(pdfContext);
    }
    
    CGContextRelease(pdfContext); //Release before writing data to disk.
    
    //Write to disk
    [(NSData *)mutableData writeToFile:path atomically:YES];
    
    //Clean up
    CGDataConsumerRelease(dataConsumer);
    CFRelease(mutableData);
}


@end
