//
//  UIControl+RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (UIControl_RBForm)

@property (nonatomic, retain) NSString *formMappingName;
@property (nonatomic, retain) NSString *formID;
@property (nonatomic, assign) NSInteger formSection;
@property (nonatomic, assign) NSInteger formSubsection;
@property (nonatomic, readonly) NSString *formTextValue;
@property (nonatomic, retain) NSString *formSubtype;

+ (UIControl *)controlWithID:(NSString *)formID datatype:(NSString *)datatype size:(CGSize)size subtype:(NSString *)subtype;

- (void)configureControlUsingValue:(NSString *)value;

- (void)btnClicked:(id)sender;

@end
