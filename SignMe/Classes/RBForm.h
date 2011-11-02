//
//  RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//


// keys for plist
#define kRBFormKeyDisplayName       @"displayName"      // name of the form to display
#define kRBFormKeySection           @"sections"         // section the field appears in in the iPad App
#define kRBFormKeyID                @"id"               // id of the field
#define kRBFormKeyLabel             @"label"            // label of the field
#define kRBFormKeyDatatype          @"datatype"         // datatype decides which UIControl is displayed
#define kRBFormKeyValue             @"value"            // set value of the field
#define kRBFormKeySectionInfos      @"sectionDisplayInfos"            // section display infos
#define kRBFormKeySubsections       @"subsections"      // section display infos
#define kRBFormKeyFields            @"fields"           // fields of subsection
#define kRBFormKeySize              @"size"             // size of a field in percent of form width
#define kRBFormKeyPosition          @"position"         // position of a field relative to its label
#define kRBFormKeyColumn            @"col"              // column of a field 
#define kRBFormKeyRow               @"row"              // row of a field 
#define kRBFormKeyColumnSpan        @"colspan"          // column span of a field 
#define kRBFormKeyRowSpan           @"rowspan"          // row span of a field 
#define kRBFormKeySubtype           @"subtype"          // subtype refines which UIControl is displayed
#define kRBFormKeyListID            @"listid"           // refers to the items to display
#define kRBFormKeyLists             @"lists"            // set of item lists
#define kRBFormKeyItems             @"items"            // set of items

#define kRBFormKeyTabs              @"tabs"             // tabs for signing in DocuSign
#define kRBFormKeyTabPage           @"page"             // the page a tab should appear
#define kRBFormKeyTabX              @"x"                // the x-position the tab should appear
#define kRBFormKeyTabY              @"y"                // the y-position the tab should appear
#define kRBFormKeyTabType           @"type"             // the type of the tab (Initial/Sign)
#define kRBFormKeyTabLabel          @"label"            // the label of the tab 
#define kRBFormKeyTabDocumentIndex  @"documentIndex"    // is always 0 in our case
#define kRBFormKeyTabRecipientIndex @"recipientIndex"   // increasing number that matches current recipient

#define kRBFormKeyMapping           @"mapping"          // the mapping of the field to the client (name, address, ...)
#define kRBFormKeyMappingNone       @""
#define kRBFormKeyMappingName       @"name"
#define kRBFormKeyMappingCompany    @"company"
#define kRBFormKeyMappingStreet     @"street"
#define kRBFormKeyMappingCity       @"city"
#define kRBFormKeyMappingZip        @"zip"

// datatypes for form creation
#define kRBFormDataTypeCheckbox     @"Btn"
#define kRBFormDataTypeTextField    @"Tx"
#define kRBFormDataTypeLabel        @"Lb"
#define kRBFormDataTypeChoice       @"Ch"
#define kRBFormDataTypeSignature    @"Sig"

// position types
#define kRBFieldPositionBelow       @"below"
#define kRBFieldPositionRight       @"right"

// tag that determines that this control is a form control
#define kRBFormControlTag           45321

typedef enum {
    RBFormStatusNew = 0,
    RBFormStatusPreSignature,
    RBFormStatusSigned,
    RBFormStatusCount,
    RBFormStatusUnknown = -1
} RBFormStatus;


NSString *RBFormStatusStringRepresentation(RBFormStatus formStatus);
RBFormStatus RBFormStatusForIndex(NSUInteger index);
NSString *RBUpdateStringForFormStatus(RBFormStatus formStatus);


@interface RBForm : NSObject 

// Creation

+ (RBForm *)emptyFormWithName:(NSString *)name;
+ (NSArray *)allEmptyForms;

- (id)initWithName:(NSString *)name;
- (id)initWithPath:(NSString *)path name:(NSString *)name;

/** All fields stored in the plist, e.g. name, sections, ... */
 @property (nonatomic, retain, readonly) NSDictionary *formData;

// Convenience Getters

/** Name of the form, e.g. W9 */
@property (nonatomic, copy, readonly) NSString *name;
/** Path to the plist-file of the form (including values) */
@property (nonatomic, readonly) NSString *fileName;
/** Sections for input view */
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSArray *sectionDisplayInfos;
/** Tabs for DocuSign */
@property (nonatomic, readonly) NSUInteger numberOfTabs;
@property (nonatomic, readonly) NSUInteger numberOfRecipients;
@property (nonatomic, readonly) NSArray *tabs;
/** Returns a dictionary with key-value pairs (ID/Value) for the pdf-form */
@property (nonatomic, readonly) NSDictionary *PDFDictionary;

@property (nonatomic, readonly) NSString *displayName;

/** all field IDs of a section */
- (NSArray *)fieldIDsOfSection:(NSUInteger)section;
- (NSArray *)fieldIDsOfSubsection:(NSUInteger)subsection inSection:(NSUInteger)section;

- (NSUInteger)numberOfSubsectionsInSection:(NSUInteger)section;

- (NSString *)displayNameOfSection:(NSUInteger)section;
- (NSString *)displayNameOfSubsection:(NSUInteger)subsection inSection:(NSUInteger)section;

- (NSUInteger)numberOfTabsWithType:(NSString *)tabType;
- (NSArray *)tabsWithType:(NSString *)tabType;
- (NSArray *)tabsForNumberOfRecipients:(NSUInteger)numberOfRecipients;

/** Retreive/set values of the dictionary stored in a specific section */
- (id)valueForKey:(NSString *)key ofField:(NSString *)fieldID inSection:(NSUInteger)section;
- (void)setValue:(id)value forField:(NSString *)fieldID inSection:(NSUInteger)section;

/** check if a field matches a specified purpose (e.g. name, street, address, ... */
- (NSArray *)fieldWithID:(NSString *)fieldID inSection:(NSUInteger)section matches:(NSArray *)match;

- (NSArray *)listForID:(NSString *)listID;

/** writes the data to a plist-file */
- (BOOL)saveAsDocument;
- (BOOL)saveAsDocumentWithName:(NSString *)name;

@end