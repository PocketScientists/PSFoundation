//
//  RBFormView.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface RBFormView : TPKeyboardAvoidingScrollView <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *innerScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIButton *prevButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, readonly) NSArray *formControls;
@property (nonatomic, readonly) NSArray *recipients;

- (void)setInnerScrollViewSize:(CGSize)size;


@end
