//
//  UIControl+RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+RBForm.h"

@interface UIControl (RBForm)

@property (nonatomic, retain) NSString *formMappingName;
@property (nonatomic, readonly) NSString *formTextValue;
@property (nonatomic, readonly) NSString *formButtonGroupValue;
@property (nonatomic, retain) NSString *formSubtype;
@property (nonatomic, retain) NSArray *formButtonGroup;
@property (nonatomic, retain) NSString *formValidationRegEx;
@property (nonatomic, retain) NSString *formValidationMsg;
@property (nonatomic, retain) NSString *formTextFormat;
@property (nonatomic, retain) NSString *formCalculate;
@property (nonatomic, retain) NSMutableArray *formFieldObservers;
@property (nonatomic, retain) NSString *formTrueValue;
@property (nonatomic, retain) NSString *formFalseValue;

+ (UIControl *)controlWithID:(NSString *)formID datatype:(NSString *)datatype size:(CGSize)size subtype:(NSString *)subtype;

- (void)configureControlUsingValue:(id)value;
- (void)unregisterObservers;

- (void)btnClicked:(id)sender;

@end
