//
//  PSBaseViewController.m
//  PSAppTemplate
//
//  Created by Tretter Matthias on 25.06.11.
//  Copyright 2011 @myell0w. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSIncludes.h"

@implementation PSBaseViewController

@synthesize backgroundImageView = backgroundImageView_;

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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[PSReachability sharedPSReachability] shutdownReachabilityFor:self];
    
    self.backgroundImageView = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation
////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
