//
//  UILabel+RBForm.m
//  SignMe
//
//  Created by Jürgen Falb on 12.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabel+RBForm.h"
#import "PSIncludes.h"

static char formIDKey;
static char formSectionKey;
static char formSubsectionKey;

@implementation UILabel (RBForm)

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

- (void)setFormSubsection:(NSInteger)formSubsection {
    [self associateValue:$I(formSubsection) withKey:&formSubsectionKey];
}

- (NSInteger)formSubsection {
    return [[self associatedValueForKey:&formSubsectionKey] intValue];
}

@end
