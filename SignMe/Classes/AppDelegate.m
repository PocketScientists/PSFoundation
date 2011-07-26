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
#import "RBForm.h"

#ifdef kDCIntrospectEnabled
#import "DCIntrospect.h"
#endif


@interface AppDelegate ()

- (void)configureLogger;
- (void)appplicationPrepareForBackgroundOrTermination:(UIApplication *)application;
- (void)postFinishLaunch;
@end


@implementation AppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(window_);
    MCRelease(navigationController_);
    
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
        
    // check for NSZombie (memory leak if enabled, but very useful!)
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
        DDLogWarn(@"NSZombieEnabled / NSAutoreleaseFreedObjectCheckEnabled enabled! Disable for release.");
    }
    
    RBHomeViewController *homeViewController = [[[RBHomeViewController alloc] initWithNibName:@"RBHomeView" bundle:nil] autorelease];
    
    // Add the navigation controller's view to the window and display.
    navigationController_ = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    navigationController_.navigationBarHidden = YES;
    window_ = [[PSWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window_.rootViewController = navigationController_;
    [window_ makeKeyAndVisible];
    
    // visual debugging!
#ifdef kDCIntrospectEnabled
    // [[DCIntrospect sharedIntrospector] start];
#endif
    
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
    // NetworkStatus networkStatus = [[notification.userInfo valueForKey:kPSNetworkStatusKey] intValue];
    
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
    //[[PSReachability sharedPSReachability] startCheckingHostAddress:kReachabilityHostURL];
    //[[PSReachability sharedPSReachability] setupReachabilityFor:self];
}

@end

