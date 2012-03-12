//
//  RBFormLayoutData.m
//  SignMe
//
//  Created by Juergen Falb on 22.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RBFormLayoutData.h"
#import "RBForm.h"
#import "UIControl+RBForm.h"
#import "RBMultiValueTextField.h"

#define kRBColPadding               30.f
#define kRBInputFieldPadding        10.f
#define kRBRowHeight                35.f
#define kRBRowPadding               11.f
#define kRBSectionSpacing           30.f


@implementation RBFormLayoutData

@synthesize formOrigin;
@synthesize formWidth;
@synthesize minFieldWidth;
@synthesize numberOfColumns;
@synthesize numberOfRows;
@synthesize columnWidths;
@synthesize columnLabelWidths;
@synthesize rowHeights;
@synthesize labels;
@synthesize fields;
@synthesize sectionHeader;
@synthesize sectionHeaderButton;


- (id)init 
{
    if ((self = [super init])) {
        self.columnWidths = [NSMutableArray arrayWithCapacity:20];
        self.columnLabelWidths = [NSMutableArray arrayWithCapacity:20];
        self.rowHeights = [NSMutableArray arrayWithCapacity:20];
        self.labels = [NSMutableArray arrayWithCapacity:20];
        self.fields = [NSMutableArray arrayWithCapacity:20];
        self.minFieldWidth = 80;
    }
    return self;
}


- (void)calculateLayout
{
    // calculate the numbers of rows and cols
    numberOfRows = 0;
    numberOfColumns = 0;
    
    for (UIView *label in labels) {
        if (label.formColumn > numberOfColumns) {
            numberOfColumns = label.formColumn;
        }
        if (label.formRow > numberOfRows) {
            numberOfRows = label.formRow;
        }
    }
    numberOfColumns++;
    numberOfRows++;
    
    [columnLabelWidths removeAllObjects];
    [columnWidths removeAllObjects];
    [rowHeights removeAllObjects];
    
    CGFloat totalWidth = 0;
    for (int i = 0; i < numberOfColumns; i++) {
        // iterate over all fields in the section and figure out the max length
        CGFloat maxLabelWidth = 0.0f;
        for (UILabel *label in labels) {
            if ([label.formDatatype isEqualToString:kRBFormDataTypeLabel] || label.text == nil || label.text.length == 0) continue;
//            if (label.formColumnSpan > 1 && (label.formColumn <= i && i < label.formColumn + label.formColumnSpan)) {
//                CGFloat lWidth = [label sizeThatFits:CGSizeMake(formWidth, 400)].width;
//                NSLog(@"lbl width: %f (%@)", lWidth, label.text);
//                if (label.formColumnSpan > 1) {
//                    lWidth -= (label.formColumnSpan - 1) * (minFieldWidth + kRBColPadding);
//                }
//                lWidth /= label.formColumnSpan;
//                //CGFloat lWidth = [label.text sizeWithFont:label.font].width / label.formColumnSpan;
//                maxLabelWidth = MAX(maxLabelWidth, lWidth);
//            }
            if (label.formColumnSpan == 1 && label.formColumn == i) {
                CGFloat lWidth = [label.text sizeWithFont:label.font].width;
                maxLabelWidth = MAX(maxLabelWidth, lWidth);
            }
        }
        [columnLabelWidths addObject:[NSNumber numberWithFloat:maxLabelWidth]];
        totalWidth += maxLabelWidth;
    }
    
    CGFloat remainingWidth = formWidth - totalWidth - (numberOfColumns - 1) * kRBColPadding;
    if (remainingWidth < numberOfColumns * minFieldWidth) {
        CGFloat sumDiff = numberOfColumns * minFieldWidth - remainingWidth;
        CGFloat diff = sumDiff / numberOfColumns;
        
        int j = numberOfColumns;
        while (sumDiff > 0 && j > 0) {
            for (int i = 0; i < numberOfColumns; i++) {
                if ([[columnLabelWidths objectAtIndex:i] floatValue] > minFieldWidth) {
                    CGFloat newWidth = [[columnLabelWidths objectAtIndex:i] floatValue] - diff;
                    if (newWidth < minFieldWidth) {
                        sumDiff -= diff - (minFieldWidth - newWidth);
                        newWidth = minFieldWidth;
                    }
                    else {
                        sumDiff -= diff;
                    }
                    [columnLabelWidths replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newWidth]];
                }
            }
            j--;
        }
        
        remainingWidth = MAX(remainingWidth, (numberOfColumns * minFieldWidth));
    }
    
    CGFloat fieldWidth = remainingWidth / numberOfColumns;
    for (int i = 0; i < numberOfColumns; i++) {
        CGFloat newWidth = [[columnLabelWidths objectAtIndex:i] floatValue] + fieldWidth;
        [columnWidths addObject:[NSNumber numberWithFloat:newWidth]];
    }
    
    for (int i = 0; i < numberOfRows; i++) {
        CGFloat maxRowHeight = kRBRowHeight + kRBRowPadding;
        for (UIControl *field in self.fields) {
            if (field.formRow == i && [field isKindOfClass:[RBMultiValueTextField class]]) {
                if (((RBMultiValueTextField *)field).rows * (kRBRowHeight + kRBRowPadding) > maxRowHeight) {
                    maxRowHeight = ((RBMultiValueTextField *)field).rows * (kRBRowHeight + kRBRowPadding);
                }
            }
        }
        [rowHeights addObject:[NSNumber numberWithFloat:maxRowHeight]];
    }
}


- (CGRect)rectForSectionHeader:(BOOL)spacing
{
    if (sectionHeader) {
        return CGRectMake(formOrigin.x, formOrigin.y + (spacing ? kRBSectionSpacing : 0), formWidth, kRBRowHeight);
    }
    
    return CGRectZero;
}


- (CGRect)rectForSectionHeaderButton:(BOOL)spacing
{
    if (sectionHeaderButton) {
        if (sectionHeader) {
            CGFloat lblWidth = [sectionHeader sizeThatFits:CGSizeMake(formWidth, kRBRowHeight)].width;
            return CGRectMake(formOrigin.x + lblWidth + kRBInputFieldPadding, formOrigin.y + (spacing ? kRBSectionSpacing : 0), 39.0f, kRBRowHeight);
        }
        else {
            return CGRectMake(formOrigin.x, formOrigin.y + (spacing ? kRBSectionSpacing : 0), 39.0f, kRBRowHeight);
        }
    }

    return CGRectZero;
}


- (CGRect)rectForLabelAtIndex:(NSInteger)index
{
    CGRect r = CGRectZero;

    UIView *label = [self.labels objectAtIndex:index];
    if (label) {
        if ([label.formDatatype isEqualToString:kRBFormDataTypeLabel]) {
            // x
            r.origin.x = formOrigin.x;
            for (int i = 0; i < label.formColumn; i++) {
                r.origin.x += [[columnWidths objectAtIndex:i] floatValue] + kRBColPadding;
            }
            r.origin.x += [[columnLabelWidths objectAtIndex:label.formColumn] floatValue] + kRBInputFieldPadding;
            r.origin.x = floorf(r.origin.x);
            
            // width
            r.size.width = floorf([[columnWidths objectAtIndex:label.formColumn] floatValue] - [[columnLabelWidths objectAtIndex:label.formColumn] floatValue] - kRBInputFieldPadding);
            for (int i = 1; i < label.formColumnSpan; i++) {
                if (label.formColumn + i < [columnWidths count]) {
                    r.size.width += [[columnWidths objectAtIndex:label.formColumn+i] floatValue] + kRBColPadding;
                }
            }
        }
        else {
            // x
            r.origin.x = formOrigin.x;
            for (int i = 0; i < label.formColumn; i++) {
                r.origin.x += [[columnWidths objectAtIndex:i] floatValue] + kRBColPadding;
            }
            r.origin.x = floorf(r.origin.x);
            
            // width
            for (int i = 0; i < label.formColumnSpan-1; i++) {
                r.size.width += [[columnWidths objectAtIndex:label.formColumn+i] floatValue] + kRBColPadding;
            }
            int spanIndex = label.formColumn+label.formColumnSpan-1;
            if (spanIndex >= 0 && spanIndex < [columnLabelWidths count]) {
                r.size.width += [[columnLabelWidths objectAtIndex:spanIndex] floatValue];
            }
            r.size.width = floorf(r.size.width);
        }
        
        // y
        r.origin.y = formOrigin.y;
        for (int i = 0; i < label.formRow; i++) {
            r.origin.y += [[rowHeights objectAtIndex:i] floatValue];
        }

        if (self.sectionHeader) {
            r.origin.y += kRBRowHeight + kRBRowPadding + kRBSectionSpacing;
        }
        r.origin.y = floorf(r.origin.y);
        
        // height
        r.size.height = floorf([[rowHeights objectAtIndex:label.formRow] floatValue] - kRBRowPadding + (kRBRowHeight + kRBRowPadding) * (label.formRowSpan - 1));
    }
    
    return r;
}


- (CGRect)rectForFieldAtIndex:(NSInteger)index
{
    CGRect r = CGRectZero;
    
    UIView *field = [self.fields objectAtIndex:index];
    if (field && ![field.formDatatype isEqualToString:kRBFormDataTypeLabel]) {
        // x
        int colIndex = field.formColumn + field.formColumnSpan - 1;
        r.origin.x = formOrigin.x;
        for (int i = 0; i < colIndex; i++) {
            r.origin.x += [[columnWidths objectAtIndex:i] floatValue] + kRBColPadding;
        }
        r.origin.x += [[columnLabelWidths objectAtIndex:colIndex] floatValue] + kRBInputFieldPadding;
        r.origin.x = floorf(r.origin.x);
        
        // width
        if ([field.formDatatype isEqualToString:kRBFormDataTypeButton]) {
            r.size.width = 36.0f;
        }
        else {
            r.size.width = floorf(([[columnWidths objectAtIndex:colIndex] floatValue] - [[columnLabelWidths objectAtIndex:colIndex] floatValue])*field.formSize - kRBInputFieldPadding);
        }
        // y
        r.origin.y = formOrigin.y;
        for (int i = 0; i < field.formRow; i++) {
            r.origin.y += [[rowHeights objectAtIndex:i] floatValue];
        }

        if (self.sectionHeader) {
            r.origin.y += kRBRowHeight + kRBRowPadding + kRBSectionSpacing;
        }
        r.origin.y = floorf(r.origin.y);

        // height
        r.size.height = floorf([[rowHeights objectAtIndex:field.formRow] floatValue] - kRBRowPadding + (kRBRowHeight + kRBRowPadding) * (field.formRowSpan - 1));
    }
    
    return r;
}


- (void)dealloc 
{
    columnWidths = nil;
    columnLabelWidths = nil;
    labels = nil;
    fields = nil;
    sectionHeader = nil;
    sectionHeaderButton = nil;
    
}

@end
