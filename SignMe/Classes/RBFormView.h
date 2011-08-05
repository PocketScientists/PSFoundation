//
//  RBFormView.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBKeyboardAvoidingScrollView.h"

@interface RBFormView : RBKeyboardAvoidingScrollView <UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UIScrollView *innerScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIButton *prevButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, readonly) NSArray *formControls;
@property (nonatomic, readonly) NSArray *recipients;
@property (nonatomic, readonly) NSString *subject;

- (void)setInnerScrollViewSize:(CGSize)size;


@end
