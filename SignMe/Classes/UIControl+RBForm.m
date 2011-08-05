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
#import "DCRoundSwitch.h"
#import "RBTextField.h"

#define kRBSwitchOnTextValue        @"X"
#define kRBSwitchOffTextValue       @""


static char formMappingKey;
static char formIDKey;
static char formSectionKey;

@implementation UIControl (UIControl_RBForm)

+ (UIControl *)controlWithID:(NSString *)formID datatype:(NSString *)datatype size:(CGSize)size {
    UIControl *control;
    
    if ([datatype isEqualToString:kRBFormDataTypeCheckbox]) {
        control = [[[DCRoundSwitch alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(95.f,30.f)}] autorelease];
    } else {
        control = [[[RBTextField alloc] initWithFrame:(CGRect){CGPointZero, size}] autorelease];
    }
    
    control.tag = kRBFormControlTag;
    control.formID = formID;
    
    return control;
}

- (void)configureControlUsingValue:(NSString *)value {
    if ([self isKindOfClass:[DCRoundSwitch class]]) {
        DCRoundSwitch *switchSelf = (DCRoundSwitch *)self;
        
        switchSelf.on = [value isEqualToString:kRBSwitchOnTextValue] ? YES : NO;
        switchSelf.onTintColor = kRBColorDetail2;
    } else if ([self isKindOfClass:[UITextField class]]) {
        UITextField *textFieldSelf = (UITextField *)self;
        
        textFieldSelf.borderStyle = UITextBorderStyleBezel;
        textFieldSelf.backgroundColor = [UIColor whiteColor];
        textFieldSelf.font = [UIFont fontWithName:kRBFontName size:18];
        textFieldSelf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textFieldSelf.clearButtonMode = UITextFieldViewModeWhileEditing;
        textFieldSelf.text = value;
    }
    
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)setFormMappingName:(NSString *)mappingName {
    [self associateValue:mappingName withKey:&formMappingKey];
}

- (NSString *)formMappingName {
    return [self associatedValueForKey:&formMappingKey];
}

- (void)setFormID:(NSString *)formID {
    [self associateValue:formID withKey:&formIDKey];
}

- (NSString *)formID {
    return [self associatedValueForKey:&formIDKey];
}

- (void)setFormSection:(NSInteger)formSection {
    [self associateValue:$I(formSection) withKey:&formSectionKey];
}

- (NSInteger)formSection {
    return [[self associatedValueForKey:&formSectionKey] intValue];
}

- (NSString *)formTextValue {
    // Switches have value 'X' for checkbox
    if ([self isKindOfClass:[DCRoundSwitch class]]) {
        DCRoundSwitch *control = (DCRoundSwitch *)self;
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
