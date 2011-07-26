//
//  UIControl+RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 26.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "UIControl+RBForm.h"
#import "RBForm.h"
#import "PSIncludes.h"

#define kRBSwitchOnTextValue        @"X"
#define kRBSwitchOffTextValue       @""


@implementation UIControl (UIControl_RBForm)

+ (UIControl *)controlForDatatype:(NSString *)datatype size:(CGSize)size {
    UIControl *control;
    
    if ([datatype isEqualToString:kRBFormDataTypeCheckbox]) {
        control = [[[UISwitch alloc] initWithFrame:(CGRect){CGPointZero, size}] autorelease];
    } else {
        control = [[[UITextField alloc] initWithFrame:(CGRect){CGPointZero, size}] autorelease];
    }
    
    return control;
}

- (void)configureControlUsingValue:(NSString *)value {
    if ([self isKindOfClass:[UISwitch class]]) {
        UISwitch *switchSelf = (UISwitch *)self;
        
        switchSelf.on = [value isEqualToString:kRBSwitchOnTextValue] ? YES : NO;
    } else if ([self isKindOfClass:[UITextField class]]) {
        UITextField *textFieldSelf = (UITextField *)self;
        
        textFieldSelf.borderStyle = UITextBorderStyleRoundedRect;
        textFieldSelf.text = value;
    }
    
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (NSString *)formTextValue {
    // Switches have value 'X' for checkbox
    if ([self isKindOfClass:[UISwitch class]]) {
        UISwitch *control = (UISwitch *)self;
        return control.on ? kRBSwitchOnTextValue : kRBSwitchOffTextValue;
    }
    
    // other controls that can store a text
    if ([self respondsToSelector:@selector(text)]) {
        return [self performSelector:@selector(text)];
    }
    
    // nothing found, just return empty string
    DDLogWarn(@"Didn't find selector to return value for %@", NSStringFromClass([self class]));
    return @"";
}

@end
