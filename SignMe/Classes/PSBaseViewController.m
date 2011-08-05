//
//  PSBaseViewController.m
//  PSAppTemplate
//
//  Created by Tretter Matthias on 25.06.11.
//  Copyright 2011 @myell0w. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSIncludes.h"
#import "ATMHud.h"

#define kRBLogoCenter                   CGPointMake(100,75)
#define kRBLogoSignMeTopLeft            CGPointMake(180,82)
#define kRBLoadingAnimationDuration     0.4f
#define kRBHUDDuration                  1.5f

void dispatch_sync_on_main_queue(dispatch_block_t block);

inline void dispatch_sync_on_main_queue(dispatch_block_t block) {
    if (dispatch_get_current_queue() == dispatch_get_main_queue()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@interface PSBaseViewController ()

@property (nonatomic, retain) ATMHud *hud;

- (void)showHUDWithCaption:(NSString *)caption image:(UIImage *)image interactionEnabled:(BOOL)interactionEnabled;
- (void)showHUDWithCaption:(NSString *)caption image:(UIImage *)image hideAfterDuration:(NSTimeInterval)duration;
- (void)hideHUD;

@end

@implementation PSBaseViewController

@synthesize backgroundImageView = backgroundImageView_;
@synthesize timeView = timeView_;
@synthesize fullLogoImageView = fullLogoImageView_;
@synthesize logoSignMe = logoSignMe_;
@synthesize hud = hud_;

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
    MCRelease(timeView_);
    MCRelease(fullLogoImageView_);
    MCRelease(logoSignMe_);
    MCRelease(hud_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PSReachability sharedPSReachability] setupReachabilityFor:self];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.backgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]] autorelease];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
    self.fullLogoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoFull"]] autorelease];
    self.fullLogoImageView.center = kRBLogoCenter;
    self.fullLogoImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.fullLogoImageView.contentMode = UIViewContentModeLeft;
    self.fullLogoImageView.clipsToBounds = YES;
    
    self.logoSignMe = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoSignMe"]] autorelease];
    self.logoSignMe.frame = (CGRect){kRBLogoSignMeTopLeft,self.logoSignMe.frame.size};
    
    [self.view addSubview:self.fullLogoImageView];
    [self.view insertSubview:self.logoSignMe aboveSubview:self.fullLogoImageView];
    
    self.timeView = [[[RBTimeView alloc] initWithFrame:CGRectMake(926, 30, 70, 82)] autorelease];
    [self.view addSubview:self.timeView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[PSReachability sharedPSReachability] shutdownReachabilityFor:self];
    
    self.backgroundImageView = nil;
    self.fullLogoImageView = nil;
    self.logoSignMe = nil;
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

- (void)showLoadingMessage:(NSString *)message {
    dispatch_sync_on_main_queue(^(void) {
        [self showHUDWithCaption:message image:nil interactionEnabled:NO];
    });
}

- (void)showSuccessMessage:(NSString *)message {
    dispatch_sync_on_main_queue(^(void) {
        [self showHUDWithCaption:message image:[UIImage imageNamed:@"19-check"] hideAfterDuration:kRBHUDDuration];
    });
}

- (void)showErrorMessage:(NSString *)message {
    dispatch_sync_on_main_queue(^(void) {
        [self showHUDWithCaption:message image:[UIImage imageNamed:@"11-x"] hideAfterDuration:kRBHUDDuration];
    });
}

- (void)hideMessage {
    dispatch_sync_on_main_queue(^(void) {
        [self hideHUD];
    });
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ATMHud
////////////////////////////////////////////////////////////////////////

- (void)showHUDWithCaption:(NSString *)caption image:(UIImage *)image interactionEnabled:(BOOL)interactionEnabled {
    CGSize hudSize = CGSizeMake(180, 111); // goldener Schnitt :)
    
    [self.hud hide];
    self.hud = [[[ATMHud alloc] init] autorelease];
    self.hud.view.center = CGPointMake(506.f,350.f);
    self.hud.allowSuperviewInteraction = interactionEnabled;
    self.hud.blockTouches = !interactionEnabled;
    self.hud.accessoryPosition = ATMHudAccessoryPositionTop;
    [self.hud setCaption:caption];
    [self.hud setFixedSize:hudSize]; 
    
    if (image) {
        [self.hud setImage:image];
    } else {
        [self.hud setActivity:YES];
        [self.hud setActivityStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    
    [self.view addSubview:self.hud.view];
    [self.hud show];
}

- (void)showHUDWithCaption:(NSString *)caption image:(UIImage *)image hideAfterDuration:(NSTimeInterval)duration {
    [self showHUDWithCaption:caption image:image interactionEnabled:YES];    
    [self.hud hideAfter:duration];
}

- (void)hideHUD {
    [self.hud hide];
    self.hud = nil;
}

@end
