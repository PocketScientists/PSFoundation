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
#import "RBDocuSignService.h"


@interface RBDocuSigningViewController ()

- (void)handleDonePress:(id)sender;

@property (nonatomic, strong) NSString *urlString;

@end



@implementation RBDocuSigningViewController

@synthesize webView = webView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithURL:(NSString *)urlString {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _urlString = [urlString copy];
    }
    return  self;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleDonePress:)];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    NSLog(@"view did load");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [webView_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
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
    if ([request.URL.query containsString:@"showdoc=true"]) {
        NSLog(@"return NO");
        return NO;
    }
    if ([request.URL.host isEqualToString:@"localhost"]) {
        [self dismissModalViewControllerAnimated:YES];
        NSString *p = request.URL.pathComponents.count > 1 ? [request.URL.pathComponents objectAtIndex:1] : nil;
        if ([p isEqualToString:@"signing_complete"]) {
            [MTApplicationDelegate showSuccessMessage:@"The document has been signed successfully."];
            [RBDocuSignService updateStatusOfDocuments];
        }
        else if ([p isEqualToString:@"viewing_complete"]) {
            [MTApplicationDelegate showSuccessMessage:@"The document has been viewed."];            
        }
        else if ([p isEqualToString:@"cancel"]) {
            [MTApplicationDelegate showErrorMessage:@"Signing of the document has been canceled."];            
        }
        else if ([p isEqualToString:@"decline"]) {
            [MTApplicationDelegate showErrorMessage:@"Signing of the document has been declined."];            
            [RBDocuSignService updateStatusOfDocuments];
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
    NSLog(@"Start loading");
    return YES;
}


@end
