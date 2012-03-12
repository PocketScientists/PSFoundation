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
#import "RBTextField.h"
#import "RBMultiValueTextField.h"

#define kRBSwitchOnTextValue        @"Y"
#define kRBSwitchOffTextValue       @""


static char formMappingKey;
static char formSubtypeKey;
static char formButtonGroupKey;
static char formValidationRegExKey;
static char formValidationMsgKey;
static char formTextFormatKey;
static char formCalculateKey;
static char formFieldObserversKey;
static char formTrueValueKey;
static char formFalseValueKey;
static char formShowZeroKey;

@implementation UIControl (RBForm)

+ (UIControl *)controlWithID:(NSString *)formID datatype:(NSString *)datatype size:(CGSize)size subtype:(NSString *)subtype repeatGroup:(NSString *)repeatGroup showRepeatButton:(BOOL)showRepeatButton {
    UIControl *control;
    
    if ([datatype isEqualToString:kRBFormDataTypeButton]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = (CGRect){CGPointZero, CGSizeMake(36.f,36.f)};
        [btn setImage:[UIImage imageNamed:@"CheckButton.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"CheckButtonSelected.png"] forState:UIControlStateSelected];
        [btn addTarget:btn action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        control = btn;
    } else if (!IsEmpty(repeatGroup)) {
        control = [[RBMultiValueTextField alloc] initWithFrame:(CGRect){CGPointZero, size}];
        control.formShowRepeatButton = showRepeatButton;
        control.formSubtype = subtype;
    }
    else {
        control = [[RBTextField alloc] initWithFrame:(CGRect){CGPointZero, size}];
        ((RBTextField *)control).subtype = subtype;
    }
    
    control.tag = kRBFormControlTag;
    control.formID = formID;
    control.formSubtype = subtype;
    
    return control;
}

- (void)configureControlUsingValue:(id)value {
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)self;
        btn.selected = value != nil && ([value isEqual:self.formTrueValue] || [value boolValue]);
    } else if ([self isKindOfClass:[RBMultiValueTextField class]]) {
        RBMultiValueTextField *textFieldSelf = (RBMultiValueTextField *)self;
        if (IsEmpty(value)) value = [NSArray arrayWithObjects:@"", nil];
        textFieldSelf.values = value;
    } else if ([self isKindOfClass:[UITextField class]]) {
        UITextField *textFieldSelf = (UITextField *)self;
        
        textFieldSelf.borderStyle = UITextBorderStyleBezel;
        textFieldSelf.backgroundColor = [UIColor whiteColor];
        textFieldSelf.font = [UIFont fontWithName:kRBFontName size:18];
        textFieldSelf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textFieldSelf.clearButtonMode = UITextFieldViewModeWhileEditing;
        if (value && [value length] > 0 && textFieldSelf.formTextFormat) {
            NSRange r = [textFieldSelf.formTextFormat rangeOfString:@"%@"];
            if (r.location != NSNotFound) {
                NSString *prefix = [textFieldSelf.formTextFormat substringToIndex:r.location];
                NSString *suffix = [textFieldSelf.formTextFormat substringFromIndex:r.location + r.length];
                prefix = [prefix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
                suffix = [suffix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
                if (([prefix length] == 0 || [value hasPrefix:prefix]) && ([suffix length] == 0 || [value hasSuffix:suffix])) {
                    textFieldSelf.text = value;
                }
                else {
                    textFieldSelf.text = [NSString stringWithFormat:textFieldSelf.formTextFormat, value];
                }
            }
            else {
                textFieldSelf.text = [NSString stringWithFormat:textFieldSelf.formTextFormat, value];
            }
        }
        else {
            textFieldSelf.text = value;
        }
    }
    
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)setFormMappingName:(NSString *)mappingName {
    [self associateValue:mappingName withKey:&formMappingKey];
}

- (NSString *)formMappingName {
    return [self associatedValueForKey:&formMappingKey];
}

- (void)setFormSubtype:(NSString *)formSubtype {
    [self associateValue:formSubtype withKey:&formSubtypeKey];
}

- (NSString *)formSubtype {
    return [self associatedValueForKey:&formSubtypeKey];
}

- (void)setFormButtonGroup:(NSArray *)formButtonGroup {
    [self associateValue:formButtonGroup withKey:&formButtonGroupKey];
}

- (NSArray *)formButtonGroup {
    return [self associatedValueForKey:&formButtonGroupKey];
}

- (void)setFormValidationRegEx:(NSString *)formValidationRegEx {
    [self associateValue:formValidationRegEx withKey:&formValidationRegExKey];
}

- (NSString *)formValidationRegEx {
    return [self associatedValueForKey:&formValidationRegExKey];
}

- (void)setFormValidationMsg:(NSString *)formValidationMsg {
    [self associateValue:formValidationMsg withKey:&formValidationMsgKey];
}

- (NSString *)formValidationMsg {
    return [self associatedValueForKey:&formValidationMsgKey];
}

- (void)setFormTextFormat:(NSString *)formTextFormat {
    [self associateValue:formTextFormat withKey:&formTextFormatKey];
}

- (NSString *)formTextFormat {
    return [self associatedValueForKey:&formTextFormatKey];
}

- (void)setFormCalculate:(NSString *)formCalculate {
    [self associateValue:formCalculate withKey:&formCalculateKey];
}

- (NSString *)formCalculate {
    return [self associatedValueForKey:&formCalculateKey];
}

- (void)setFormFieldObservers:(NSMutableArray *)formFieldObservers {
    [self associateValue:formFieldObservers withKey:&formFieldObserversKey];
}

- (NSMutableArray *)formFieldObservers {
    return [self associatedValueForKey:&formFieldObserversKey];
}

- (void)setFormTrueValue:(NSString *)formTrueValue {
    [self associateValue:formTrueValue withKey:&formTrueValueKey];
}

- (NSString *)formTrueValue {
    return [self associatedValueForKey:&formTrueValueKey];
}

- (void)setFormFalseValue:(NSString *)formFalseValue {
    [self associateValue:formFalseValue withKey:&formFalseValueKey];
}

- (NSString *)formFalseValue {
    return [self associatedValueForKey:&formFalseValueKey];
}

- (void)setFormShowZero:(BOOL)formShowZero {
    [self associateValue:[NSNumber numberWithBool:formShowZero] withKey:&formShowZeroKey];
}

- (BOOL)formShowZero {
    return [[self associatedValueForKey:&formShowZeroKey] boolValue];
}

- (id)formTextValue {
    // Switches have value 'X' for checkbox
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *control = (UIButton *)self;
        if (control.selected) {
            return self.formTrueValue ? self.formTrueValue : kRBSwitchOnTextValue;
        }
        else {
            return self.formFalseValue ? self.formFalseValue : kRBSwitchOffTextValue;
        }
    }
    
    if ([self isKindOfClass:[RBMultiValueTextField class]]) {
        return ((RBMultiValueTextField *)self).values;
    }
    
    // other controls that can store a text
    if ([self respondsToSelector:@selector(text)]) {
        return [self performSelector:@selector(text)];
    }
    
    // nothing found, just return empty string
    DDLogWarn(@"Didn't find selector to return value for %@", NSStringFromClass([self class]));
    return @"";
}

- (NSString *)formButtonGroupValue {
    if ([self isKindOfClass:[UIButton class]] && [self.formSubtype isEqualToString:@"radio"]) {
        for (UIControl *control in self.formButtonGroup) {
            if (control.selected) {
                return control.formTextValue;
            }
        }
    }
    return @"";
}

- (void)btnClicked:(id)sender 
{
    if ([self.formSubtype isEqualToString:@"radio"]) {
        for (UIControl *control in self.formButtonGroup) {
            control.selected = NO;
        }
        self.selected = YES;
    }
    else {
        self.selected = !self.selected;
    }
}

- (void)unregisterObservers {
    for (id observer in self.formFieldObservers) {
        if ([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[RBMultiValueTextField class]]) {
            [self removeObserver:observer forKeyPath:@"text"];
        }
        else {
            [self removeObserver:observer forKeyPath:@"selected"];
        }
    }
    self.formFieldObservers = nil;
}

@end
