//
//  RBMusketeerEditViewController.h
//  SignMe
//
//  Created by Tretter Matthias on 27.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "PSBaseViewController.h"
#import "RBMusketeer.h"

@interface RBMusketeerEditViewController : PSBaseViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger first;
    NSInteger last;
}

@property (nonatomic, strong) RBMusketeer *musketeer;

@end
