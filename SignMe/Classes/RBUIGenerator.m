//
//  RBUIGenerator.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBUIGenerator.h"
#import "PSIncludes.h"
#import "UIControl+RBForm.h"
#import "RBRecipientsView.h"
#import "RBRecipient.h"
#import "DocuSignService.h"
#import "RBTextField.h"
#import "RBMusketeer+RBProperties.h"
#import "RBClient+RBProperties.h"
#import "RBFormLayoutData.h"
#import <AddressBook/AddressBook.h>
#import "ABAddressBook.h"
#import "ABPerson.h"
#import "ABMultiValue.h"
#import "ABPerson+RBMail.h"
#import "RegexKitLite.h"
#import "RBMultiValueTextField.h"


#define kRBColPadding               30.f
#define kRBInputFieldPadding        30.f
#define kRBRowHeight                35.f
#define kRBRowPadding               11.f


@interface RBUIGenerator ()

+ (UIView *)viewOfForm:(RBFormView *)formView 
           formFieldID:(NSString *)fieldID 
               section:(NSInteger)section 
            subsection:(NSInteger)subsection 
                  type:(Class)type;

- (void)setupFormCalculationForFields:(NSArray *)fields;
- (UIView *)recipientsViewForDocument:(RBDocument *)document form:(RBForm *)form;

- (UILabel *)labelWithText:(NSString *)text fieldID:(NSString *)fieldID alignment:(NSString *)alignment;

- (UILabel *)titleLabelWithText:(NSString *)text;

- (UIControl *)inputFieldWithID:(NSString *)fieldID 
                      inSection:(NSUInteger)section 
                        forForm:(RBForm *)form 
                         client:(RBClient *)client 
                   buttonGroups:(NSMutableDictionary *)buttonGroups
                   repeatGroups:(NSMutableDictionary *)repeatGroups;

- (UIControl *)inputFieldWithID:(NSString *)fieldID 
                          value:(id)value 
                       datatype:(NSString *)datatype 
                          width:(CGFloat)width 
                        subtype:(NSString *)subtype  
                      trueValue:(NSString *)trueValue 
                     falseValue:(NSString *)falseValue;

@end


@implementation RBUIGenerator

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBUIGenerator
////////////////////////////////////////////////////////////////////////

- (RBFormView *)viewWithFrame:(CGRect)frame form:(RBForm *)form client:(RBClient *)client document:(RBDocument *)document {
    NSMutableDictionary *buttonGroups = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *repeatGroups = [NSMutableDictionary dictionaryWithCapacity:5];
    
    RBFormView *view = [[RBFormView alloc] initWithFrame:frame form:form];
    
    // ================ iterate over all sections ================
    NSInteger numberOfPages = form.numberOfSections + 1; // +1 for RecipientsView
    for (NSUInteger section=0;section < form.numberOfSections; section++) {
        RBFormLayoutData *layoutData = [[RBFormLayoutData alloc] init];
        [view.formLayoutData setObject:layoutData forKey:$I(section*1000-1)];

        // ================ add a section label to the page ================
        NSString *sectionTitleText = [form displayNameOfSection:section];
        if (sectionTitleText && sectionTitleText.length > 0) {
            UILabel *sectionTitle = [self titleLabelWithText:sectionTitleText];
            sectionTitle.formSection = section;
            sectionTitle.formSubsection = -1;
            [view.innerScrollView addSubview:sectionTitle];
            layoutData.sectionHeader = sectionTitle;
        }
        
        if ([form isOptionalSection:section]) {
            BOOL included = [form isIncludedSection:section];
            UIButton *sectionBtn = (UIButton *)[self inputFieldWithID:@"sec" value:[NSNumber numberWithBool:included] 
                                                             datatype:@"Btn" width:36.0f subtype:@"checkbox" trueValue:nil falseValue:nil];
            sectionBtn.tag = 0;
            [view.innerScrollView addSubview:sectionBtn];
            layoutData.sectionHeaderButton = sectionBtn;
        }

        for (NSUInteger subsection=0; subsection < [form numberOfSubsectionsInSection:section]; subsection++) {
            layoutData = [[RBFormLayoutData alloc] init];
            [view.formLayoutData setObject:layoutData forKey:$I(section*1000+subsection)];
            
            // ================ add a subsection label to the page ================
            NSString *subSectionTitleText = [form displayNameOfSubsection:subsection inSection:section];
            if (subSectionTitleText && subSectionTitleText.length > 0) {
                UILabel *subSectionTitle = [self titleLabelWithText:subSectionTitleText];
                subSectionTitle.formSection = section;
                subSectionTitle.formSubsection = subsection;
                [view.innerScrollView addSubview:subSectionTitle];
                layoutData.sectionHeader = subSectionTitle;
            }
            
            if ([form isOptionalSubsection:subsection inSection:section]) {
                BOOL included = [form isIncludedSubsection:subsection inSection:section];
                UIButton *subSectionBtn = (UIButton *)[self inputFieldWithID:@"subsec" value:[NSNumber numberWithBool:included] 
                                                                    datatype:@"Btn" width:36.0f subtype:@"checkbox" trueValue:nil falseValue:nil];
                subSectionBtn.tag = 0;
                [view.innerScrollView addSubview:subSectionBtn];
                layoutData.sectionHeaderButton = subSectionBtn;
            }
            
            // ================ iterate over all fields in the section ================
            NSArray *fieldIDs = [form fieldIDsOfSubsection:subsection inSection:section];
            for (NSString *fieldID in fieldIDs) {
                // ================ load all values for creating form fields ================
                NSString *labelText = [form valueForKey:kRBFormKeyLabel ofField:fieldID inSection:section];
                NSString *datatype = [form valueForKey:kRBFormKeyDatatype ofField:fieldID inSection:section];
                CGFloat size = [[form valueForKey:kRBFormKeySize ofField:fieldID inSection:section] floatValue];
                NSString *position = [form valueForKey:kRBFormKeyPosition ofField:fieldID inSection:section];
                NSInteger col = [[form valueForKey:kRBFormKeyColumn ofField:fieldID inSection:section] intValue];
                NSInteger row = [[form valueForKey:kRBFormKeyRow ofField:fieldID inSection:section] intValue];
                NSInteger colspan = [[form valueForKey:kRBFormKeyColumnSpan ofField:fieldID inSection:section] intValue];
                NSInteger rowspan = [[form valueForKey:kRBFormKeyRowSpan ofField:fieldID inSection:section] intValue];
                NSString *alignment = [form valueForKey:kRBFormKeyAlignment ofField:fieldID inSection:section];
                NSString *textAlignment = [form valueForKey:kRBFormKeyTextFormat ofField:fieldID inSection:section];
                position = position == nil ? kRBFieldPositionBelow : position;
                
                // ================ create label ================
                UILabel *label = [self labelWithText:labelText fieldID:fieldID alignment:textAlignment];
                label.formDatatype = datatype;
                label.formSection = section;
                label.formSubsection = subsection; 
                label.formSize = size;
                label.formPosition = position;
                label.formColumn = col;
                label.formRow = row;
                label.formColumnSpan = colspan;
                label.formRowSpan = rowspan;
                if (!IsEmpty(labelText)) {
                    [view.innerScrollView addSubview:label];
                }
                [layoutData.labels addObject:label];
                
                // ================ create field ================
                UIControl *inputField = [self inputFieldWithID:fieldID inSection:section forForm:form client:client buttonGroups:buttonGroups repeatGroups:repeatGroups];
                inputField.formSection = section;
                inputField.formSubsection = subsection;
                inputField.formSize = size;
                inputField.formPosition = position;
                inputField.formColumn = col;
                inputField.formRow = row;
                inputField.formColumnSpan = colspan;
                inputField.formRowSpan = rowspan;
                inputField.formAlignment = alignment;
                
                if (![datatype isEqualToString:kRBFormDataTypeLabel]) {
                    [view.innerScrollView addSubview:inputField];
                }
                [layoutData.fields addObject:inputField];
            }
        }
    }
    
    // ================ Setup repeat control fields ================
    for (UIControl *ctrl in view.formControls) {
        if (ctrl.formRepeatField && [ctrl.formRepeatField length] > 0) {
            for (UIControl *varField in view.formControls) {
                if (varField == ctrl) continue;
                
                if ([varField.formID isEqualToString:ctrl.formRepeatField]) {
                    [varField addObserver:ctrl forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:@"repeatgroup"];
                    NSMutableArray *observers = varField.formFieldObservers;
                    if (!observers) {
                        observers = [NSMutableArray arrayWithCapacity:2];
                        varField.formFieldObservers = observers;
                    }
                    [observers addObject:ctrl];
                }
            }
        }
    }
    
    // ================ Create the responder chain ================
    [view setupResponderChain];
    
    // ================ Add Calculation Evaluators ================
    [self setupFormCalculationForFields:view.formControls];

    // ================ Add RecipientsView ================
    [view.innerScrollView addSubview:[self recipientsViewForDocument:document form:form]];
    
    // ================ update pageControl on view (isn't displayed yet, because it is not a subview of the scrollView) ================
    view.pageControl.numberOfPages = numberOfPages;
    
    // ================ enable vertical scrolling ================
    [view setInnerScrollViewSize:CGSizeMake(PSAppWidth()*numberOfPages, 1000)];
    view.contentSize = CGSizeMake(PSAppWidth(), 1000 + 10.f);
    
    return view;
}


- (void)setupFormCalculationForFields:(NSArray *)fields {
    for (UIControl *ctrl in fields) {
        if (ctrl.formCalculate && [ctrl.formCalculate length] > 0) {
            NSMutableDictionary *calcVarFields = [NSMutableDictionary dictionary];
            NSArray *comps = [ctrl.formCalculate arrayOfCaptureComponentsMatchedByRegex:@"\\$([a-zA-Z_0-9]+)"];
            for (NSArray *capGroups in comps) {
                NSString *varName = [capGroups objectAtIndex:1];
                for (UIControl *varField in fields) {
                    if (varField == ctrl) continue;
                    
                    if ([[varField.formID stringByReplacingOccurrencesOfRegex:@"[^a-zA-Z_0-9]" withString:@""] isEqualToString:varName]) {
                        NSMutableArray *observers = varField.formFieldObservers;
                        if (!observers) {
                            observers = [NSMutableArray arrayWithCapacity:2];
                            varField.formFieldObservers = observers;
                        }
                        [observers addObject:ctrl];
                        if ([varField isKindOfClass:[UITextField class]] || [varField isKindOfClass:[RBMultiValueTextField class]]) {
                            [varField addObserver:ctrl forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:@"calculate"];
                        }
                        else {
                            [varField addObserver:ctrl forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"calculate"];
                        }
                        [calcVarFields setObject:varField forKey:varName];
                    }
                }
            }
            if ([ctrl isKindOfClass:[RBTextField class]]) {
                ctrl.enabled = NO;
                ((RBTextField *)ctrl).calcVarFields = calcVarFields;
            }
            if ([ctrl isKindOfClass:[RBMultiValueTextField class]]) {
                for (UIControl *txtField in ((RBMultiValueTextField *)ctrl).textFields) {
                    txtField.enabled = NO;
                }
                ((RBMultiValueTextField *)ctrl).calcVarFields = calcVarFields;
            }
        }
    }
    
    for (UIControl *ctrl in fields) {
        if ([ctrl isKindOfClass:[RBTextField class]]) {
            [(RBTextField *)ctrl calculate];
        }
        if ([ctrl isKindOfClass:[RBMultiValueTextField class]]) {
            [(RBMultiValueTextField *)ctrl calculate];
        }
    }
}


- (UIView *)recipientsViewForDocument:(RBDocument *)document form:(RBForm *)form {
    RBRecipientsView *recipientsView = [[RBRecipientsView alloc] initWithFrame:CGRectMake(form.numberOfSections*PSAppWidth(), 0.f, 1024.f, 475.f)];
    
    NSMutableArray *recipients = [NSMutableArray array];
    if (document.recipients == nil || [document.recipients count] == 0) {
        RBMusketeer *musketeer = [RBMusketeer loadEntity];
        NSArray *people = [[ABAddressBook sharedAddressBook] allPeople];
        ABPerson *abMusketeer = nil;
        for (ABPerson *person in people) {
            if ([[person getFirstName] isEqualToStringIgnoringCase:musketeer.firstname] && 
                [[person getLastName] isEqualToStringIgnoringCase:musketeer.lastname]) {
                abMusketeer = person;
                break;
            }
        }
        if (abMusketeer == nil) {
            NSError *error;
            abMusketeer = [[ABPerson alloc] init];
            if (musketeer.firstname) {
                [abMusketeer setValue:musketeer.firstname forProperty:kABPersonFirstNameProperty error:nil];
            }
            if (musketeer.lastname) {
                [abMusketeer setValue:musketeer.lastname forProperty:kABPersonLastNameProperty error:nil];
            }
            [[ABAddressBook sharedAddressBook] addRecord:abMusketeer error:&error];
            [[ABAddressBook sharedAddressBook] save:&error];
        }
        
        ABMultiValue *emails = [abMusketeer valueForProperty:kABPersonEmailProperty];
        if (emails == nil || [emails indexOfValue:musketeer.email] == (NSUInteger)-1L) {
            NSError *error;
            if (emails == nil) {
                emails = [[ABMutableMultiValue alloc] initWithPropertyType:kABPersonEmailProperty];
            }
            else {
                emails = [emails mutableCopy];
            }
            [(ABMutableMultiValue *)emails addValue:musketeer.email withLabel:(NSString *)kABWorkLabel identifier:nil];
            [abMusketeer setValue:emails forProperty:kABPersonEmailProperty error:nil];
            [[ABAddressBook sharedAddressBook] save:&error];
            
            emails = [abMusketeer valueForProperty:kABPersonEmailProperty];
        }
        ABMultiValueIdentifier identifier;
        for (int i = 0; i < [emails count]; i++) {
            if ([[emails valueAtIndex:i] isEqualToStringIgnoringCase:musketeer.email]) {
                identifier = [emails identifierAtIndex:i];
                break;
            }
        }
        NSMutableDictionary *personDict = XMDICT($I(abMusketeer.recordID), kRBRecipientPersonID, $I(identifier), kRBRecipientEmailID, $I(kRBRecipientTypeInPerson), kRBRecipientType, @"RB", kRBRecipientKind);
        [recipients addObject:personDict];
    }
 
    for (RBRecipient *recipient in [document.recipients allObjects]) {
        NSMutableDictionary *dictionaryRepresentation = [[recipient dictionaryWithValuesForKeys:XARRAY(kRBRecipientPersonID, kRBRecipientEmailID, kRBRecipientCode, kRBRecipientIDCheck, kRBRecipientType, kRBRecipientOrder, kRBRecipientKind)] mutableCopy];
        [recipients addObject:dictionaryRepresentation];
    }
    
    recipientsView.tabs = [form tabsWithType:@"SignHere"];
    recipientsView.maxNumberOfRecipients = [form numberOfTabsWithType:@"SignHere"];
    recipientsView.recipients = recipients;
    recipientsView.subject = document.subject;
    recipientsView.useRoutingOrder = [document.obeyRoutingOrder boolValue];

    return recipientsView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Resizing
////////////////////////////////////////////////////////////////////////

+ (void)resizeFormView:(RBFormView *)formView withForm:(RBForm *)form {
    CGFloat realViewWidth = formView.bounds.size.width;
    CGFloat realViewHeight = formView.bounds.size.height;
    CGFloat maxHeight = realViewHeight;
    NSInteger numberOfPages = form.numberOfSections + 1; // +1 for RecipientsView

    UIView *label;
    UIView *control;
    CGPoint origin = CGPointZero;
    
    // iterate over all sections
    for (NSUInteger section=0; section < form.numberOfSections; section++) {
        origin.x = kRBColPadding + section * realViewWidth;
        origin.y = kRBRowPadding;
        
        RBFormLayoutData *layoutData = [formView.formLayoutData objectForKey:$I(section*1000-1)];
        layoutData.formOrigin = origin;
        layoutData.formWidth = realViewWidth - 2 * kRBColPadding;
        [layoutData calculateLayout];
        
        label = layoutData.sectionHeader;
        if (label) {
            label.frame = [layoutData rectForSectionHeader];
        }
        
        control = layoutData.sectionHeaderButton;
        if (control) {
            control.frame = [layoutData rectForSectionHeaderButton];
        }
        
        if (label || control) {
            origin.y += kRBRowHeight + kRBRowPadding;
        }
        
        for (NSUInteger subsection=0; subsection < [form numberOfSubsectionsInSection:section]; subsection++) {
            layoutData = [formView.formLayoutData objectForKey:$I(section*1000+subsection)];
            layoutData.formWidth = realViewWidth - 2 * kRBColPadding;
            layoutData.formOrigin = origin;
            [layoutData calculateLayout];

            // add a section label to the page
            label = layoutData.sectionHeader;
            if (label) {
                label.frame = [layoutData rectForSectionHeader];
            }

            control = layoutData.sectionHeaderButton;
            if (control) {
                control.frame = [layoutData rectForSectionHeaderButton];
            }

            for (int i = 0; i < layoutData.labels.count; i++) {
                label = [layoutData.labels objectAtIndex:i];
                label.frame = [layoutData rectForLabelAtIndex:i];
                
                control = [layoutData.fields objectAtIndex:i];
                control.frame = [layoutData rectForFieldAtIndex:i];

                maxHeight = MAX(maxHeight, control.frameBottom);
            }
            
            origin.y = control.frameBottom + kRBRowPadding;
        }
    }
    
    for (UIView *v in formView.innerScrollView.subviews) {
        if ([v isKindOfClass:[RBRecipientsView class]]) {
            v.frame = CGRectMake(form.numberOfSections*realViewWidth, 0.f, realViewWidth, realViewHeight);
            break;
        }
    }
    
    // enable vertical scrolling
    [formView setInnerScrollViewSize:CGSizeMake(realViewWidth*numberOfPages, maxHeight)];
    formView.contentSize = CGSizeMake(realViewWidth, maxHeight + 10.f);
    [formView.innerScrollView setContentOffset:CGPointMake(formView.pageControl.currentPage*formView.bounds.size.width,formView.innerScrollView.contentOffset.y) animated:NO];
}


+ (UIView *)viewOfForm:(RBFormView *)formView formFieldID:(NSString *)fieldID section:(NSInteger)section subsection:(NSInteger)subsection type:(Class)type {
    // retreive all subviews, that are meant to be controls
    return [[formView.innerScrollView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if (![evaluatedObject respondsToSelector:@selector(formID)]) return NO;
        if ([evaluatedObject isKindOfClass:type] && (!fieldID || [[evaluatedObject formID] isEqualToString:fieldID]) && [evaluatedObject formSection] == section && [evaluatedObject formSubsection] == subsection) {
            return YES;
        }
        
        return NO;
    }]] firstObject];
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)labelWithText:(NSString *)text fieldID:(NSString *)fieldID alignment:(NSString *)alignment {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000.f, kRBRowHeight)];
    label.formID = fieldID;
    
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kRBColorMain;
    label.font = [UIFont fontWithName:kRBFontName size:16];
    if ([alignment isEqualToString:@"center"]) {
        label.textAlignment = UITextAlignmentCenter;
    }
    if ([alignment isEqualToString:@"right"]) {
        label.textAlignment = UITextAlignmentRight;
    }
    else {
        label.textAlignment = UITextAlignmentLeft;
    }
    label.text = text;
    [label sizeToFit];
    label.numberOfLines = 0;
    label.frameHeight = kRBRowHeight;
    label.formAlignment = alignment;
    
    return label;
}

- (UILabel *)titleLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000.f, kRBRowHeight)];
    
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kRBColorDetail;
    label.font = [UIFont fontWithName:kRBFontName size:20];
    label.textAlignment = UITextAlignmentLeft;
    label.text = [text uppercaseString];
    [label sizeToFit];
    label.numberOfLines = 0;
    label.frameHeight = kRBRowHeight + 10.0f;
    
    return label;
}


- (UIControl *)inputFieldWithID:(NSString *)fieldID 
                          value:(id)value 
                       datatype:(NSString *)datatype 
                          width:(CGFloat)width 
                        subtype:(NSString *)subtype  
                      trueValue:(NSString *)trueValue 
                     falseValue:(NSString *)falseValue {
    UIControl *control = [UIControl controlWithID:fieldID datatype:datatype size:CGSizeMake(width, kRBRowHeight) subtype:subtype repeatGroup:nil showRepeatButton:NO];
    
    control.formTrueValue = trueValue;
    control.formFalseValue = falseValue;

    [control configureControlUsingValue:value];
    
    return control;
}

- (UIControl *)inputFieldWithID:(NSString *)fieldID 
                      inSection:(NSUInteger)section 
                        forForm:(RBForm *)form 
                         client:(RBClient *)client 
                   buttonGroups:(NSMutableDictionary *)buttonGroups
                   repeatGroups:(NSMutableDictionary *)repeatGroups {
    NSString *datatype = [form valueForKey:kRBFormKeyDatatype ofField:fieldID inSection:section];
    NSString *subtype = [form valueForKey:kRBFormKeySubtype ofField:fieldID inSection:section];
    NSString *repeatGroup = [form valueForKey:kRBFormKeyRepeatGroup ofField:fieldID inSection:section];
    BOOL showRepeatButton = [[form valueForKey:kRBFormKeyShowRepeatButton ofField:fieldID inSection:section] boolValue];

    UIControl *control = [UIControl controlWithID:fieldID datatype:datatype size:CGSizeMake(100.0f, kRBRowHeight) subtype:subtype repeatGroup:repeatGroup showRepeatButton:showRepeatButton];
    
    control.formDatatype = datatype;
    control.formValidationRegEx = [form valueForKey:kRBFormKeyValidationRegEx ofField:fieldID inSection:section];
    control.formValidationMsg = [form valueForKey:kRBFormKeyValidationMsg ofField:fieldID inSection:section];
    control.formTextFormat = [form valueForKey:kRBFormKeyTextFormat ofField:fieldID inSection:section];
    control.formShowZero = [[form valueForKey:kRBFormKeyShowZero ofField:fieldID inSection:section] boolValue];
    control.formCalculate = [form valueForKey:kRBFormKeyCalculate ofField:fieldID inSection:section];
    control.formRepeatField = [form valueForKey:kRBFormKeyRepeatField ofField:fieldID inSection:section];
    
    // ================ setup control value ================
    control.formTrueValue = [form valueForKey:kRBFormKeyTrueValue ofField:fieldID inSection:section];
    control.formFalseValue = [form valueForKey:kRBFormKeyFalseValue ofField:fieldID inSection:section];

    // ================ setup drop down lists ================
    if (([control isKindOfClass:[RBTextField class]] || [control isKindOfClass:[RBMultiValueTextField class]]) && [subtype isEqualToString:@"list"]) {
        NSString *listID = [form valueForKey:kRBFormKeyListID ofField:fieldID inSection:section];
        if ([listID isEqualToString:@"states"]) {
            ((RBTextField *)control).items = stateList;
        }
        else if ([listID isEqualToString:@"countries"]) {
            ((RBTextField *)control).items = countryList;
        }
        else {
            ((RBTextField *)control).items = [form listForID:listID];
        }
    }
    
    id value = [form valueForKey:kRBFormKeyValue ofField:fieldID inSection:section];
    if (value == nil || [value isKindOfClass:[NSString class]]) {
        // ================ match values for client if there is no value set ================
        if (IsEmpty(value)) {
            NSArray *mappings = [form fieldWithID:fieldID inSection:section matches:[RBClient propertyNamesForMapping]];
            if (mappings) {
                NSMutableString *val = [NSMutableString string];
                for (int i = 0; i < mappings.count; i++) {
                    NSString *mappingValue = [client valueForKey:[mappings objectAtIndex:i]];
                    if (mappingValue) {
                        [val appendString:mappingValue];
                        if (i < mappings.count - 1) {
                            [val appendString:@" "];
                        }
                    }
                }
                value = val;
            }
        }
        
        // ================ match values for musketeer if there is no value set ================
        if (IsEmpty(value)) {
            NSMutableArray *tmp = [NSMutableArray array];
            for (NSString *prop in [RBMusketeer propertyNamesForMapping]) {
                [tmp addObject:[NSString stringWithFormat:@"musketeer_%@", prop]];
            }
            
            NSArray *mappings = [form fieldWithID:fieldID inSection:section matches:tmp];
            if (mappings) {
                NSMutableString *val = [NSMutableString string];
                for (int i = 0; i < mappings.count; i++) {
                    NSString *key = [[mappings objectAtIndex:i] substringFromIndex:[@"musketeer_" length]];
                    NSString *mappingValue = [[RBMusketeer loadEntity] valueForKey:key];
                    if (mappingValue) {
                        [val appendString:mappingValue];
                        if (i < mappings.count - 1) {
                            [val appendString:@" "];
                        }
                    }
                }
                value = val;
            }
        }
    }
    [control configureControlUsingValue:value];
    
    // ================ set buttons for button group to implement radio or toggle buttons ================
    NSString *buttonGroup = [form valueForKey:kRBFormKeyButtonGroup ofField:fieldID inSection:section];
    if ([control isKindOfClass:[UIControl class]] && [subtype isEqualToString:@"radio"] && buttonGroup) {
        NSMutableArray *btnGrp = [buttonGroups objectForKey:buttonGroup];
        if (!btnGrp) {
            btnGrp = [NSMutableArray arrayWithCapacity:2];
            [buttonGroups setObject:btnGrp forKey:buttonGroup];
        }
        [btnGrp addObject:control];
        control.formButtonGroup = btnGrp;
    }
    
    // ================ set repeat groups for adding and removing multiple fields at once ================
    if ([control isKindOfClass:[RBMultiValueTextField class]] && repeatGroup) {
        NSMutableArray *rptGrp = [repeatGroups objectForKey:repeatGroup];
        if (!rptGrp) {
            rptGrp = [NSMutableArray arrayWithCapacity:2];
            [repeatGroups setObject:rptGrp forKey:repeatGroup];
        }
        [rptGrp addObject:control];
        control.formRepeatGroup = rptGrp;
    }

    return control;
}


@end
