//
//  RBCarouselView.h
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBForm.h"
#import "RBClient.h"

#define kCarouselViewFrame  CGRectMake(0,0,170,105)
#define kCarouselItemWidth  (CGRectGetWidth(kCarouselViewFrame) * 1.5)

@interface RBCarouselView : UIView

@property (nonatomic, retain) UILabel *textLabel;

+ (RBCarouselView *)carouselView;

- (void)setFromFormType:(RBFormType)formType;
- (void)setFromClient:(RBClient *)client;

@end
