//
//  RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RBFormStatusNew = 0,
    RBFormStatusPreSignature,
    RBFormStatusSigned,
    RBFormStatusCount,
    RBFormStatusUnknown = -1
} RBFormStatus;


NSString *RBFormStatusStringRepresentation(RBFormStatus formType);
RBFormStatus RBFormStatusForIndex(NSUInteger index);


@interface RBForm : NSObject 

+ (RBForm *)formWithID:(NSUInteger)formID name:(NSString *)name;
+ (NSArray *)allForms;

- (id)initWithID:(NSUInteger)formID name:(NSString *)name;

@property (nonatomic, readonly) NSUInteger formID;
@property (nonatomic, readonly) NSString *name;

@end