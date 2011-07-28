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

#define kRBFormsCarouselItemWidth           230.f
#define kRBClientsCarouselItemWidth         170.f
#define kRBDetailCarouselItemWidth          190.f
#define kRBCarouselItemWidthScaleFactor     1.4f

@interface RBCarouselView : UIControl

@property (nonatomic, readonly, retain) id attachedObject;
@property (nonatomic, assign) BOOL isAddClientView;

+ (RBCarouselView *)carouselViewWithWidth:(CGFloat)width;

- (void)setText:(NSString *)text;
- (void)setFromFormStatus:(RBFormStatus)formStatus count:(NSUInteger)count;
- (void)setFromForm:(RBForm *)form;
- (void)setFromClient:(RBClient *)client;

@end
