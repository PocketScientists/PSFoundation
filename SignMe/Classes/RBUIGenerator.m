//
//  RBUIGenerator.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBUIGenerator.h"

@implementation RBUIGenerator

- (RBFormView *)viewFromForm:(RBForm *)form withFrame:(CGRect)frame {
    RBFormView *view = [[[RBFormView alloc] initWithFrame:frame] autorelease];
    
    return view;
}

@end
