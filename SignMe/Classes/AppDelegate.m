//
//  PSAppTemplateAppDelegate.m
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//  Template by Peter Steinberger
//

#import "AppDelegate.h"
#import "PSIncludes.h"
#import "RBHomeViewController.h"
#import "RBBoxLoginViewController.h"
#import "RBForm.h"

#ifdef kDCIntrospectEnabled
#import "DCIntrospect.h"
#endif


@interface AppDelegate ()

@property (nonatomic, retain) RBHomeViewController *homeViewController;

- (void)configureLogger;
- (void)appplicationPrepareForBackgroundOrTermination:(UIApplication *)application;
- (void)postFinishLaunch;
@end


@implementation AppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize homeViewController = homeViewController_;
@synthesize box = box_;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(window_);
    MCRelease(navigationController_);
    MCRelease(homeViewController_);
    MCRelease(box_);
    
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIApplicationDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup CocoaLumberJack-Logging
    [self configureLogger];
    // copy plist-files for forms from bundle to documents-directory
    [RBForm copyFormsFromBundle];
    // setup CoreData
	[ActiveRecordHelpers setupCoreDataStack];
    
    // TODO: Add Settings bundle instead of hardcoded value
    [NSUserDefaults standardUserDefaults].folderID = 92059513;
    
    // check for NSZombie (memory leak if enabled, but very useful!)
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
        DDLogWarn(@"NSZombieEnabled / NSAutoreleaseFreedObjectCheckEnabled enabled! Disable for release.");
    }
    
    self.homeViewController = [[[RBHomeViewController alloc] initWithNibName:@"RBHomeView" bundle:nil] autorelease];
    
    // Add the navigation controller's view to the window and display.
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self.homeViewController] autorelease];
    self.navigationController.navigationBarHidden = YES;
    self.window = [[[PSWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    self.box = [[[Box alloc] init] autorelease];
    
    if (kPostFinishLaunchDelay > 0) {
        [self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:kPostFinishLaunchDelay];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self appplicationPrepareForBackgroundOrTermination:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [self appplicationPrepareForBackgroundOrTermination:application];
    
    [ActiveRecordHelpers cleanUp];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory management
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // TODO: Release memory, or hell freazes over!
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Reachability
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configureForNetworkStatus:(NSNotification *)notification {
    NetworkStatus networkStatus = [[notification.userInfo valueForKey:kPSNetworkStatusKey] intValue];
    
    if (networkStatus != NotReachable) {
        __block RBBoxLoginViewController *loginViewController = [[RBBoxLoginViewController alloc] initWithNibName:nil bundle:nil];
        
        loginViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self.box syncFolderWithId:[NSUserDefaults standardUserDefaults].folderID
                        loginBlock:^UIWebView *(void) {
                            [self.navigationController presentModalViewController:loginViewController animated:NO];
                            return loginViewController.webView;
                        } 
                     progressBlock:^(BoxResponseType response, NSObject *boxObject) {
                         if (loginViewController != nil) {
                             [self.navigationController dismissModalViewControllerAnimated:YES];
                             MCReleaseNil(loginViewController);
                         }
                         
                         NSLog(@"progress box object: %@", [(BoxObject *)boxObject objectToString]);
                     } 
                   completionBlock:^(BoxResponseType response, NSObject *boxObject) {
                       if (loginViewController != nil) {
                           [self.navigationController dismissModalViewControllerAnimated:YES];
                           MCReleaseNil(loginViewController);
                       }
                       
                       NSLog(@"complete box object: %@", [(BoxObject *)boxObject objectToString]);
                   }];
        
        /*__block UIWebView *webView = nil;
        
        [self.box syncFolderWithId:92059513 loginBlock:^UIWebView *(void) {
            webView = [[UIWebView alloc] initWithFrame:self.homeViewController.view.bounds];
            [self.homeViewController.view addSubview:webView];
            [webView release];
            return webView;
        } progressBlock:^(BoxResponseType response, NSObject *boxObject) {
            if (webView) {
                [webView removeFromSuperview];
                webView = nil;
            }
            NSLog(@"progress box object: %@", [(BoxObject *)boxObject objectToString]);
        } completionBlock:^(BoxResponseType response, NSObject *boxObject) {
            if (webView) {
                [webView removeFromSuperview];
                webView = nil;
            }
            NSLog(@"complete box object: %@", [(BoxObject *)boxObject objectToString]);
        }];*/

    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configureLogger {
    PSDDFormatter *psLogger = [[[PSDDFormatter alloc] init] autorelease];
    [[DDTTYLogger sharedInstance] setLogFormatter:psLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
#ifndef APPSTORE
    // log to file
    DDFileLogger *fileLogger = [[[DDFileLogger alloc] init] autorelease];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
#ifndef DISTRIBUTION
    // log to network (disabled for now, as it breaks clang 1.7)
    // [DDLog addLogger:[DDNSLoggerLogger sharedInstance]];
#endif
    
#endif
}

- (void)appplicationPrepareForBackgroundOrTermination:(UIApplication *)application {
    DDLogInfo(@"detected application termination.");
    
    // post notification to all listeners
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppplicationWillSuspendNotification object:application];
    [[PSReachability sharedPSReachability] shutdownReachabilityFor:self];
}

// launched via post selector to speed up launch time
- (void)postFinishLaunch {
    [[PSReachability sharedPSReachability] startCheckingHostAddress:kReachabilityHostURL];
    [[PSReachability sharedPSReachability] setupReachabilityFor:self];
}

@end

