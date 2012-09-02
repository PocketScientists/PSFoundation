//
//  UIView+RBForm.m
//  SignMe
//
//  Created by Jürgen Falb on 12.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+RBForm.h"
#import "PSIncludes.h"

static char formIDKey;
static char formDatatypeKey;
static char formSectionKey;
static char formSubsectionKey;
static char formPositionKey;
static char formColumnKey;
static char formRowKey;
static char formColumnSpanKey;
static char formRowSpanKey;
static char formSizeKey;
static char formAlignmentKey;
static char formRepeatGroupKey;
static char formShowRepeatButtonKey;
static char formRepeatFieldKey;


@implementation UIView (RBForm)

- (void)setFormID:(NSString *)formID {
    [self associateValue:formID withKey:&formIDKey];
}

- (NSString *)formID {
    return [self associatedValueForKey:&formIDKey];
}

- (void)setFormDatatype:(NSString *)formDatatype {
    [self associateValue:formDatatype withKey:&formDatatypeKey];
}

- (NSString *)formDatatype {
    return [self associatedValueForKey:&formDatatypeKey];
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

- (void)setFormPosition:(NSString *)formPosition {
    [self associateValue:formPosition withKey:&formPositionKey];
}

- (NSString *)formPosition {
    return [self associatedValueForKey:&formPositionKey];
}

- (void)setFormColumn:(NSInteger )formColumn {
    [self associateValue:$I(formColumn) withKey:&formColumnKey];
}

- (NSInteger)formColumn {
    return [[self associatedValueForKey:&formColumnKey] intValue];
}

- (void)setFormRow:(NSInteger )formRow {
    [self associateValue:$I(formRow) withKey:&formRowKey];
}

- (NSInteger)formRow {
    return [[self associatedValueForKey:&formRowKey] intValue];
}

- (void)setFormColumnSpan:(NSInteger )formColumnSpan {
    [self associateValue:$I(formColumnSpan) withKey:&formColumnSpanKey];
}

- (NSInteger)formColumnSpan {
    return [[self associatedValueForKey:&formColumnSpanKey] intValue];
}

- (void)setFormRowSpan:(NSInteger )formRowSpan {
    [self associateValue:$I(formRowSpan) withKey:&formRowSpanKey];
}

- (NSInteger)formRowSpan {
    return [[self associatedValueForKey:&formRowSpanKey] intValue];
}

- (void)setFormSize:(CGFloat)formSize {
    [self associateValue:$F(formSize) withKey:&formSizeKey];
}

- (CGFloat)formSize {
    return [[self associatedValueForKey:&formSizeKey] floatValue];
}

- (void)setFormAlignment:(NSString *)formAlignment {
    [self associateValue:formAlignment withKey:&formAlignmentKey];
}

- (NSString *)formAlignment {
    return [self associatedValueForKey:&formAlignmentKey];
}

- (void)setFormRepeatGroup:(NSArray *)formRepeatGroup {
    [self associateValue:formRepeatGroup withKey:&formRepeatGroupKey];
}

- (NSArray *)formRepeatGroup {
    return [self associatedValueForKey:&formRepeatGroupKey];
}

- (void)setFormShowRepeatButton:(BOOL)formShowRepeatButton {
    [self associateValue:$B(formShowRepeatButton) withKey:&formShowRepeatButtonKey];
}

- (BOOL)formShowRepeatButton {
    return [[self associatedValueForKey:&formShowRepeatButtonKey] boolValue];
}

- (void)setFormRepeatField:(NSString *)formRepeatField {
    [self associateValue:formRepeatField withKey:&formRepeatFieldKey];
}

- (NSString *)formRepeatField {
    return [self associatedValueForKey:&formRepeatFieldKey];
}

@end