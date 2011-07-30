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
#import "RBClient+RBProperties.h"

#define kRBLabelX                   50.f
#define kRBInputFieldX              435.f
#define kRBInputFieldWidth          560.f
#define kRBRowHeight                35.f
#define kRBRowPadding               11.f


@interface RBUIGenerator ()

- (UILabel *)labelWithText:(NSString *)text;
- (UIControl *)inputFieldWithID:(NSString *)fieldID value:(NSString *)value datatype:(NSString *)datatype;

@end

@implementation RBUIGenerator

- (RBFormView *)viewWithForm:(RBForm *)form client:(RBClient *)client frame:(CGRect)frame {
    RBFormView *view = [[[RBFormView alloc] initWithFrame:frame] autorelease];
    UIView *topLabel = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kRBRowHeight)] autorelease];
    UIView *topInputField = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kRBRowHeight)] autorelease];
    CGFloat realViewWidth = [[UIScreen mainScreen] applicationFrame].size.height; // Because of landscape we have to switch width/height
    CGFloat realViewHeight = view.bounds.size.width;
    CGFloat maxHeight = realViewHeight;
    NSInteger numberOfPages = form.numberOfSections + 1; // +1 for RecipientsView
    
    // iterate over all sections
    for (NSUInteger section=0;section < form.numberOfSections; section++) {
        NSArray *fieldIDs = [form fieldIDsOfSection:section];
        
        // position top views on corresponding page of scrollView
        topLabel.frameTop =  - kRBRowHeight - kRBRowPadding;
        topLabel.frameLeft = kRBLabelX + section * realViewWidth;
        topInputField.frameTop =  - kRBRowHeight - kRBRowPadding;
        topInputField.frameLeft = kRBInputFieldX + section * realViewWidth;
        
        // iterate over all fields in the section
        for (NSString *fieldID in fieldIDs) {
            // get values
            NSString *labelText = [form valueForKey:kRBFormKeyLabel ofField:fieldID inSection:section];
            NSString *value = [form valueForKey:kRBFormKeyValue ofField:fieldID inSection:section];
            NSString *datatype = [form valueForKey:kRBFormKeyDatatype ofField:fieldID inSection:section];
            
            // match values for client if there is no value set
            if (IsEmpty(value)) {
                for (NSString *mapping in [RBClient propertyNamesForMapping]) {
                    if ([form fieldWithID:fieldID inSection:section matches:mapping]) {
                        value = [client valueForKey:mapping];
                    }
                }
            }
            
            // create label and input field
            UILabel *label = [self labelWithText:labelText];
            UIControl *inputField = [self inputFieldWithID:fieldID value:value datatype:datatype];
            CGFloat heightDiff = kRBRowHeight - inputField.frameHeight; // Switch = 27 pt, TextField = 31 pt
            
            inputField.formSection = section;
            
            // position in Grid depending on anchor-views
            [label positionUnderView:topLabel padding:kRBRowPadding alignment:MTUIViewAlignmentLeftAligned];
            [inputField positionUnderView:topInputField padding:(kRBRowPadding + heightDiff/2.f) alignment:MTUIViewAlignmentLeftAligned];
            
            [view.innerScrollView addSubview:label];
            [view.innerScrollView addSubview:inputField];
            
            // set new frames for anchor-views
            topLabel.frame = label.frame;
            topInputField.frame = inputField.frame;
            topInputField.frameTop += heightDiff/2.f;
            
            maxHeight = MAX(maxHeight, topInputField.frameBottom);
        }
    }
    
    // Add RecipientsView
    RBRecipientsView *recipientsView = [[[RBRecipientsView alloc] initWithFrame:CGRectMake(form.numberOfSections*realViewWidth, 0, view.bounds.size.width, view.bounds.size.height)] autorelease];
    [view.innerScrollView addSubview:recipientsView];
    
    // update pageControl on view (isn't displayed yet, because it is not a subview of the scrollView)
    view.pageControl.numberOfPages = numberOfPages;
    
    // enable vertical scrolling
    [view setInnerScrollViewSize:CGSizeMake(realViewWidth*numberOfPages, maxHeight)];
    view.contentSize = CGSizeMake(realViewWidth, maxHeight);
    
    return view;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, kRBInputFieldX - kRBLabelX - 30.f, kRBRowHeight)] autorelease];
    
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kRBColorMain;
    label.font = [UIFont fontWithName:kRBFontName size:16];
    label.textAlignment = UITextAlignmentRight;
    label.text = [text uppercaseString];
    
    return label;
}

- (UIControl *)inputFieldWithID:(NSString *)fieldID value:(NSString *)value datatype:(NSString *)datatype {
    UIControl *control = [UIControl controlWithID:fieldID datatype:datatype size:CGSizeMake(kRBInputFieldWidth, kRBRowHeight)];
    
    [control configureControlUsingValue:value];
    
    return control;
}

@end
