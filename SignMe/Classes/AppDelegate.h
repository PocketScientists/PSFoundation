//
//  PSAppTemplateAppDelegate.h
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//  Template by Peter Steinberger
//

#import "PSDefines.h"
#import "PSWindow.h"
#import "RBHomeViewController.h"


@interface AppDelegate : NSObject <UIApplicationDelegate> 

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) RBHomeViewController *homeViewController;

- (void)showLoadingMessage:(NSString *)message;
- (void)showSuccessMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message;
- (void)hideMessage;

@end

