//
//  NGPDFManager.h
//  NOUSGuide
//
//  Created by Jürgen Falb on 21.07.11.
//  Copyright 2011 NOUSGuide Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface RBPDFManager : NSObject 

@property(nonatomic, retain) NSString *password;

- (CGPDFDocumentRef)openDocument:(NSURL *)url;
- (NSDictionary *)annotsForPDFDocument:(CGPDFDocumentRef)document;

@end
