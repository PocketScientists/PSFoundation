//
//  RBFormLayoutData.h
//  SignMe
//
//  Created by Juergen Falb on 22.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBFormLayoutData : NSObject

@property (nonatomic, assign) CGPoint formOrigin;
@property (nonatomic, assign) CGFloat formWidth;
@property (nonatomic, assign) CGFloat minFieldWidth;
@property (nonatomic, assign) NSInteger numberOfColumns;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, retain) NSMutableArray *columnWidths;
@property (nonatomic, retain) NSMutableArray *columnLabelWidths;
@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *fields;
@property (nonatomic, retain) UIView *sectionHeader;
@property (nonatomic, retain) UIButton *sectionHeaderButton;

- (void)calculateLayout;

- (CGRect)rectForSectionHeader;
- (CGRect)rectForSectionHeaderButton;
- (CGRect)rectForLabelAtIndex:(NSInteger)index;
- (CGRect)rectForFieldAtIndex:(NSInteger)index;

@end
