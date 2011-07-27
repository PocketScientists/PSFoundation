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

#define kCarouselViewFrame  CGRectMake(0,0,170,120)
#define kCarouselItemWidth  (CGRectGetWidth(kCarouselViewFrame) * 1.4)

@interface RBCarouselView : UIControl

@property (nonatomic, assign) BOOL isAddClientView;

+ (RBCarouselView *)carouselView;

- (void)setText:(NSString *)text;
- (void)setFromFormStatus:(RBFormStatus)formStatus count:(NSUInteger)count;
- (void)setFromForm:(RBForm *)form;
- (void)setFromClient:(RBClient *)client;

@end
