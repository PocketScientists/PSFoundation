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
static char formSubsectionKey;
static char formSubtypeKey;

@implementation UIControl (UIControl_RBForm)

+ (UIControl *)controlWithID:(NSString *)formID datatype:(NSString *)datatype size:(CGSize)size subtype:(NSString *)subtype {
    UIControl *control;
    
    if ([datatype isEqualToString:kRBFormDataTypeCheckbox]) {
//        control = [[[DCRoundSwitch alloc] initWithFrame:(CGRect){CGPointZero, CGSizeMake(95.f,30.f)}] autorelease];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = (CGRect){CGPointZero, CGSizeMake(36.f,36.f)};
        [btn setImage:[UIImage imageNamed:@"CheckButton.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"CheckButtonSelected.png"] forState:UIControlStateSelected];
        [btn addTarget:btn action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        control = btn;
    } else {
        control = [[[RBTextField alloc] initWithFrame:(CGRect){CGPointZero, size}] autorelease];
        ((RBTextField *)control).subtype = subtype;
    }
    
    control.tag = kRBFormControlTag;
    control.formID = formID;
    control.formSubtype = subtype;
    
    return control;
}

- (void)configureControlUsingValue:(NSString *)value {
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)self;
        btn.selected = [value isEqualToString:kRBSwitchOnTextValue];
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

- (void)setFormSubtype:(NSString *)formSubtype {
    [self associateValue:formSubtype withKey:&formSubtypeKey];
}

- (NSString *)formSubtype {
    return [self associatedValueForKey:&formSubtypeKey];
}

- (void)setFormSection:(NSInteger)formSection {
    [self associateValue:$I(formSection) withKey:&formSectionKey];
}

- (NSInteger)formSection {
    return [[self associatedValueForKey:&formSectionKey] intValue];
}

- (void)setFormSubsection:(NSInteger)formSubsection {
    [self associateValue:$I(formSubsection) withKey:&formSubsectionKey];
}

- (NSInteger)formSubsection {
    return [[self associatedValueForKey:&formSubsectionKey] intValue];
}

- (NSString *)formTextValue {
    // Switches have value 'X' for checkbox
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *control = (UIButton *)self;
        return control.selected ? kRBSwitchOnTextValue : kRBSwitchOffTextValue;
    }
    
    // other controls that can store a text
    if ([self respondsToSelector:@selector(text)]) {
        return [self performSelector:@selector(text)];
    }
    
    // nothing found, just return empty string
    DDLogWarn(@"Didn't find selector to return value for %@", NSStringFromClass([self class]));
    return @"";
}

- (void)btnClicked:(id)sender 
{
    UIButton *btn = (UIButton *)self;
    btn.selected = !btn.selected;
}

@end
