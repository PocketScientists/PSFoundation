//
//  RBClient.m
//  SignMe
//
//  Created by Tretter Matthias on 03.08.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBMusketeer.h"
#import "PSIncludes.h"
#import "RBMusketeer+RBProperties.h"

static RBMusketeer *musketeer;

@implementation RBMusketeer

@synthesize firstname = firstname_;
@synthesize lastname = lastname_;
@synthesize street = street_;
@synthesize city = city_;
@synthesize zip = zip_;
@synthesize state = state_;

+ (RBMusketeer *)loadEntity {
    if (!musketeer) {
        musketeer = [[RBMusketeer alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        for (NSString *propname in [RBMusketeer propertyNamesForMapping]) {
            [musketeer setStringValue:[defaults stringForKey:[NSString stringWithFormat:@"kRBMusketeer%@", propname]] forKey:propname];
        }
    }
    
    return musketeer;
}

- (void)saveEntity {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *propname in [RBMusketeer propertyNamesForMapping]) {
        [defaults setObject:[musketeer valueForKey:propname] forKey:[NSString stringWithFormat:@"kRBMusketeer%@", propname]];
    }
    [defaults synchronize];
}

- (void)dealloc {
    MCReleaseNil(firstname_);
    MCReleaseNil(lastname_);
    MCReleaseNil(street_);
    MCReleaseNil(city_);
    MCReleaseNil(zip_);
    MCReleaseNil(state_);
    
    [super dealloc];
}

@end
