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

#define kFormsCarouselItemWidth     230.f
#define kClientsCarouselItemWidth   170.f
#define kCarouselItemWrapFactor     1.4f

@interface RBCarouselView : UIControl

@property (nonatomic, assign) BOOL isAddClientView;

+ (RBCarouselView *)carouselViewWithWidth:(CGFloat)width;

- (void)setText:(NSString *)text;
- (void)setFromFormStatus:(RBFormStatus)formStatus count:(NSUInteger)count;
- (void)setFromForm:(RBForm *)form;
- (void)setFromClient:(RBClient *)client;

@end
