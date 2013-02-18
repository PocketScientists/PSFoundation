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
#import "RBUserAuthentication.h"
#import <AddressBook/ABAddressBook.h>
#import "ABAddressBook.h"


@interface AppDelegate : NSObject <UIApplicationDelegate,RBUserAuthenticationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) RBHomeViewController *homeViewController;
@property (nonatomic, strong) RBUserAuthentication *userAuthentication;

- (void)showLoadingMessage:(NSString *)message;
- (void)showSuccessMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message;
- (void)updateToSuccessMessage:(NSString *)message;
- (void)updateToErrorMessage:(NSString *)message;
- (void)hideMessage;

- (void)syncOfflineCreatedOutlets;
- (void)userAuthenticated;
- (void)setTimerTo:(NSTimeInterval)intervall;

@end

