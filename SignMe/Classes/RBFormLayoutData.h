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
@property (nonatomic, strong) NSMutableArray *columnWidths;
@property (nonatomic, strong) NSMutableArray *columnLabelWidths;
@property (nonatomic, strong) NSMutableArray *rowHeights;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) UIView *sectionHeader;
@property (nonatomic, strong) UIButton *sectionHeaderButton;

- (void)calculateLayout;

- (CGRect)rectForSectionHeader:(BOOL)spacing;
- (CGRect)rectForSectionHeaderButton:(BOOL)spacing;
- (CGRect)rectForLabelAtIndex:(NSInteger)index;
- (CGRect)rectForFieldAtIndex:(NSInteger)index;

@end
