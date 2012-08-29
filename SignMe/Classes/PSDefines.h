//
//  PSDefines.h
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//

#import "PSIncludes.h"
#import "BoxUser.h"
#import "RBMusketeer.h"
#import "VCTitleCase.h"

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

#define kReachabilityUserXML @"https://wss21-s.wiiings.com/saleshq_mibsync/api/1/session.xml"
#define kReachabilityOutletsXML @"https://stage-rbmib.v2a.net/api/2/sign_me/outlets.xml"
//#define kReachabilityOutletsXML @"https://stage-rbmib.v2a.net/api/1/outlets/list.xml"
#define kReachabilityFormsXML @"https://stage-rbmib.v2a.net/api/2/sign_me/templates.xml"
#define kApplicationURL [[RBMusketeer loadEntity] application_url]

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Constants
////////////////////////////////////////////////////////////////////////


#define kRBMIBURLPath @"mib.bundle.identifier"
#define kRBMIBCallType @"mibcalltype"
#define kRBMIBCallClientID @"mibcallclientid"
#define kRBMIBCallTypeAdd 1
#define kRBMIBCallTypeEdit 2
#define kRBMIBCallTypeDelete 3

#define kRBDetailGradientStartColor [UIColor colorWithRed:0.0627f green:0.0824f blue:0.1176f alpha:1.0000f]
#define kRBDetailGradientEndColor   [UIColor colorWithRed:0.0824f green:0.1765f blue:0.4314f alpha:1.0000f]
#define kRBColorMain                [UIColor whiteColor]
#define kRBColorDetail              [UIColor colorWithRed:1.0000f green:0.7725f blue:0.0000f alpha:1.0000f]
#define kRBColorDetail2             [UIColor colorWithRed:0.7804f green:0.0000f blue:0.2941f alpha:1.0000f]
#define kRBColorError               [UIColor colorWithRed:0.7961f green:0.0000f blue:0.3098f alpha:1.0000f]

#define kRBFormDataType             @"plist"
#define kRBFormExtension            @"." kRBFormDataType
#define kRBPDFDataType              @"pdf"
#define kRBPDFExtension             @"." kRBPDFDataType

#define kRBBoxNetDirectoryName      @"box.net"
#define kRBFormSavedDirectoryName   @"SavedForms"
#define kRBPDFSavedDirectoryName    @"PDFs"
#define kRBLogoSavedDirectoryName   @"Logos"
#define kRBBoxNetDirectoryPath      ([NSDocumentsFolder() stringByAppendingPathComponent:kRBBoxNetDirectoryName])
#define kRBFormSavedDirectoryPath   ([NSDocumentsFolder() stringByAppendingPathComponent:kRBFormSavedDirectoryName])
#define kRBPDFSavedDirectoryPath    ([NSDocumentsFolder() stringByAppendingPathComponent:kRBPDFSavedDirectoryName])
#define kRBLogoSavedDirectorypath   ([NSDocumentsFolder() stringByAppendingPathComponent:kRBLogoSavedDirectoryName])

#define kRBFontName                 @"Heiti TC"
#define kRBDateFormat               @"MM-dd-yyyy"
#define kRBDateTimeFormat           @"yyyy-MM-dd_HH-mm-ss"
#define kRBDateTime2Format          @"MM-dd-yyyy hh:mm a"

#define kRBRecipientPersonID        @"addressBookPersonID"
#define kRBRecipientEmailID         @"emailPropertyID"
#define kRBRecipientType            @"type"
#define kRBRecipientCode            @"code"
#define kRBRecipientIDCheck         @"idcheck"
#define kRBRecipientOrder           @"order"
#define kRBRecipientKind            @"kind"
#define kRBRecipientTypeRemote      0
#define kRBRecipientTypeInPerson    1

#define kRBDocuSignUpdateTimeInterval MTTimeIntervalMinutes(15)
#define kRBAuthorizationTimeInterval MTTimeIntervalHours(12) 

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Box.net Folder Structure
////////////////////////////////////////////////////////////////////////

//#define kRBFolderUser               [[[BoxUser savedUser] userName] lowercaseString]
//#define kRBFolderUser               [[[RBMusketeer loadEntity] firstname] titlecaseString]
#define kRBFolderUser               [[NSString stringWithFormat:@"%@ %@", [[RBMusketeer loadEntity] firstname], \
                                    [[RBMusketeer loadEntity] lastname]] titlecaseString]
#define kRBFolderUserEmptyForms     ([NSDocumentsFolder() stringByAppendingPathComponent:kRBFormSavedDirectoryName])
#define kRBFolderEmptyForms         @"forms"
#define kRBFolderPreSignature       @"pre-signature"
#define kRBFolderSigned             @"signed"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Settings
////////////////////////////////////////////////////////////////////////

#define kRBSettingsBoxFolderIDKey           @"kRBSettingsBoxFolderIDKey"
#define kRBSettingsBoxLogoutKey             @"kRBSettingsBoxLogoutKey"
#define kRBSettingsBoxUsernameKey           @"kRBSettingsBoxUsernameKey"
#define kRBSettingsBoxPasswordKey           @"kRBSettingsBoxPasswordKey"
#define kRBSettingsFormsUpdateDateKey       @"kRBSettingsFormsUpdateDateKey"
#define kRBSettingsDocuSignUserNameKey      @"kRBSettingsDocuSignUserNameKey"
#define kRBSettingsDocuSignPasswordKey      @"kRBSettingsDocuSignPasswordKey"
#define kRBSettingsDocuSignUpdateDateKey    @"kRBSettingsDocuSignUpdateDateKey"

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
