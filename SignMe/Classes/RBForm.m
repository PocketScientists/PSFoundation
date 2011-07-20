//
//  RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBForm.h"

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