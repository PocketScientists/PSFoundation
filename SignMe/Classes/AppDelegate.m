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

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(window_);
    MCRelease(navigationController_);
    MCRelease(homeViewController_);
    
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
    [NSUserDefaults standardUserDefaults].folderID = 0;
    
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
}

// launched via post selector to speed up launch time
- (void)postFinishLaunch {
    [[PSReachability sharedPSReachability] startCheckingHostAddress:kReachabilityHostURL];

    [RBBoxService syncFolderWithID:[NSUserDefaults standardUserDefaults].folderID
                       startedFrom:self.homeViewController
                      successBlock:^(id boxObject) {
                          BoxFolder *formsFolder = (BoxFolder *)[boxObject objectAtFilePath:RBPathToEmptyForms()];
                          
                          if (formsFolder != nil) {
                              for (BoxFile *file in [formsFolder filesWithExtension:@"plist"]) {
                                  /*[[RBBoxService box] downloadFile:file
                                                     progressBlock:^(float progress) {
                                                         MTLog(progress);
                                                     } completionBlock:^(BoxResponseType resultType, NSData *fileData) {
                                                         MTLog(fileData);
                                                     }];*/
                              }
                          }
                      } failureBlock:nil];
}

@end

