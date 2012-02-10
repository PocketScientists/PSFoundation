//
//  RBClientEditViewController.h
//  SignMe
//
//  Created by Tretter Matthias on 27.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "PSBaseViewController.h"
#import "RBClient.h"

@interface RBClientEditViewController : PSBaseViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger first;
    NSInteger last;
}

@property (nonatomic, strong) RBClient *client;

@end
