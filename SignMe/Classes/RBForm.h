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

#define kRBFormKeyTabs              @"tabs"             // tabs for signing in DocuSign
#define kRBFormKeyTabPage           @"page"             // the page a tab should appear
#define kRBFormKeyTabX              @"x"                // the x-position the tab should appear
#define kRBFormKeyTabY              @"y"                // the y-position the tab should appear
#define kRBFormKeyTabType           @"type"             // the type of the tab (Initial/Sign)

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

// tag that determines that this control is a form control
#define kRBFormControlTag           45321

typedef enum {
    RBFormStatusNew = 0,
    RBFormStatusPreSignature,
    RBFormStatusSigned,
    RBFormStatusCount,
    RBFormStatusUnknown = -1
} RBFormStatus;


NSString *RBFormStatusStringRepresentation(RBFormStatus formType);
RBFormStatus RBFormStatusForIndex(NSUInteger index);


@interface RBForm : NSObject 

// Creation

+ (RBForm *)emptyFormWithName:(NSString *)name;
+ (NSArray *)allEmptyForms;

- (id)initWithName:(NSString *)name;
- (id)initWithPath:(NSString *)path;

/** All fields stored in the plist, e.g. name, sections, ... */
 @property (nonatomic, retain, readonly) NSDictionary *formData;

// Convenience Getters

/** Name of the form, e.g. W9 */
@property (nonatomic, copy, readonly) NSString *name;
/** Path to the plist-file of the form (including values) */
@property (nonatomic, readonly) NSString *filePath;
/** Sections for input view */
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly) NSArray *sections;
/** Returns a dictionary with key-value pairs (ID/Value) for the pdf-form */
@property (nonatomic, readonly) NSDictionary *PDFDictionary;

@property (nonatomic, readonly) NSString *displayName;

/** all field IDs of a section */
- (NSArray *)fieldIDsOfSection:(NSUInteger)section;

/** Retreive/set values of the dictionary stored in a specific section */
- (id)valueForKey:(NSString *)key ofField:(NSString *)fieldID inSection:(NSUInteger)section;
- (void)setValue:(id)value forField:(NSString *)fieldID inSection:(NSUInteger)section;

/** check if a field matches a specified purpose (e.g. name, street, address, ... */
- (BOOL)fieldWithID:(NSString *)fieldID inSection:(NSUInteger)section matches:(NSString *)match;

/** writes the data to a plist-file */
- (BOOL)saveAsDocument;

@end