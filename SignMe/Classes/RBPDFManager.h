//
//  NGPDFManager.h
//  NOUSGuide
//
//  Created by Jürgen Falb on 21.07.11.
//  Copyright 2011 NOUSGuide Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define kPDFNoOffRadioButton    (1 << 14)
#define kPDFRadioButton         (1 << 15)
#define kPDFPushButton          (1 << 16)

void GetButtonStateName(const char *key, CGPDFObjectRef object, void *info);


@interface RBPDFManager : NSObject {
     NSString *password;
}

@property(nonatomic, retain) NSString *password;

- (CGPDFDocumentRef)newOpenDocument:(NSURL *)url;
- (NSMutableDictionary *)annotsForPDFDocument:(CGPDFDocumentRef)document;

@end
