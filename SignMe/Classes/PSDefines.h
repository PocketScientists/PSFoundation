//
//  PSDefines.h
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//

#import "PSIncludes.h"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Template Configuration
////////////////////////////////////////////////////////////////////////

#define kIntroFadeAnimation
#define kUseCrashReporter
#define kCrashReporterFeedbackEnabled NO      // boolean switch
#define kPostFinishLaunchDelay        1.5     // set to positive value to call postFinishLaunch in AppDelegate after delay

#ifdef DEBUG
#define kMemoryWarningAfterDeviceShake
#endif

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark DCInstropect - Awesome visual debugging
////////////////////////////////////////////////////////////////////////

#ifdef TARGET_IPHONE_SIMULATOR
    #define kDCIntrospectEnabled
#endif


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark URLs
////////////////////////////////////////////////////////////////////////

#define kReachabilityHostURL    @"www.box.net"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Constants
////////////////////////////////////////////////////////////////////////

#define kRBCarouselColor        [UIColor lightGrayColor]
#define kRBCarouselViewColor    [UIColor darkGrayColor]

#define kRBFormDataType         @"plist"
#define kRBFormExtension        @"." kRBFormDataType
#define kRBFormDirectoryName    @"Forms"
#define kRBFormDirectoryPath    ([NSDocumentsFolder() stringByAppendingPathComponent:kRBFormDirectoryName])


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notifications
////////////////////////////////////////////////////////////////////////

// suspend/kill delegate
#define kAppplicationWillSuspendNotification @"kAppplicationWillSuspendNotification"
// device shaken
#define kDeviceWasShakenNotification         @"kDeviceWasShakenNotification"