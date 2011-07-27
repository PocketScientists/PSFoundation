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
            return @"New Form";
            
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
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, retain, readwrite) NSMutableDictionary *formData;

- (NSInteger)indexOfObjectWithFieldID:(NSString *)fieldID inArray:(NSArray *)array;

@end

@implementation RBForm

@synthesize name = name_;
@synthesize formData = formData_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods
////////////////////////////////////////////////////////////////////////

+ (RBForm *)emptyFormWithName:(NSString *)name {
    return [[[RBForm alloc] initWithName:name] autorelease];
}

+ (NSArray *)allEmptyForms {
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
            [allForms addObject:[RBForm emptyFormWithName:fileName]];
        }
    }
    
    return allForms;
}

+ (void)copyFormsFromBundle {    
    NSError *error = nil;
    NSArray *forms = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kRBFormDirectoryPath error:&error];
    
    // if there are no files in the directory yet, copy files from App Bundle
    if (IsEmpty(forms)) {
        // Create forms directory (Forms/Saved, because of intermediate=YES also forms-directory gets created)
        if ([[NSFileManager defaultManager] createDirectoryAtPath:kRBFormSavedDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            // TODO: Update with all forms shipped
            for (NSString *fileName in XARRAY(@"W-9", @"Red Bull Form", @"Partnership Agreement")) {
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
    // delete file extension if already specified
    if ([name hasSuffix:kRBFormExtension]) {
        name = [name substringToIndex:[name rangeOfString:kRBFormExtension].location];
    }
    
    NSString *fullPath = [[kRBFormDirectoryPath stringByAppendingPathComponent:name] stringByAppendingPathExtension:kRBFormDataType];
    
    return [self initWithPath:fullPath];
}

- (id)initWithPath:(NSString *)path {
    if ((self = [super init])) {
        formData_ = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        // remove extension from name
        path = [path lastPathComponent];
        
        NSRange dotRange = [path rangeOfString:@"."];
        if (dotRange.location != NSNotFound) {
            path = [path substringToIndex:dotRange.location];
        }
        
        name_ = [path copy];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(formData_);
    MCRelease(name_);
    
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

- (NSString *)filePath {
    NSString *fileComponent = [NSString stringWithFormat:@"%d_%@",(NSInteger)[[NSDate date] timeIntervalSince1970], self.name];
    
    // Forms/Saved/DateInSecondsSince1970_Name.plist
    return [[kRBFormSavedDirectoryPath stringByAppendingPathComponent:fileComponent] stringByAppendingPathExtension:kRBFormDataType];
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSArray *)sections {
    return [self.formData valueForKey:kRBFormKeySection];
}

- (NSArray *)fieldIDsOfSection:(NSUInteger)section {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return nil;
    }
    
    // get section at specified index
    NSArray *sectionData = [self.sections objectAtIndex:section];
    NSArray *fieldIDs = [sectionData valueForKey:kRBFormKeyID];
    
    return fieldIDs;
}

- (id)valueForKey:(NSString *)key ofField:(NSString *)fieldID inSection:(NSUInteger)section {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return nil;
    }
    
    // get section at specified index
    NSArray *sectionData = [self.sections objectAtIndex:section];
    NSInteger index = [self indexOfObjectWithFieldID:fieldID inArray:sectionData];
    
    // if we found an index, return the value of the field for the given key
    if (index != NSNotFound) {
        return [[sectionData objectAtIndex:index] valueForKey:key];
    }
    
    return nil;
}

- (void)setValue:(id)value forField:(NSString *)fieldID inSection:(NSUInteger)section {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return;
    }
    
    NSArray *sectionData = [self.sections objectAtIndex:section];
    NSInteger index = [self indexOfObjectWithFieldID:fieldID inArray:sectionData];
    
    if (index != NSNotFound) {
        [[sectionData objectAtIndex:index] setValue:value forKey:kRBFormKeyValue];
    } else {
        DDLogWarn(@"Index '%d' not found in section '%d'", index, section);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Document
////////////////////////////////////////////////////////////////////////

- (BOOL)saveAsDocument {
    return [self.formData writeToFile:self.filePath atomically:YES];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (NSInteger)indexOfObjectWithFieldID:(NSString *)fieldID inArray:(NSArray *)array {
    // retreive index of object with the given fieldID
    NSInteger index = [array indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForKey:kRBFormKeyID] isEqualToString:fieldID]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    return index;
}

@end