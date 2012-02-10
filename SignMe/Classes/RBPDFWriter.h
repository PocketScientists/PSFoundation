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

@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;

- (void)writePDFDocument:(CGPDFDocumentRef)document withFormData:(NSDictionary *)formData toFile:(NSString *)path;

@end
