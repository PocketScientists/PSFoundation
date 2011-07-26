//
//  UIControl+RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (UIControl_RBForm)

@property (nonatomic, readonly) NSString *formTextValue;

+ (UIControl *)controlForDatatype:(NSString *)datatype size:(CGSize)size;

- (void)configureControlUsingValue:(NSString *)value;
@end
