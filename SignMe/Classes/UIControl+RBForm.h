//
//  UIControl+RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (UIControl_RBForm)

@property (nonatomic, retain) NSString *formID;
@property (nonatomic, assign) NSInteger formSection;
@property (nonatomic, readonly) NSString *formTextValue;

+ (UIControl *)controlWithID:(NSString *)formID datatype:(NSString *)datatype size:(CGSize)size;

- (void)configureControlUsingValue:(NSString *)value;
@end
