//
//  RBForm.h
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kRBFormKeyID        @"id"
#define kRBFormKeyLabel     @"label"
#define kRBFormKeyOrderID   @"order"
#define kRBFormKeyDatatype  @"datatype"
#define kRBFormKeyValue     @"value"

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
+ (NSArray *)allForms;
+ (void)copyFormsFromBundle;

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

/** Retreive/set values of the dictionary stored in a specific section */
- (id)valueForKey:(NSString *)key ofField:(NSString *)fieldID inSection:(NSUInteger)section;
- (void)setValue:(id)value forField:(NSString *)fieldID inSection:(NSUInteger)section;

// Document
- (BOOL)saveAsDocument;

@end