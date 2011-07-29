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
#pragma mark URLs
////////////////////////////////////////////////////////////////////////

#define kReachabilityHostURL    @"www.box.net"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Constants
////////////////////////////////////////////////////////////////////////

#define kRBDetailGradientStartColor   [UIColor colorWithRed:0.0549f green:0.0471f blue:0.0510f alpha:1.0000f]
#define kRBDetailGradientEndColor     [UIColor colorWithRed:0.0980f green:0.1137f blue:0.2549f alpha:1.0000f]

#define kRBFormDataType             @"plist"
#define kRBFormExtension            @"." kRBFormDataType
#define kRBFormDirectoryName        @"Forms"
#define kRBFormSavedDirectoryName   @"Saved"
#define kRBFormDirectoryPath        ([NSDocumentsFolder() stringByAppendingPathComponent:kRBFormDirectoryName])
#define kRBFormSavedDirectoryPath   [kRBFormDirectoryPath stringByAppendingPathComponent:kRBFormSavedDirectoryName]

#define kRBFontName                 @"Heiti SC"
#define kRBColorMain                [UIColor whiteColor]
#define kRBColorDetail              [UIColor colorWithRed:0.7765f green:0.7333f blue:0.1137f alpha:1.0000f]
#define kRBDateFormat               @"MM-dd-yyyy"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Settings
////////////////////////////////////////////////////////////////////////

#define kRBSettingsFolderIDKey      @"kRBSettingsFolderIDKey"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notifications
////////////////////////////////////////////////////////////////////////

// suspend/kill delegate
#define kAppplicationWillSuspendNotification @"kAppplicationWillSuspendNotification"
// device shaken
#define kDeviceWasShakenNotification         @"kDeviceWasShakenNotification"


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Helper Functions
////////////////////////////////////////////////////////////////////////

NS_INLINE NSString *RBFormattedDate(NSDate *date) {
    static NSDateFormatter *dateFormatter = nil;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kRBDateFormat];
    }
    
    return [dateFormatter stringFromDate:date];
}