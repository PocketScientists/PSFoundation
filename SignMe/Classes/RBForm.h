//
//  RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RBFormTypeNew = 0,
    RBFormTypePreSignature,
    RBFormTypeSigned,
    RBFormTypeCount,
    RBFormTypeUnknown = -1
} RBFormType;


NSString *RBFormTypeStringRepresentation(RBFormType formType);
RBFormType RBFormTypeForIndex(NSUInteger index);


@interface RBForm : NSObject 

+ (RBForm *)formWithID:(NSUInteger)formID name:(NSString *)name;

- (id)initWithID:(NSUInteger)formID name:(NSString *)name;

@property (nonatomic, readonly) NSUInteger formID;
@property (nonatomic, readonly) NSString *name;

@end