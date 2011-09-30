//
//  RBDocuSigningViewController.h
//  SignMe
//
//  Created by Jürgen Falb on 13.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBDocuSigningViewController : UIViewController

@property (nonatomic, retain) UIWebView *webView;

- (void)loadURL:(NSString *)urlString;

@end
