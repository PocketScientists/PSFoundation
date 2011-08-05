//
//  PSDefines.h
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//

#import "PSIncludes.h"
#import "BoxUser.h"

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

#define kRBDetailGradientStartColor [UIColor colorWithRed:0.0627f green:0.0824f blue:0.1176f alpha:1.0000f]
#define kRBDetailGradientEndColor   [UIColor colorWithRed:0.0824f green:0.1765f blue:0.4314f alpha:1.0000f]
#define kRBColorMain                [UIColor whiteColor]
#define kRBColorDetail              [UIColor colorWithRed:1.0000f green:0.7725f blue:0.0000f alpha:1.0000f]
#define kRBColorDetail2             [UIColor colorWithRed:0.7804f green:0.0000f blue:0.2941f alpha:1.0000f]

#define kRBFormDataType             @"plist"
#define kRBFormExtension            @"." kRBFormDataType
#define kRBPDFDataType              @"pdf"
#define kRBPDFExtension             @"." kRBPDFDataType

#define kRBBoxNetDirectoryName      @"box.net"
#define kRBFormSavedDirectoryName   @"SavedForms"
#define kRBPDFSavedDirectoryName    @"PDFs"
#define kRBBoxNetDirectoryPath      ([NSDocumentsFolder() stringByAppendingPathComponent:kRBBoxNetDirectoryName])
#define kRBFormSavedDirectoryPath   ([NSDocumentsFolder() stringByAppendingPathComponent:kRBFormSavedDirectoryName])
#define kRBPDFSavedDirectoryPath    ([NSDocumentsFolder() stringByAppendingPathComponent:kRBPDFSavedDirectoryName])

#define kRBFontName                 @"Heiti TC"
#define kRBDateFormat               @"MM-dd-yyyy"
#define kRBDateTimeFormat           @"yyyy-MM-dd_hh-mm-ss"

#define kRBRecipientPersonID        @"addressBookPersonID"
#define kRBRecipientEmailID         @"emailPropertyID"

#define kRBDocuSignUpdateTimeInterval MTTimeIntervalMinutes(10)

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Box.net Folder Structure
////////////////////////////////////////////////////////////////////////

#define kRBFolderUser               [[[BoxUser savedUser] userName] lowercaseString]
#define kRBFolderEmptyForms         @"forms"
#define kRBFolderPreSignature       @"pre-signature"
#define kRBFolderSigned             @"signed"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Settings
////////////////////////////////////////////////////////////////////////

#define kRBSettingsBoxFolderIDKey           @"kRBSettingsBoxFolderIDKey"
#define kRBSettingsBoxLogoutKey             @"kRBSettingsBoxLogoutKey"
#define kRBSettingsFormsUpdateDateKey       @"kRBSettingsFormsUpdateDateKey"
#define kRBSettingsDocuSignUserNameKey      @"kRBSettingsDocuSignUserNameKey"
#define kRBSettingsDocuSignPasswordKey      @"kRBSettingsDocuSignPasswordKey"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notifications
////////////////////////////////////////////////////////////////////////

// suspend/kill delegate
#define kAppplicationWillSuspendNotification @"kAppplicationWillSuspendNotification"
// device shaken
#define kDeviceWasShakenNotification         @"kDeviceWasShakenNotification"
// Download of a file finished
#define kBoxNetFileDownloadFinishedNotification     @"kBoxNetFileDownloadFinishedNotification"
