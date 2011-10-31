//
//  RBKeyboardAvoidingScrollView.h
//  SignMe
//
//  Created by Tretter Matthias on 05.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBKeyboardAvoidingScrollView : UIScrollView

- (void)moveResponderIntoPlace:(UIView *)firstResponder;

@end
