//
//  PSAppTemplateAppDelegate.m
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//  Template by Peter Steinberger
//

#import "AppDelegate.h"
#import "PSIncludes.h"
#import "RBForm.h"
#import "RBDocuSignService.h"
#import "RBPersistenceManager.h"


@interface AppDelegate ()

@property (nonatomic, retain) NSTimer *docuSignUpdateTimer;

- (void)configureLogger;
- (void)appplicationPrepareForBackgroundOrTermination:(UIApplication *)application;
- (void)postFinishLaunch;
- (void)setupFileStructure;
- (void)logoutUserIfSpecifiedInSettings;
@end


@implementation AppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize homeViewController = homeViewController_;
@synthesize docuSignUpdateTimer = docuSignUpdateTimer_;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(window_);
    MCRelease(navigationController_);
    MCRelease(homeViewController_);
    MCRelease(docuSignUpdateTimer_);
    [docuSignUpdateTimer_ invalidate];
    MCRelease(docuSignUpdateTimer_);
    
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIApplicationDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup CocoaLumberJack-Logging
    [self configureLogger];
    // create needed folders
    [self setupFileStructure];
    
    // log out of box.net? was set in Settings Application
    [self logoutUserIfSpecifiedInSettings];
    // setup CoreData
	[ActiveRecordHelpers setupCoreDataStack];
    
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
    
    // fade effect
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Landscape~ipad"]] autorelease];
    [self.navigationController.view addSubview:imageView];
    [UIView animateWithDuration:0.4 animations:^(void) {
        imageView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    
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
#endif
}

- (void)appplicationPrepareForBackgroundOrTermination:(UIApplication *)application {
    DDLogInfo(@"detected application termination.");
    
    // post notification to all listeners
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppplicationWillSuspendNotification object:application];
    [[NSManagedObjectContext defaultContext] saveOnMainThread];
}

// launched via post selector to speed up launch time
- (void)postFinishLaunch {    
    // regularly update the status of all DocuSign Documents
    self.docuSignUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:kRBDocuSignUpdateTimeInterval
                                                                 block:^(void) {
                                                                     [RBDocuSignService updateStatusOfDocuments];
                                                                 } repeats:YES];
}

- (void)setupFileStructure {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // check if directories already exist
    for (NSString *directoryPath in XARRAY(kRBFormSavedDirectoryPath, kRBPDFSavedDirectoryPath)) {
        if (![manager fileExistsAtPath:directoryPath]) {
            [manager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

- (void)logoutUserIfSpecifiedInSettings {
    if ([NSUserDefaults standardUserDefaults].shouldLogOutOfBox && [[BoxUser savedUser] loggedIn]) {
        
        PSAlertView *alertView = [PSAlertView alertWithTitle:[BoxUser savedUser].userName
                                                     message:@"Do you really want to logout?\nThis will delete all your saved data from this device."];
        
        [alertView addButtonWithTitle:@"Log out" block:^(void) {
            RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
            
            [persistenceManager deleteAllSavedData];
            
            [[BoxUser savedUser] logOut];
            [NSUserDefaults standardUserDefaults].shouldLogOutOfBox = NO;
            [[NSUserDefaults standardUserDefaults] deleteStoredObjectNames];
            
            [self.homeViewController updateUI];
            [self.homeViewController syncBoxNet];
        }];
        
        [alertView setCancelButtonWithTitle:@"Cancel" block:nil];
        [alertView show];
    }
}

@end

