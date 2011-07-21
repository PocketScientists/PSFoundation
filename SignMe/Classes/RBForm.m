//
//  RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBForm.h"
#import "PSIncludes.h"

NSString *RBFormTypeStringRepresentation(RBFormType formType) {
    switch (formType) {
        case RBFormTypeNew:
            return @"New";

        case RBFormTypePreSignature:
            return @"Pre-Signature";
            
        case RBFormTypeSigned:
            return @"Signed";
            
        case RBFormTypeCount:
            return @"";
            
        case RBFormTypeUnknown:
            return @"Unknown";
    }
    
    return @"";
}

RBFormType RBFormTypeForIndex(NSUInteger index) {
    if (index < RBFormTypeCount) {
        return (RBFormType)index;
    }
    
    return RBFormTypeUnknown;
}


@implementation RBForm

@synthesize formID = formID_;
@synthesize name = name_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
////////////////////////////////////////////////////////////////////////

+ (RBForm *)formWithID:(NSUInteger)formID name:(NSString *)name {
    return [[[RBForm alloc] initWithID:formID name:name] autorelease];
}

+ (NSArray *)forms {
    return XARRAY([RBForm formWithID:1 name:@"Partnership Agreement"],
                  [RBForm formWithID:2 name:@"W-9"],
                  [RBForm formWithID:3 name:@"Terms and Condition"],
                  [RBForm formWithID:4 name:@"POS Delivery"],
                  [RBForm formWithID:5 name:@"???"]);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithID:(NSUInteger)formID name:(NSString *)name {
    if ((self = [super init])) {
        formID_ = formID;
        name_ = [name copy];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(name_);
    
    [super dealloc];
}

@end