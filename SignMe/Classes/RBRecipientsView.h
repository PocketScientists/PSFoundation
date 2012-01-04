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

#define kRBRecipientsViewTag    540492

@interface RBRecipientsView : UIView <UITableViewDataSource, UITableViewDelegate, RBRecipientTableViewCellDelegate, 
ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate, UITextFieldDelegate> {
    UIButton *lastButtonPressed;
}

@property (nonatomic, assign) NSUInteger maxNumberOfRecipients;
@property (nonatomic, copy) NSArray *recipients;
@property (nonatomic, retain) NSArray *tabs;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, assign) BOOL useRoutingOrder;

@property (nonatomic, retain) NSArray *tableViews;

@end
