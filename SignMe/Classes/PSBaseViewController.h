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

@interface PSBaseViewController : UIViewController <PSReachabilityAware> 

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) RBTimeView *timeView;

@property (nonatomic, retain) UIImageView *fullLogoImageView;
@property (nonatomic, retain) UIImageView *emptyLogoImageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIImageView *logoSignMe;

- (void)beginLoadingShowingProgress:(BOOL)showingProgress;
- (void)setLoadingProgress:(float)progress;
- (void)finishLoading;

- (void)showActivityViewAtPoint:(CGPoint)center;
- (void)hideActivityView;

@end
