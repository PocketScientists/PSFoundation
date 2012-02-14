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

@property (nonatomic, strong) UIScrollView *innerScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (unsafe_unretained, nonatomic, readonly) NSArray *formControls;
@property (unsafe_unretained, nonatomic, readonly) NSArray *recipients;
@property (unsafe_unretained, nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) BOOL obeyRoutingOrder;
@property (strong, nonatomic, readonly) NSMutableDictionary *formLayoutData;
@property (unsafe_unretained, nonatomic, readonly) RBForm *form;

- (id)initWithFrame:(CGRect)frame form:(RBForm *)form;

- (void)setInnerScrollViewSize:(CGSize)size;

- (void)validate;
- (void)updateRecipientsView;
- (void)forceLayout;
- (void)setupResponderChain;

@end
