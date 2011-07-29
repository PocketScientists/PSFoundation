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
#import "RBClient.h"

@interface RBUIGenerator : NSObject

- (RBFormView *)viewWithForm:(RBForm *)form client:(RBClient *)client frame:(CGRect)frame;

@end
