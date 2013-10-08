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
            RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
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
@property (nonatomic, strong, readwrite) NSMutableDictionary *formData;
@property (nonatomic, strong) NSDate *creationDate;

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
    return [[RBForm alloc] initWithName:name];
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

    NSString *fullPath=RBFullPathToEmptyFormWithName(name);
    
    return [self initWithPath:fullPath name:name];
}

- (id)initWithPath:(NSString *)path name:(NSString *)name {
    if ((self = [super init])) {
        formData_ = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        name_ = [name copy];
        _creationDate = [NSDate date];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    RBForm *copy = [[[self class] allocWithZone:zone] initWithName:self.name];
        
    return copy;
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
    if (self.creationDate == nil) {
        self.creationDate = [NSDate date];
    }
    
    return [NSString stringWithFormat:@"%@__%@", self.name, RBFormattedDateWithFormat(self.creationDate, kRBDateTimeFormat)];
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

- (BOOL)isOptionalSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return NO;
    
    return [[sectionInfo objectForKey:kRBFormKeyOptional] boolValue];
}

- (BOOL)isOptionalSubsection:(NSUInteger)subsection inSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return NO;
    
    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    if (subsections == nil) return NO;
    
    NSDictionary *subsectionInfo = [subsections objectAtIndex:subsection];
    if (subsectionInfo == nil) return NO;
    
    return [[subsectionInfo objectForKey:kRBFormKeyOptional] boolValue];
}

- (BOOL)isIncludedSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return YES;
    
    NSString *value = [sectionInfo objectForKey:kRBFormKeyIncluded];
    return value == nil ? YES : [value boolValue];
}

- (BOOL)isIncludedSubsection:(NSUInteger)subsection inSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return YES;
    
    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    if (subsections == nil) return YES;
    
    NSDictionary *subsectionInfo = [subsections objectAtIndex:subsection];
    if (subsectionInfo == nil) return YES;
    
    NSString *value = [subsectionInfo objectForKey:kRBFormKeyIncluded];
    return value == nil ? YES : [value boolValue];
}

- (void)setIncluded:(BOOL)included forSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return;
    
    [sectionInfo setValue:[NSNumber numberWithBool:included] forKey:kRBFormKeyIncluded];
}

- (void)setIncluded:(BOOL)included forSubsection:(NSUInteger)subsection inSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return;
    
    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    if (subsections == nil) return;
    
    NSDictionary *subsectionInfo = [subsections objectAtIndex:subsection];
    if (subsectionInfo == nil) return;
    
    [subsectionInfo setValue:[NSNumber numberWithBool:included] forKey:kRBFormKeyIncluded];
}

- (NSString *)discriminatorOfSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return nil;
    
    return [sectionInfo objectForKey:kRBFormKeyDiscriminator];
}

- (NSString *)discriminatorOfSubsection:(NSUInteger)subsection inSection:(NSUInteger)section {
    NSDictionary *sectionInfo = [self.sectionDisplayInfos objectAtIndex:section];
    if (sectionInfo == nil) return nil;
    
    NSArray *subsections = [sectionInfo objectForKey:kRBFormKeySubsections];
    if (subsections == nil) return nil;
    
    NSDictionary *subsectionInfo = [subsections objectAtIndex:subsection];
    if (subsectionInfo == nil) return nil;
    
    return [subsectionInfo objectForKey:kRBFormKeyDiscriminator];
}

- (NSString *)discriminator {
    NSMutableString *disc = [NSMutableString stringWithCapacity:5];
    for (NSUInteger section=0;section < self.numberOfSections; section++) {
        if ([self isOptionalSection:section]) {
            NSString *d = [self discriminatorOfSection:section];
            if (d && [self isIncludedSection:section]) {
                [disc appendString:d];
            }
            else {
                [disc appendString:@"-"];
            }
        }
        for (NSUInteger subsection=0; subsection < [self numberOfSubsectionsInSection:section]; subsection++) {
            if ([self isOptionalSubsection:subsection inSection:section]) {
                NSString *d = [self discriminatorOfSubsection:subsection inSection:section];
                if (d && [self isIncludedSubsection:subsection inSection:section]) {
                    [disc appendString:d];
                }
                else {
                    [disc appendString:@"-"];
                }
            }
        }
    }
    
    return disc;
}


- (NSDictionary *)optionalSectionsDictionary {
    NSMutableDictionary *disc = [NSMutableDictionary dictionaryWithCapacity:5];
    for (NSUInteger section=0;section < self.numberOfSections; section++) {
        if ([self isOptionalSection:section]) {
            NSString *d = [self discriminatorOfSection:section];
            if (d) {
                d = [NSString stringWithFormat:@"section%@", d];
                if ([self isIncludedSection:section]) {
                    [disc setObject:[NSNumber numberWithBool:YES] forKey:d];
                }
                else {
                    [disc setObject:[NSNumber numberWithBool:NO] forKey:d];
                }
            }
        }
        for (NSUInteger subsection=0; subsection < [self numberOfSubsectionsInSection:section]; subsection++) {
            if ([self isOptionalSubsection:subsection inSection:section]) {
                NSString *d = [self discriminatorOfSubsection:subsection inSection:section];
                if (d) {
                    d = [NSString stringWithFormat:@"section%@", d];
                    if ([self isIncludedSubsection:subsection inSection:section]) {
                        [disc setObject:[NSNumber numberWithBool:YES] forKey:d];
                    }
                    else {
                        [disc setObject:[NSNumber numberWithBool:NO] forKey:d];
                    }
                }
            }
        }
    }
    
    return disc;
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
            NSMutableDictionary *tabCopy = [tab mutableCopy];
            
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

- (NSArray *)tabsForRecipients:(NSArray *)recipients {
    NSArray *tabs = [self.formData valueForKey:kRBFormKeyTabs];
    NSMutableArray *flattenedTabs = [NSMutableArray array];
    
    NSMutableDictionary *rCount = [NSMutableDictionary dictionaryWithCapacity:2];
    
    // tabs stores an array of recipients, which contains an array of tabs for this recipient
    for (NSUInteger i = 0; i < MIN(recipients.count, tabs.count); i++) {
        NSDictionary *recipient = [recipients objectAtIndex:i];
        
        int c = [[rCount valueForKey:[recipient valueForKey:kRBFormKeyTabKind]] intValue];

        int k = 0;
        for (NSUInteger j = 0; j < tabs.count; j++) {
            NSArray *tabsForRecipient = [tabs objectAtIndex:j];
            
            // add additional information to tabs
            BOOL found = NO;
            for (NSDictionary *tab in tabsForRecipient) {
                if ([[recipient valueForKey:kRBFormKeyTabKind] isEqual:[tab valueForKey:kRBFormKeyTabKind]]) {
                    k++;
                    if (k <= c) {
                        break;
                    }
                    found = YES;
                    
                    NSMutableDictionary *tabCopy = [tab mutableCopy];
                    
                    // we always have document index 0
                    [tabCopy setValue:$I(0) forKey:kRBFormKeyTabDocumentIndex];
                    // we set a default-value for the recipient-index (increasing)
                    [tabCopy setValue:$I(i) forKey:kRBFormKeyTabRecipientIndex];
                    
                    // add object to flattened tabs
                    [flattenedTabs addObject:tabCopy];
                }
            }
            
            if (found) {
                break;
            }
        }
        
        [rCount setValue:[NSNumber numberWithInt:c+1] forKey:[recipient valueForKey:kRBFormKeyTabKind]];
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
    
    return [dict copy];
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
    
    NSArray *subFieldIDs = [fields componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
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

- (NSArray *)fieldWithID:(NSString *)fieldID inSection:(NSUInteger)section matches:(NSArray *)match {
    // index out of bounds
    if (section >= self.numberOfSections) {
        DDLogWarn(@"Index %d out of bounds", section);
        return nil;
    }
    
    NSArray *sectionData = [self.sections objectAtIndex:section];
    NSInteger index = [self indexOfObjectWithFieldID:fieldID inArray:sectionData];
    
    if (index != NSNotFound) {
        NSString *mapString = [[sectionData objectAtIndex:index] valueForKey:kRBFormKeyMapping];
        NSMutableCharacterSet *set = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
        [set formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
        [set removeCharactersInString:@"_"];
        NSArray *maps = [mapString componentsSeparatedByCharactersInSet:set];
        NSMutableArray *matches = [NSMutableArray array];
        for (NSString *map in maps) {
            if ([match containsObject:map]) {
                [matches addObject:map];
            }
        }
        return [matches count] > 0 ? matches : nil;
    }
    
    return nil;
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