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
    NSArray *formNames = [[NSUserDefaults standardUserDefaults] allStoredObjectNames];
    NSMutableArray *allForms = [NSMutableArray arrayWithCapacity:formNames.count];
    
    // Create array of RBForm-Objects with the given names
    for (NSString *formName in formNames) {
        [allForms addObject:[RBForm emptyFormWithName:formName]];
    }
    
    return allForms;
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
    
    NSString *fullPath = [kRBBoxNetDirectoryPath stringByAppendingPathComponent:RBFileNameForFormWithName(name)];
    
    return [self initWithPath:fullPath name:name];
}

- (id)initWithPath:(NSString *)path name:(NSString *)name {
    if ((self = [super init])) {
        formData_ = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        name_ = [name copy];
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

- (NSString *)fileName {
    return [NSString stringWithFormat:@"%@__%@", self.name, RBFormattedDateWithFormat([NSDate date], kRBDateTimeFormat)];
}

- (NSString *)displayName {
    return [self.formData valueForKey:kRBFormKeyDisplayName];
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSArray *)sections {
    return [self.formData valueForKey:kRBFormKeySection];
}

- (NSDictionary *)PDFDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSArray *section in self.sections) {
        for (NSDictionary *field in section) {
            id fieldValue = [field valueForKey:kRBFormKeyValue];
            
            if (!IsEmpty(fieldValue)) {
                [dict setValue:fieldValue forKey:[field valueForKey:kRBFormKeyID]];
            }
        }
    }
    
    return [[dict copy] autorelease];
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

- (BOOL)fieldWithID:(NSString *)fieldID inSection:(NSUInteger)section matches:(NSString *)match {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return NO;
    }
    
    NSArray *sectionData = [self.sections objectAtIndex:section];
    NSInteger index = [self indexOfObjectWithFieldID:fieldID inArray:sectionData];
    
    if (index != NSNotFound) {
        return [[[sectionData objectAtIndex:index] valueForKey:kRBFormKeyMapping] isEqualToString:match];
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Document
////////////////////////////////////////////////////////////////////////

- (BOOL)saveAsDocument {
    NSString *filePath = [kRBFormSavedDirectoryPath stringByAppendingPathComponent:[self.fileName stringByAppendingString:kRBFormExtension]];
    return [self.formData writeToFile:filePath atomically:YES];
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