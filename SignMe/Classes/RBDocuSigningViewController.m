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
    self.webView.delegate = self;
    
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


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.host isEqualToString:@"localhost"]) {
        [self dismissModalViewControllerAnimated:YES];
        NSString *p = request.URL.pathComponents.count > 1 ? [request.URL.pathComponents objectAtIndex:1] : nil;
        if ([p isEqualToString:@"signing_complete"]) {
            [MTApplicationDelegate showSuccessMessage:@"The document has been signed successfully."];
        }
        else if ([p isEqualToString:@"viewing_complete"]) {
            [MTApplicationDelegate showSuccessMessage:@"The document has been viewed."];            
        }
        else if ([p isEqualToString:@"cancel"]) {
            [MTApplicationDelegate showErrorMessage:@"Signing of the document has been canceled."];            
        }
        else if ([p isEqualToString:@"decline"]) {
            [MTApplicationDelegate showErrorMessage:@"Signing of the document has been declined."];            
        }
        else if ([p isEqualToString:@"timeout"]) {
            [MTApplicationDelegate showErrorMessage:@"Signing of the document has been timed out. Please sign within 5 minutes."];            
        }
        else if ([p isEqualToString:@"ttl-expired"]) {
            [MTApplicationDelegate showErrorMessage:@"Signing of the document has been timed out."];            
        }
        else {
            [MTApplicationDelegate showErrorMessage:@"An exception while signing the document has occured. Please contact your IT support."];            
        }
        return NO;
    }
    return YES;
}


@end
