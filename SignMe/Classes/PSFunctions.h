//
//  PSFunctions.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


NSString *RBFormattedDateWithFormat(NSDate *date, NSString *format);

// path to Box.net folders
NSString *RBPathToEmptyForms();
NSString *RBPathToSignedFolderForClientWithName(NSString *clientName);
NSString *RBPathToPreSignatureFolderForClientWithName(NSString *clientName);

// path to local plist file
NSString *RBPathToPlistWithName(NSString *name);
NSString *RBPathToPDFWithName(NSString *name);

NSString *RBFileNameForFormWithName(NSString *formName);
NSString *RBFileNameForPDFWithName(NSString *formName);