//
//  RBForm.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBForm.h"
#import "PSIncludes.h"
#import "RBPersistenceManager.h"

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Form Status
////////////////////////////////////////////////////////////////////////

NSString *RBFormStatusStringRepresentation(RBFormStatus formStatus) {
    switch (formStatus) {
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

NSString *RBUpdateStringForFormStatus(RBFormStatus formStatus) {
    NSDate *updateDate = nil;
    
    switch (formStatus) {
        case RBFormStatusNew:
            updateDate = [NSUserDefaults standardUserDefaults].formsUpdateDate;
            break;
            
        case RBFormStatusPreSignature:
        case RBFormStatusSigned: 
        {
            RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
            updateDate = [persistenceManager updateDateForFormStatus:formStatus];
            break;
        }
            
        case RBFormStatusCount:
        case RBFormStatusUnknown:
            return @"";
    }
    
    if (updateDate != nil) {
        return [NSString stringWithFormat:@"UPDATED %@",RBFormattedDateWithFormat(updateDate, kRBDateFormat)];
    } else {
        return @"NEVER UPDATED";
    }
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

- (id)copyWithZone:(NSZone *)zone {
    RBForm *copy = [[[self class] allocWithZone:zone] initWithName:self.name];
        
    return copy;
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
    static NSDate *creationDate = nil;
    
    if (creationDate == nil) {
        creationDate = [[NSDate date] retain];
    }
    
    return [NSString stringWithFormat:@"%@__%@", self.name, RBFormattedDateWithFormat(creationDate, kRBDateTimeFormat)];
}

- (NSString *)displayName {
    return [self.formData valueForKey:kRBFormKeyDisplayName];
}

- (NSString *)displayNameOfSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return nil;
    
    return [sectionInfo objectForKey:kRBFormKeyDisplayName];
}

- (NSString *)displayNameOfSubsection:(NSUInteger)subsection inSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return nil;

    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    if (subsections == nil) return nil;

    NSDictionary *subsectionInfo = [subsections objectAtIndex:subsection];
    if (subsectionInfo == nil) return nil;
    
    return [subsectionInfo objectForKey:kRBFormKeyDisplayName];
}

- (NSUInteger)numberOfSections {
    return self.sections.count;
}

- (NSUInteger)numberOfSubsectionsInSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return 1;
    
    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    return MAX([subsections count], 1);
}

- (NSArray *)sections {
    return [self.formData valueForKey:kRBFormKeySection];
}

- (NSArray *)sectionDisplayInfos {
    return [self.formData valueForKey:kRBFormKeySectionInfos];
}

- (NSUInteger)numberOfTabs {
    return self.tabs.count;
}

- (NSUInteger)numberOfRecipients {
    return [[self.formData valueForKey:kRBFormKeyTabs] count];
}

- (NSUInteger)numberOfTabsWithType:(NSString *)tabType {
    return [self tabsWithType:tabType].count;
}

- (NSArray *)tabsWithType:(NSString *)tabType {
    return [self.tabs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[evaluatedObject valueForKey:kRBFormKeyTabType] isEqualToStringIgnoringCase:tabType]) {
            return YES;
        }
        
        return NO;
    }]];
}

- (NSArray *)tabs {
    return [self tabsForNumberOfRecipients:self.numberOfRecipients];
}

- (NSArray *)tabsForNumberOfRecipients:(NSUInteger)numberOfRecipients {
    NSArray *tabs = [self.formData valueForKey:kRBFormKeyTabs];
    NSMutableArray *flattenedTabs = [NSMutableArray array];
    
    // tabs stores an array of recipients, which contains an array of tabs for this recipient
    for (NSUInteger i = 0;i < MIN(numberOfRecipients,tabs.count);i++) {
        NSArray *tabsForRecipient = [tabs objectAtIndex:i];
        
        // add additional information to tabs
        for (NSDictionary *tab in tabsForRecipient) {
            NSMutableDictionary *tabCopy = [[tab mutableCopy] autorelease];
            
            // we always have document index 0
            [tabCopy setValue:$I(0) forKey:kRBFormKeyTabDocumentIndex];
            // we set a default-value for the recipient-index (increasing)
            [tabCopy setValue:$I(i) forKey:kRBFormKeyTabRecipientIndex];
            
            // add object to flattened tabs
            [flattenedTabs addObject:tabCopy];
        }
    }
    
    return flattenedTabs;
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

- (NSArray *)fieldIDsOfSubsection:(NSUInteger)subsection inSection:(NSUInteger)section {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return nil;
    }
    
    NSArray *fieldIDs = [self fieldIDsOfSection:section];
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return fieldIDs;
    
    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    if (subsection >= [subsections count]) {
        DDLogWarn(@"Subsection index %d out of bounds", subsection);
        return nil;
    }
    
    NSDictionary *subsectionInfo = [subsections objectAtIndex:subsection];
    NSString *fields = [subsectionInfo objectForKey:kRBFormKeyFields];
    
    NSArray *fieldIndexes = [fields componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSMutableArray *subFieldIDs = [NSMutableArray array];
    
    for (NSString *fieldIndex in fieldIndexes) {
        NSUInteger idx = [fieldIndex intValue];
        if (idx >= [fieldIDs count]) {
            continue;
        }
        [subFieldIDs addObject:[fieldIDs objectAtIndex:idx]];
    }
    return subFieldIDs;
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

- (NSArray *)listForID:(NSString *)listID {
    NSArray *lists = [self.formData valueForKey:kRBFormKeyLists];
    for (NSDictionary *list in lists) {
        NSString *listid = [list objectForKey:kRBFormKeyListID];
        if ([listid isEqualToString:listID]) {
            return [list objectForKey:kRBFormKeyItems];
        }
    }
    return nil;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Document
////////////////////////////////////////////////////////////////////////

- (BOOL)saveAsDocument {
    return [self saveAsDocumentWithName:self.fileName];
}

- (BOOL)saveAsDocumentWithName:(NSString *)name {
    NSString *filePath = RBPathToPlistWithName(name);
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