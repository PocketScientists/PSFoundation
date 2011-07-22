//
//  NGPDFManager.h
//  NOUSGuide
//
//  Created by Jürgen Falb on 21.07.11.
//  Copyright 2011 NOUSGuide Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


@interface NGPDFManager : NSObject 

@property(nonatomic, retain) NSString *password;
@property(nonatomic, retain) UIFont *font;
@property(nonatomic, retain) UIColor *textColor;

- (CGPDFDocumentRef)openDocument:(NSURL *)url;
- (void)writePDFDocument:(CGPDFDocumentRef)document withFormData:(NSDictionary *)formData toFile:(NSString *)path;

@end
