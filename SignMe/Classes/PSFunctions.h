//
//  PSFunctions.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


NSString *RBFormattedDateWithFormat(NSDate *date, NSString *format);

NSString *RBPathToEmptyForms();
NSString *RBPathToSignedFolderForClientWithName(NSString *clientName);
NSString *RBPathToPreSignatureFolderForClientWithName(NSString *clientName);
