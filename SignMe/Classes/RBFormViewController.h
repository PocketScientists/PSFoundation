//
//  RBFormViewController.h
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import "RBForm.h"
#import "RBFormView.h"

@interface RBFormViewController : PSBaseViewController

@property (nonatomic, retain) RBForm *form;

@property (nonatomic, retain) RBFormView *formView;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *doneButton;

- (id)initWithForm:(RBForm *)form;

@end
