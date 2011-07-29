//
//  NSUserDefaults+RBAdditions.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NSUserDefaults+RBAdditions.h"
#import "PSIncludes.h"

@implementation NSUserDefaults (NSUserDefaults_RBAdditions)

- (void)setFolderID:(NSInteger)folderID {
    [self setInteger:folderID forKey:kRBSettingsFolderIDKey];
}

- (NSInteger)folderID {
    return [self integerForKey:kRBSettingsFolderIDKey];
}

@end
