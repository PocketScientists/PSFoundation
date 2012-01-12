//
//  RBTextField.h
//  SignMe
//
//  Created by Tretter Matthias on 05.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBTextField : UITextField <UIPopoverControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *nextField;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *prevField;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, assign) BOOL usePopover;
@property (nonatomic, retain) NSDictionary *calcVarFields;

- (void)calculate;

@end
