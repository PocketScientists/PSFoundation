//
//  ABPerson+RBMail.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "ABPerson+RBMail.h"
#import "ABMultiValue.h"
#import "PSIncludes.h"


#define kRBNoMailString     @"No E-Mail Address"

@implementation ABPerson (ABPerson_RBMail)

- (NSString *)emailForID:(NSNumber *)emailID {
    ABMultiValue *multiValue = [self valueForProperty:kABPersonEmailProperty];
    
    if (multiValue.count > 0) {
        int index = [multiValue indexForIdentifier:[emailID intValue]];
        
        if (index >=0 && index < multiValue.count) {
            return [multiValue valueAtIndex:index];
        }
    }
    
    return kRBNoMailString;
}

- (NSString *)fullName {
    NSString *name = @"";
    
    if (!IsEmpty(self.lastName)) {
        name = self.lastName;
    }
    
    if (!IsEmpty(self.firstName)) {
        if (IsEmpty(name)) {
            name = self.firstName;
        } else {
            name = [name stringByAppendingFormat:@", %@", self.firstName];
        }
    }
    
    return name;
}

- (BOOL)isEqual:(id)secondPerson {
    if (![secondPerson isKindOfClass:[ABPerson class]]) {
        return NO;
    }
    
    return self.recordID == [secondPerson recordID];
}

@end
