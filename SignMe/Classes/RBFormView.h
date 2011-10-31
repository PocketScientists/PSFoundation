//
//  RBFormView.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBKeyboardAvoidingScrollView.h"
#import "RBForm.h"

@interface RBFormView : RBKeyboardAvoidingScrollView <UIScrollViewDelegate, UITextFieldDelegate> {
    @private
    CGSize lastFormSize;
}

@property (nonatomic, retain) UIScrollView *innerScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIButton *prevButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, readonly) NSArray *formControls;
@property (nonatomic, readonly) NSArray *recipients;
@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) BOOL obeyRoutingOrder;
@property (nonatomic, readonly) NSMutableDictionary *formLayoutData;
@property (nonatomic, readonly) RBForm *form;

- (id)initWithFrame:(CGRect)frame form:(RBForm *)form;

- (void)setInnerScrollViewSize:(CGSize)size;

@end
