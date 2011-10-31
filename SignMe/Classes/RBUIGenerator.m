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

#define kRBColPadding               30.f
#define kRBInputFieldPadding        30.f
#define kRBRowHeight                35.f
#define kRBRowPadding               11.f


@interface RBUIGenerator ()

@property (nonatomic, assign) RBTextField *previousTextField;

+ (UIView *)viewOfForm:(RBFormView *)formView 
           formFieldID:(NSString *)fieldID 
               section:(NSInteger)section 
            subsection:(NSInteger)subsection 
                  type:(Class)type;

- (UILabel *)labelWithText:(NSString *)text 
                   fieldID:(NSString *)fieldID;

- (UILabel *)titleLabelWithText:(NSString *)text;

- (UIControl *)inputFieldWithID:(NSString *)fieldID 
                          value:(NSString *)value 
                       datatype:(NSString *)datatype 
                          width:(CGFloat)width 
                        subtype:(NSString *)subtype;

- (void)createNextResponderChainWithControl:(UIControl *)control 
                                     inView:(RBFormView *)view;

@end


@implementation RBUIGenerator

@synthesize previousTextField = previousTextField_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBUIGenerator
////////////////////////////////////////////////////////////////////////

- (RBFormView *)viewWithFrame:(CGRect)frame form:(RBForm *)form client:(RBClient *)client document:(RBDocument *)document {
    RBFormView *view = [[[RBFormView alloc] initWithFrame:frame form:form] autorelease];
    
    // ================ iterate over all sections ================
    NSInteger numberOfPages = form.numberOfSections + 1; // +1 for RecipientsView
    for (NSUInteger section=0;section < form.numberOfSections; section++) {
        RBFormLayoutData *layoutData = [[[RBFormLayoutData alloc] init] autorelease];
        [view.formLayoutData setObject:layoutData forKey:$I(section*1000-1)];

        // a new section starts with a new "first" textfield
        self.previousTextField = nil;
        
        // ================ add a section label to the page ================
        NSString *sectionTitleText = [form displayNameOfSection:section];
        if (sectionTitleText && sectionTitleText.length > 0) {
            UILabel *sectionTitle = [self titleLabelWithText:sectionTitleText];
            sectionTitle.formSection = section;
            sectionTitle.formSubsection = -1;
            [view.innerScrollView addSubview:sectionTitle];
            layoutData.sectionHeader = sectionTitle;
        }

        for (NSUInteger subsection=0; subsection < [form numberOfSubsectionsInSection:section]; subsection++) {
            layoutData = [[[RBFormLayoutData alloc] init] autorelease];
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
            
            // ================ iterate over all fields in the section ================
            NSArray *fieldIDs = [form fieldIDsOfSubsection:subsection inSection:section];
            for (NSString *fieldID in fieldIDs) {
                // ================ load all values for creating form fields ================
                NSString *labelText = [form valueForKey:kRBFormKeyLabel ofField:fieldID inSection:section];
                NSString *value = [form valueForKey:kRBFormKeyValue ofField:fieldID inSection:section];
                NSString *datatype = [form valueForKey:kRBFormKeyDatatype ofField:fieldID inSection:section];
                CGFloat size = [[form valueForKey:kRBFormKeySize ofField:fieldID inSection:section] floatValue];
                NSString *position = [form valueForKey:kRBFormKeyPosition ofField:fieldID inSection:section];
                NSString *subtype = [form valueForKey:kRBFormKeySubtype ofField:fieldID inSection:section];
                NSInteger col = [[form valueForKey:kRBFormKeyColumn ofField:fieldID inSection:section] intValue];
                NSInteger row = [[form valueForKey:kRBFormKeyRow ofField:fieldID inSection:section] intValue];
                NSInteger colspan = [[form valueForKey:kRBFormKeyColumnSpan ofField:fieldID inSection:section] intValue];
                NSInteger rowspan = [[form valueForKey:kRBFormKeyRowSpan ofField:fieldID inSection:section] intValue];
                position = position == nil ? kRBFieldPositionBelow : position;
                
                // ================ match values for client if there is no value set ================
                if (IsEmpty(value)) {
                    NSArray *mappings = [form fieldWithID:fieldID inSection:section matches:[RBClient propertyNamesForMapping]];
                    if (mappings) {
                        NSMutableString *val = [NSMutableString string];
                        for (int i = 0; i < mappings.count; i++) {
                            [val appendString:[client valueForKey:[mappings objectAtIndex:i]]];
                            if (i < mappings.count - 1) {
                                [val appendString:@" "];
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
                
                // ================ create label ================
                UILabel *label = [self labelWithText:labelText fieldID:fieldID];
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
                UIControl *inputField = [self inputFieldWithID:fieldID value:value datatype:datatype width:100.0f subtype:subtype];
                inputField.formDatatype = datatype;
                inputField.formSection = section;
                inputField.formSubsection = subsection;
                inputField.formSize = size;
                inputField.formPosition = position;
                inputField.formColumn = col;
                inputField.formRow = row;
                inputField.formColumnSpan = colspan;
                inputField.formRowSpan = rowspan;
                
                if ([inputField isKindOfClass:[RBTextField class]] && [subtype isEqualToString:@"list"]) {
                    NSString *listID = [form valueForKey:kRBFormKeyListID ofField:fieldID inSection:section];
                    if ([listID isEqualToString:@"states"]) {
                        ((RBTextField *)inputField).items = stateList;
                    }
                    else if ([listID isEqualToString:@"countries"]) {
                        ((RBTextField *)inputField).items = countryList;
                    }
                    else {
                        ((RBTextField *)inputField).items = [form listForID:listID];
                    }
                }
                
                if (![datatype isEqualToString:kRBFormDataTypeLabel]) {
                    [view.innerScrollView addSubview:inputField];
                }
                [layoutData.fields addObject:inputField];

                // ================ Setup chain to go from one textfield to the next ================
                [self createNextResponderChainWithControl:inputField inView:view];
            }
        }
    }
    
    // ================ Add RecipientsView ================
    RBRecipientsView *recipientsView = [[[RBRecipientsView alloc] initWithFrame:CGRectMake(form.numberOfSections*PSAppWidth(), 0.f, 1024.f, 475.f)] autorelease];
    
    for (RBRecipient *recipient in [document.recipients allObjects]) {
        NSDictionary *dictionaryRepresentation = [recipient dictionaryWithValuesForKeys:XARRAY(kRBRecipientPersonID, kRBRecipientEmailID)];
        [recipientsView.recipients addObject:dictionaryRepresentation];
    }
    
    recipientsView.maxNumberOfRecipients = form.numberOfRecipients;
    recipientsView.subject = document.subject;
    recipientsView.useRoutingOrder = [document.obeyRoutingOrder boolValue];
    [view.innerScrollView addSubview:recipientsView];
    
    // ================ update pageControl on view (isn't displayed yet, because it is not a subview of the scrollView) ================
    view.pageControl.numberOfPages = numberOfPages;
    
    // ================ enable vertical scrolling ================
    [view setInnerScrollViewSize:CGSizeMake(PSAppWidth()*numberOfPages, 1000)];
    view.contentSize = CGSizeMake(PSAppWidth(), 1000 + 10.f);
    
    return view;
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
    [formView.innerScrollView setContentOffset:CGPointMake(formView.pageControl.currentPage*formView.bounds.size.width,0) animated:YES];
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

- (UILabel *)labelWithText:(NSString *)text fieldID:(NSString *)fieldID {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000.f, kRBRowHeight)] autorelease];
    label.formID = fieldID;
    
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kRBColorMain;
    label.font = [UIFont fontWithName:kRBFontName size:16];
    label.textAlignment = UITextAlignmentLeft;
    label.text = text;
    [label sizeToFit];
    label.numberOfLines = 0;
    label.frameHeight = kRBRowHeight;
    
    return label;
}

- (UILabel *)titleLabelWithText:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000.f, kRBRowHeight)] autorelease];
    
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

- (UIControl *)inputFieldWithID:(NSString *)fieldID value:(NSString *)value datatype:(NSString *)datatype width:(CGFloat)width subtype:(NSString *)subtype {
    UIControl *control = [UIControl controlWithID:fieldID datatype:datatype size:CGSizeMake(width, kRBRowHeight) subtype:subtype];
    
    [control configureControlUsingValue:value];
    
    return control;
}

- (void)createNextResponderChainWithControl:(UIControl *)control inView:(RBFormView *)view {
    if ([control isKindOfClass:[RBTextField class]]) {
        RBTextField *textField = (RBTextField *)control;
        
        textField.delegate = view;

        self.previousTextField.nextField = (UITextField *)control;
        textField.prevField = self.previousTextField;
        self.previousTextField = textField;
    }
}

@end
