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
#import "RBClient.h"
#import "SSLineView.h"

@interface RBFormViewController : PSBaseViewController {
    id observerShow;
    id observerHide;
    BOOL keyboardVisible;
}

@property (nonatomic, strong) RBForm *form;
@property (nonatomic, strong) RBClient *client;
@property (nonatomic, strong) RBDocument *document;

@property (nonatomic, strong) RBFormView *formView;


- (id)initWithForm:(RBForm *)form client:(RBClient *)client;
- (id)initWithDocument:(RBDocument *)document;

@end
