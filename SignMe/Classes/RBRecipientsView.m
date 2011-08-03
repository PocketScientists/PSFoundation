//
//  RBReceipientsView.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBRecipientsView.h"
#import "PSIncludes.h"
#import "RBRecipientTableViewCell.h"
#import <AddressBook/AddressBook.h>
#import "ABAddressBook.h"
#import "ABPerson.h"
#import "ABPerson+RBMail.h"

#define kRBHeaderViewHeight     40

@interface RBRecipientsView ()

@property (nonatomic, readonly) UIViewController *viewControllerResponder;
@property (nonatomic, retain) UIButton *addContactButton;

- (void)showPeoplePicker;
- (void)handleAddContactPress:(id)sender;

@end

@implementation RBRecipientsView

@synthesize tableView = tableView_;
@synthesize recipients = recipients_;
@synthesize maxNumberOfRecipients = maxNumberOfRecipients_;
@synthesize addContactButton = addContactButton_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.tag = kRBRecipientsViewTag;
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 5, 150, 31)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Add Recipient: ";
        [self addSubview:label];
        
        addContactButton_ = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
        addContactButton_.frame = CGRectMake(label.frameRight, label.frameTop, 31, 31);
        [addContactButton_ addTarget:self action:@selector(handleAddContactPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addContactButton_];
        
        tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(30, kRBHeaderViewHeight, 480, self.bounds.size.height-kRBHeaderViewHeight) style:UITableViewStylePlain];
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        tableView_.backgroundColor = [UIColor clearColor];
        tableView_.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        tableView_.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        tableView_.editing = YES;
        
        [self addSubview:tableView_];
        
        recipients_ = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(tableView_);
    MCRelease(recipients_);
    MCRelease(addContactButton_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recipients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RBRecipientTableViewCell *cell = [RBRecipientTableViewCell cellForTableView:tableView style:UITableViewCellStyleDefault];
    NSDictionary *personDict = [self.recipients objectAtIndex:indexPath.row];
    ABPerson *person = [[ABAddressBook sharedAddressBook] personWithRecordID:[[personDict valueForKey:@"addressBookPersonID"] intValue]];
    
    if (person.imageData != nil) {
        cell.image = [UIImage imageWithData:person.imageData];
    }
    cell.mainText = person.fullName;
    cell.detailText = [person emailForID:[personDict valueForKey:@"emailPropertyID"]];
    
    return cell;
}

// no cell is selectable
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.recipients removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:XARRAY(indexPath) withRowAnimation:UITableViewRowAnimationMiddle];
        self.addContactButton.enabled = YES;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ABPeoplePickerNavigationControllerDelegate
////////////////////////////////////////////////////////////////////////

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    ABPerson *personWrapper = [[ABAddressBook sharedAddressBook] personWithRecordRef:person];
    NSDictionary *personDict = XDICT($I(personWrapper.recordID), @"addressBookPersonID", $I(identifier), @"emailPropertyID");
    
    if ([self.recipients containsObject:personDict]) {
        NSInteger index = [self.recipients indexOfObject:personDict];
        
        [self.recipients removeObject:personDict];
        [self.tableView deleteRowsAtIndexPaths:XARRAY([NSIndexPath indexPathForRow:index inSection:0]) withRowAnimation:UITableViewRowAnimationMiddle];
    } else {
        [self.recipients addObject:personDict];
        NSInteger index = [self.recipients indexOfObject:personDict];
        [self.tableView insertRowsAtIndexPaths:XARRAY([NSIndexPath indexPathForRow:index inSection:0]) withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    if (self.recipients.count < self.maxNumberOfRecipients) {
        return YES;
    } else {
        self.addContactButton.enabled = NO;
        [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
        return NO;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleAddContactPress:(id)sender {
    if (self.recipients.count < self.maxNumberOfRecipients) {
        [self showPeoplePicker];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

// retreives the first viewController in the responder chain
- (UIViewController *)viewControllerResponder {
    UIResponder *responder = self.nextResponder;
    
    while (responder != nil && ![responder isKindOfClass:[UIViewController class]]) {
        responder = responder.nextResponder;
    }
    
    return (UIViewController *)responder;
}

- (void)showPeoplePicker {
    ABPeoplePickerNavigationController *picker = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
    
    picker.peoplePickerDelegate = self;
	picker.displayedProperties = XARRAY([NSNumber numberWithInt:kABPersonEmailProperty]);
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
	// Show the picker 
	[self.viewControllerResponder presentModalViewController:picker animated:YES];
}

@end
