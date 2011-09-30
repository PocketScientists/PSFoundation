//
//  RBDocuSigningViewController.m
//  SignMe
//
//  Created by Jürgen Falb on 13.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RBDocuSigningViewController.h"
#import "PSIncludes.h"
#import "AppDelegate.h"


@interface RBDocuSigningViewController ()

- (void)handleDonePress:(id)sender;

@end



@implementation RBDocuSigningViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleDonePress:)] autorelease];
    // self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(handleRefreshPress:)] autorelease];
}

- (void)loadURL:(NSString *)urlString {
    [webView_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation
////////////////////////////////////////////////////////////////////////

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;//UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleDonePress:(id)sender {
    [MTApplicationDelegate.homeViewController dismissModalViewControllerAnimated:YES];
}

@end
