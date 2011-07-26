//
//  RBPDFWriter.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBPDFManager.h"
#import <UIKit/UIKit.h>

@interface RBPDFWriter : RBPDFManager

@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) UIColor *textColor;

- (void)writePDFDocument:(CGPDFDocumentRef)document withFormData:(NSDictionary *)formData toFile:(NSString *)path;

@end
