//
//  UILabel+RBForm.h
//  SignMe
//
//  Created by Jürgen Falb on 12.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (RBForm)

@property (nonatomic, retain) NSString *formID;
@property (nonatomic, assign) NSInteger formSection;
@property (nonatomic, assign) NSInteger formSubsection;

@end
