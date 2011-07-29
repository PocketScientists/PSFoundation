//
//  PSBaseViewController.m
//  PSAppTemplate
//
//  Created by Tretter Matthias on 25.06.11.
//  Copyright 2011 @myell0w. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSIncludes.h"

#define kRBLogoCenter                   CGPointMake(100,100)
#define kRBLoadingAnimationDuration     0.4f

@implementation PSBaseViewController

@synthesize backgroundImageView = backgroundImageView_;
@synthesize fullLogoImageView = fullLogoImageView_;
@synthesize emptyLogoImageView = emptyLogoImageView_;
@synthesize activityView = activityView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(backgroundImageView_);
    MCRelease(fullLogoImageView_);
    MCRelease(emptyLogoImageView_);
    MCRelease(activityView_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PSReachability sharedPSReachability] setupReachabilityFor:self];
    
    self.backgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]] autorelease];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
    self.emptyLogoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoEmpty"]] autorelease];
    self.emptyLogoImageView.center = kRBLogoCenter;
    self.emptyLogoImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.emptyLogoImageView.alpha = 0.f;
    self.emptyLogoImageView.contentMode = UIViewContentModeLeft;
    
    self.fullLogoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoFull"]] autorelease];
    self.fullLogoImageView.center = self.emptyLogoImageView.center;
    self.fullLogoImageView.autoresizingMask = self.emptyLogoImageView.autoresizingMask;
    self.fullLogoImageView.contentMode = UIViewContentModeLeft;
    self.fullLogoImageView.clipsToBounds = YES;
    
    [self.view insertSubview:self.emptyLogoImageView aboveSubview:self.backgroundImageView];
    [self.view insertSubview:self.fullLogoImageView aboveSubview:self.emptyLogoImageView];
    
    self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[PSReachability sharedPSReachability] shutdownReachabilityFor:self];
    
    self.backgroundImageView = nil;
    self.fullLogoImageView = nil;
    self.emptyLogoImageView = nil;
    self.activityView = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation
////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Loading
////////////////////////////////////////////////////////////////////////

- (void)showActivityViewAtPoint:(CGPoint)center {
    [self.view addSubview:self.activityView];
    self.activityView.alpha = 1.f;
    self.activityView.center = center;
    [self.activityView startAnimating];
}

- (void)hideActivityView {
    self.activityView.alpha = 0.f;
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
}

- (void)beginLoading {
    [UIView animateWithDuration:kRBLoadingAnimationDuration
                     animations:^(void) {
                         self.emptyLogoImageView.alpha = 1.f;
                         self.fullLogoImageView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         self.fullLogoImageView.frameWidth = 1.f;
                         self.fullLogoImageView.alpha = 1.f;
                         [self showActivityViewAtPoint:CGPointMake(self.emptyLogoImageView.center.x-2, self.emptyLogoImageView.frameTop + 29)];
                     }];
}

- (void)setLoadingProgress:(float)progress {
    if (progress <= 0.f) {
        progress = 0.f;
    } else if (progress >= 1.f) {
        progress = 1.f;
    }
    
    [UIView animateWithDuration:0.1f 
                          delay:0.f
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^(void) {
                         self.fullLogoImageView.frameWidth = self.emptyLogoImageView.frameWidth * progress;
                     } completion:nil];
}

- (void)finishLoading {
    [UIView animateWithDuration:kRBLoadingAnimationDuration
                     animations:^(void) {
                         self.fullLogoImageView.frameWidth = self.emptyLogoImageView.frameWidth;
                     } completion:^(BOOL finished) {
                         self.emptyLogoImageView.alpha = 0.f;
                         [self hideActivityView];
                     }];
}

@end
