//
//  ABPerson+RBMail.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "ABPerson+RBMail.h"
#import "ABMultiValue.h"


@implementation ABPerson (ABPerson_RBMail)

- (NSString *)mainEMail {
    ABMultiValue *multiValue = [self valueForProperty:kABPersonEmailProperty];
    
    if (multiValue.count) {
        return [multiValue valueAtIndex:0];
    }
    
    return @"No Mail";
}

- (BOOL)isEqual:(id)secondPerson {
    if (![secondPerson isKindOfClass:[ABPerson class]]) {
        return NO;
    }
    
    return self.recordID == [secondPerson recordID];
}

@end
