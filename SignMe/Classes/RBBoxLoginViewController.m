//
//  RBBoxLoginViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBBoxLoginViewController.h"
#import "PSIncludes.h"

@interface RBBoxLoginViewController ()

- (void)handleDonePress:(id)sender;
- (void)handleRefreshPress:(id)sender;

@end

@implementation RBBoxLoginViewController

@synthesize webView = webView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)loadView {
    self.webView = [[UIWebView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleDonePress:)];
    // self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(handleRefreshPress:)] autorelease];
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
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)handleRefreshPress:(id)sender {
    [self.webView reload];
}

@end
