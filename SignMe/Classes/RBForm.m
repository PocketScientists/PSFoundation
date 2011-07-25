//
//  RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBForm.h"
#import "PSIncludes.h"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Form Status
////////////////////////////////////////////////////////////////////////

NSString *RBFormStatusStringRepresentation(RBFormStatus formType) {
    switch (formType) {
        case RBFormStatusNew:
            return @"New";
            
        case RBFormStatusPreSignature:
            return @"Pre-Signature";
            
        case RBFormStatusSigned:
            return @"Signed";
            
        case RBFormStatusCount:
            return @"";
            
        case RBFormStatusUnknown:
            return @"Unknown";
    }
    
    return @"";
}

RBFormStatus RBFormStatusForIndex(NSUInteger index) {
    if (index < RBFormStatusCount) {
        return (RBFormStatus)index;
    }
    
    return RBFormStatusUnknown;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Class Extension
////////////////////////////////////////////////////////////////////////

@interface RBForm ()

// overwrite property as read/write and mutable
@property (nonatomic, retain, readwrite) NSMutableDictionary *formData;

@end

@implementation RBForm

@synthesize formData = formData_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
////////////////////////////////////////////////////////////////////////

+ (RBForm *)formWithName:(NSString *)name {
    return [[[RBForm alloc] initWithName:name] autorelease];
}

+ (NSArray *)allForms {
    NSError *error = nil;
    NSArray *formNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kRBFormDirectoryPath error:&error];
    
    if(IsEmpty(formNames)) {
        DDLogError(@"Error in reading form directory: %@", [error localizedDescription]);
        return nil;
    }
    
    NSMutableArray *allForms = [NSMutableArray arrayWithCapacity:formNames.count];
    
    // Create array of RBForm-Objects with the given names
    for (NSString *fileName in formNames) {
        if ([fileName hasSuffix:kRBFormExtension]) {
            [allForms addObject:[RBForm formWithName:fileName]];
        }
    }
    
    return allForms;
}

+ (void)copyFormsFromBundle {    
    NSError *error = nil;
    NSArray *forms = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kRBFormDirectoryPath error:&error];
    
    // if there are no files in the directory yet, copy files from App Bundle
    if (IsEmpty(forms)) {
        // Create forms directory
        if ([[NSFileManager defaultManager] createDirectoryAtPath:kRBFormDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            // TODO: Update with all forms shipped
            for (NSString *fileName in XARRAY(@"W-9", @"Partnership Agreement")) {
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileName ofType:kRBFormDataType];
                NSString *documentsPath = [[kRBFormDirectoryPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:kRBFormDataType];
                
                error = nil;
                if ([[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:documentsPath error:&error]) {
                    DDLogInfo(@"Copied file '%@' from bundle.", fileName);
                } else {
                    DDLogError(@"Error copying file '%@' from bundle: %@", fileName, [error localizedDescription]);
                }
            }
        } else {
            DDLogError(@"Couldn't create directory for forms: %@", [error localizedDescription]);
        }
    } else {
        DDLogInfo(@"No need to copy files from bundle");
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        // delete file extension if already specified
        if ([name hasSuffix:kRBFormExtension]) {
            name = [name substringToIndex:[name rangeOfString:kRBFormExtension].location];
        }
        
        NSString *fullPath = [[kRBFormDirectoryPath stringByAppendingPathComponent:name] stringByAppendingPathExtension:kRBFormDataType];
        formData_ = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(formData_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [self.formData description];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters
////////////////////////////////////////////////////////////////////////

- (NSString *)name {
    return [self.formData valueForKey:@"name"];
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSArray *)sections {
    return [self.formData valueForKey:@"sections"];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Section Setter/Getter
////////////////////////////////////////////////////////////////////////

- (id)valueForKey:(NSString *)key inSection:(NSUInteger)section {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return nil;
    }
    
    NSDictionary *sectionData = [self.sections objectAtIndex:section];
    
    return [sectionData valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key inSection:(NSUInteger)section {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return;
    }
    
    NSMutableDictionary *sectionData = [self.sections objectAtIndex:section];
    
    [sectionData setValue:value forKey:key];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Document
////////////////////////////////////////////////////////////////////////

- (void)saveAsDocument {
    
}

@end