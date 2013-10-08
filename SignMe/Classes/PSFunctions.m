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
   
    NSLog(@"%@",urlressourcepart);
    return [NSURL URLWithString:[[NSString stringWithFormat:@"https://%@/%@",kApplicationURL,urlressourcepart] copy]];
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
    if ([formressourcename containsString:@"___"]) {
        formressourcename = [formressourcename substringAfterSubstring:@"___"];
    }
    fullPath = [NSString stringWithFormat:@"%@%@%@",fullPath,formressourcename,kRBFormExtension];
    return fullPath;
}

inline NSString *RBFullPathToPDFTemplateWithFormName(NSString *formressourcename) {
    //NSString *pdfname = [formressourcename substringBeforeSubstring:@"_Form"];
    NSString *pdfname;
    if([formressourcename hasSubstring:@"_Form"])
		pdfname = [formressourcename substringToIndex:[formressourcename rangeOfString:@"_Form"].location];
    if ([pdfname containsString:@"___"]) {
        pdfname = [pdfname substringAfterSubstring:@"___"];
    }
    pdfname= [pdfname stringByAppendingString:@"_PDF"];
    NSString *fullPath = RBFullPathToRessourceDirectoryForForm(formressourcename);
    fullPath = [NSString stringWithFormat:@"%@%@%@",fullPath,pdfname,kRBFormExtension];
    NSLog(@"Full path to pdf %@",fullPath);
    return fullPath;
}

inline NSString *RBPathToSignedFolderForClientWithName(NSString *clientName) {
    return [[kRBFolderUser stringByAppendingPathComponent:[clientName lowercaseString]] stringByAppendingPathComponent:kRBFolderSigned];
}

inline BOOL RBAllRecipientsSet(NSArray *recipients,NSUInteger numberOfRBSigner){
    NSUInteger rbsigners =0,accountsigners=0;
    
    for(NSDictionary *dict in recipients){
        if([dict objectForKey:kRBRecipientPersonID] != $I(0)){
            NSString *type = (NSString *)[dict objectForKey:kRBRecipientKind];
            if([type isEqualToString:@"RB"]){
                if([[dict objectForKey:kRBisNeededSigner] isEqualToNumber:kRBisNeededSignerTRUE]){
                    rbsigners++;
                }
            }
            if([type isEqualToString:@"Account"]){
                accountsigners++;
            }
        }
    }
    
    if(accountsigners == 1 && rbsigners >= numberOfRBSigner){
        return YES;
    }
    return NO;
}

inline NSString *RBPathToPreSignatureFolderForClientWithName(NSString *clientName) {
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

inline NSUInteger RBNumberOfSignersForContractSum(NSUInteger contractValue){
    RBMusketeer *musketeer = [RBMusketeer loadEntity];
    NSUInteger limit1,limit2;
    limit1=limit2=0;
    if(musketeer.sign_me_limit_1 != nil){
        limit1 = [musketeer.sign_me_limit_1 integerValue];
    }
    
    if(musketeer.sign_me_limit_2 != nil){
        limit2 = [musketeer.sign_me_limit_2 integerValue];
    }
    if(contractValue > limit2) return 3;
    if(contractValue > limit1) return 2;
    
    return 1;
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