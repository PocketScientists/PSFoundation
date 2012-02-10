//
//  RBTextField.h
//  SignMe
//
//  Created by Tretter Matthias on 05.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBTextField : UITextField <UIPopoverControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *subtype;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, readwrite, unsafe_unretained) IBOutlet UITextField *nextField;
@property (nonatomic, readwrite, unsafe_unretained) IBOutlet UITextField *prevField;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) BOOL usePopover;
@property (nonatomic, strong) NSDictionary *calcVarFields;

- (void)calculate;

@end
