//
//  RBBoxLoginViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBBoxLoginViewController.h"
#import "PSIncludes.h"

@implementation RBBoxLoginViewController

@synthesize webView = webView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(webView_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)loadView {
    self.webView = [[[UIWebView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds] autorelease];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    
    self.view = self.webView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation
////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
