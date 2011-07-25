//
//  RBUIGenerator.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBUIGenerator.h"
#import "PSIncludes.h"

#define kRBLabelX                   50.f
#define kRBInputFieldX              250.f
#define kRBInputFieldWidth          250.f
#define kRBRowHeight                31.f
#define kRBRowPadding               10.f

#define kRBOriginTop                150.f


@interface RBUIGenerator ()

- (UILabel *)labelWithText:(NSString *)text;
- (UIControl *)inputFieldWithValue:(NSString *)value datatype:(NSString *)datatype;

@end

@implementation RBUIGenerator

- (RBFormView *)viewFromForm:(RBForm *)form withFrame:(CGRect)frame {
    RBFormView *view = [[[RBFormView alloc] initWithFrame:frame] autorelease];
    UIView *topLabel = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kRBRowHeight)] autorelease];
    UIView *topInputField = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kRBRowHeight)] autorelease];
    CGFloat realViewWidth = view.bounds.size.height; // Because of landscape we have to switch width/height
    CGFloat realViewHeight = view.bounds.size.width;
    
    // iterate over all sections
    for (NSUInteger section=0;section < form.numberOfSections; section++) {
        NSArray *fieldIDs = [form fieldIDsOfSection:section];
        
        // position top views on corresponding page of scrollView
        topLabel.frameTop = kRBOriginTop;
        topLabel.frameLeft = kRBLabelX + section * realViewWidth;
        topInputField.frameTop = kRBOriginTop;
        topInputField.frameLeft = kRBInputFieldX + section * realViewWidth;
        
        MTLog(topLabel.frame);
        
        // iterate over all fields in the section
        for (NSString *fieldID in fieldIDs) {
            NSString *labelText = [form valueForKey:kRBFormKeyLabel ofField:fieldID inSection:section];
            NSString *value = [form valueForKey:kRBFormKeyValue ofField:fieldID inSection:section];
            NSString *datatype = [form valueForKey:kRBFormKeyDatatype ofField:fieldID inSection:section];
            UILabel *label = [self labelWithText:labelText];
            UIControl *inputField = [self inputFieldWithValue:value datatype:datatype];
            
            [label positionUnderView:topLabel padding:kRBRowPadding alignment:MTUIViewAlignmentLeftAligned];
            [inputField positionUnderView:topInputField padding:kRBRowPadding alignment:MTUIViewAlignmentLeftAligned];
            
            [view addSubview:label];
            [view addSubview:inputField];
            
            topLabel.frame = label.frame;
            topInputField.frame = inputField.frame;
        }
    }
    
    // enable horizontal scrolling
    view.contentSize = CGSizeMake(realViewWidth * form.numberOfSections, realViewHeight);
    
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
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textAlignment = UITextAlignmentRight;
    label.text = text;
    
    return label;
}

- (UIControl *)inputFieldWithValue:(NSString *)value datatype:(NSString *)datatype {
    UITextField *inputField = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, kRBInputFieldWidth, kRBRowHeight)] autorelease];
    
    inputField.autoresizingMask = UIViewAutoresizingNone;
    inputField.borderStyle = UITextBorderStyleRoundedRect;
    inputField.text = value;
    
    return inputField;
}

@end
