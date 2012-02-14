//
//  UIView+RBForm.h
//  SignMe
//
//  Created by Jürgen Falb on 12.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RBForm)

@property (nonatomic, retain) NSString *formID;
@property (nonatomic, retain) NSString *formDatatype;
@property (nonatomic, assign) NSInteger formSection;
@property (nonatomic, assign) NSInteger formSubsection;
@property (nonatomic, retain) NSString *formPosition;
@property (nonatomic, assign) NSInteger formColumn;
@property (nonatomic, assign) NSInteger formRow;
@property (nonatomic, assign) NSInteger formColumnSpan;
@property (nonatomic, assign) NSInteger formRowSpan;
@property (nonatomic, assign) CGFloat formSize;
@property (nonatomic, retain) NSString *formAlignment;
@property (nonatomic, retain) NSArray *formRepeatGroup;
@property (nonatomic, assign) BOOL formShowRepeatButton;
@property (nonatomic, retain) NSString *formRepeatField;

@end
