//
//  RBUIGenerator.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBFormView.h"
#import "RBForm.h"

@interface RBUIGenerator : NSObject

- (RBFormView *)viewFromForm:(RBForm *)form withFrame:(CGRect)frame;

@end
