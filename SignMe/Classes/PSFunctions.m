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

inline NSURL *RBFullFormRessourceURL(NSString *urlressourcepart){
   
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@",kApplicationURL,urlressourcepart]];
}

inline NSString *RBFormSaveName(NSString *formname, NSString *ressourceurl){
    
    return [NSString stringWithFormat:@"%@_%@",formname,[ressourceurl lastPathComponent]];
}

inline NSString *RBRessourceNameFromURL(NSString *urlressourcepart){
    return  [[urlressourcepart lastPathComponent] stringByDeletingPathExtension];
}

inline NSString *RBPathToEmptyForms() {
    return kRBFolderEmptyForms;
}

inline NSString *RBFullPathToRessourceDirectoryForForm(NSString *formressourcename){
    NSString * fullPath = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",formressourcename,kRBFormExtension]];
    fullPath = [NSString stringWithFormat:@"%@/",fullPath];
    return fullPath;
}

inline NSString *RBFullPathToEmptyFormWithName(NSString *formressourcename) {
    NSString *fullPath = RBFullPathToRessourceDirectoryForForm(formressourcename);
    fullPath = [NSString stringWithFormat:@"%@%@%@",fullPath,formressourcename,kRBFormExtension];
    return fullPath;
}

inline NSString *RBFullPathToPDFTemplateWithFormName(NSString *formressourcename) {
    //NSString *pdfname = [formressourcename substringBeforeSubstring:@"_Form"];
    NSString *pdfname;
    if([formressourcename hasSubstring:@"_Form"])
		pdfname = [formressourcename substringToIndex:[formressourcename rangeOfString:@"_Form"].location];
    pdfname= [pdfname stringByAppendingString:@"_PDF"];
    NSString *fullPath = RBFullPathToRessourceDirectoryForForm(formressourcename);
    fullPath = [NSString stringWithFormat:@"%@%@%@",fullPath,pdfname,kRBFormExtension];
    return fullPath;
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

inline NSString *RBPathToFolderForStatusAndClientWithName(RBFormStatus status, NSString *clientName) {
    if (status == RBFormStatusPreSignature) {
        return RBPathToPreSignatureFolderForClientWithName(clientName);
    } else if (status == RBFormStatusSigned) {
        return RBPathToSignedFolderForClientWithName(clientName);
    }
    
    return nil;
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
//    NSNumber *objectID = [[NSUserDefaults standardUserDefaults] objectIDForPDFWithName:formName];
    
  //  return [NSString stringWithFormat:@"%@_%@%@", objectID, formName, kRBPDFExtension];
    return [NSString stringWithFormat:@"%@%@",formName,kRBPDFExtension];
}