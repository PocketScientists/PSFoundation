//
//  RBFormView.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBFormView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *innerScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIButton *prevButton;
@property (nonatomic, retain) UIButton *nextButton;

- (void)setInnerScrollViewSize:(CGSize)size;

@end
