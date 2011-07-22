//
//  RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBForm.h"
#import "PSIncludes.h"

NSString *RBFormStatusStringRepresentation(RBFormStatus formType) {
    switch (formType) {
        case RBFormStatusNew:
            return @"New";

        case RBFormStatusPreSignature:
            return @"Pre-Signature";
            
        case RBFormStatusSigned:
            return @"Signed";
            
        case RBFormStatusCount:
            return @"";
            
        case RBFormStatusUnknown:
            return @"Unknown";
    }
    
    return @"";
}

RBFormStatus RBFormStatusForIndex(NSUInteger index) {
    if (index < RBFormStatusCount) {
        return (RBFormStatus)index;
    }
    
    return RBFormStatusUnknown;
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

+ (NSArray *)allForms {
    // TODO: Read from plist
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