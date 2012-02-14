//
//  RBMultiValueTextField.h
//  SignMe
//
//  Created by Juergen Falb on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBMultiValueTextField : UIControl

@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSDictionary *calcVarFields;
@property (nonatomic, strong) NSString *text;

- (void)calculate;

@end
