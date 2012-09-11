//
//  RBReceipientsView.h
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RBRecipientTableViewCell.h"
#import "RBRecipientPickerViewController.h"
#import "RBRecipient.h"
#import "RBAvailableRecipients.h"

#define kRBRecipientsViewTag    540492

@interface RBRecipientsView : UIView <UITableViewDataSource, UITableViewDelegate, RBRecipientTableViewCellDelegate, 
ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate, UITextFieldDelegate,RBRecipientPickerDelegate> {
    UIButton *lastButtonPressed;
}

@property (nonatomic, assign) NSUInteger maxNumberOfRecipients;
@property (nonatomic, copy) NSArray *recipients;
@property (nonatomic, strong) NSArray *tabs;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, assign) BOOL useRoutingOrder;

@property (nonatomic, strong) NSArray *tableViews;

@end
