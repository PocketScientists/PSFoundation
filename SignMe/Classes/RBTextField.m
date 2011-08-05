//
//  RBTextField.m
//  SignMe
//
//  Created by Tretter Matthias on 05.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBTextField.h"

@implementation RBTextField

@synthesize nextField = nextField_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBTextField
////////////////////////////////////////////////////////////////////////

- (void)setNextField:(UITextField *)nextField {
    nextField_ = nextField;
    
    if (nextField_ != nil) {
        self.returnKeyType = UIReturnKeyNext;
    }
}

@end
