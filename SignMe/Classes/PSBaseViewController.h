//
//  PSBaseViewController.h
//  PSAppTemplate
//
//  Created by Tretter Matthias on 25.06.11.
//  Copyright 2011 @myell0w. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSFoundation.h"
#import "RBTimeView.h"
#import "ATMHudDelegate.h"

@interface PSBaseViewController : UIViewController <PSReachabilityAware, ATMHudDelegate> 

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) RBTimeView *timeView;

@property (nonatomic, retain) UIImageView *fullLogoImageView;
@property (nonatomic, retain) UIImageView *logoSignMe;

- (void)showLoadingMessage:(NSString *)message;
- (void)showSuccessMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message;
- (void)hideMessage;

- (UIView *)findFirstResponderBeneathView:(UIView *)view;

@end
