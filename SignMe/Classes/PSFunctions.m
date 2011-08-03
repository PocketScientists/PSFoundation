//
//  PSFunctions.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "PSFunctions.h"
#import "PSDefines.h"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Helper Functions
////////////////////////////////////////////////////////////////////////

inline NSString *RBFormattedDateWithFormat(NSDate *date, NSString *format) {
    static NSDateFormatter *dateFormatter = nil;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

inline NSString *RBPathToEmptyForms() {
    return kRBFolderEmptyForms;
}

inline NSString *RBPathToSignedFolderForClientWithName(NSString *clientName) {
    if (![BoxUser savedUser].loggedIn) {
        return nil;
    }
    
    return [[kRBFolderUser stringByAppendingPathComponent:[clientName lowercaseString]] stringByAppendingPathComponent:kRBFolderSigned];
}

inline NSString *RBPathToPreSignatureFolderForClientWithName(NSString *clientName) {
    if (![BoxUser savedUser].loggedIn) {
        return nil;
    }
    
    return [[kRBFolderUser stringByAppendingPathComponent:[clientName lowercaseString]] stringByAppendingPathComponent:kRBFolderPreSignature];
}

inline NSString *RBPathToPlistWithName(NSString *name) {
    return [kRBFormSavedDirectoryPath stringByAppendingPathComponent:[name stringByAppendingString:kRBFormExtension]];
}

inline NSString *RBPathToPDFWithName(NSString *name) {
    return [kRBPDFSavedDirectoryPath stringByAppendingPathComponent:[name stringByAppendingString:kRBPDFExtension]];
}

inline NSString *RBFileNameForFormWithName(NSString *formName) {
    NSNumber *objectID = [[NSUserDefaults standardUserDefaults] objectIDForPlistWithName:formName];
    
    return [NSString stringWithFormat:@"%@_%@%@", objectID, formName, kRBFormExtension];
}

inline NSString *RBFileNameForPDFWithName(NSString *formName) {
    NSNumber *objectID = [[NSUserDefaults standardUserDefaults] objectIDForPDFWithName:formName];
    
    return [NSString stringWithFormat:@"%@_%@%@", objectID, formName, kRBPDFExtension];
}