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
}

@property (nonatomic, retain) RBForm *form;
@property (nonatomic, retain) RBClient *client;
@property (nonatomic, retain) RBDocument *document;

@property (nonatomic, retain) RBFormView *formView;


- (id)initWithForm:(RBForm *)form client:(RBClient *)client;
- (id)initWithDocument:(RBDocument *)document;

@end
