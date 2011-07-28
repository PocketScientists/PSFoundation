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

@interface RBRecipientsView ()

@property (nonatomic, readonly) UIViewController *viewControllerResponder;

- (void)showPeoplePicker;

@end

@implementation RBRecipientsView

@synthesize tableView = tableView_;
@synthesize recipients = recipients_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        tableView_ = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView_.backgroundColor = [UIColor clearColor];
        tableView_.backgroundView = [[[UIView alloc] init] autorelease];
        
        [self addSubview:tableView_];
        
        recipients_ = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(tableView_);
    MCRelease(recipients_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recipients.count +1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RBRecipientTableViewCell *cell = [RBRecipientTableViewCell cellForTableView:tableView style:UITableViewCellStyleDefault];
    if (indexPath.row == self.recipients.count) {
        cell.mainText = @"Add";
    } else {
        ABPerson *personWrapper = [self.recipients objectAtIndex:indexPath.row];
        
        cell.mainText = [personWrapper.lastName stringByAppendingFormat:@", %@", personWrapper.firstName];
        cell.detailText = personWrapper.mainEMail;
    }
    
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showPeoplePicker];
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
    ABPerson *personWrapper = [[ABAddressBook sharedAddressBook] personWithRecordRef:person];
    
    if ([self.recipients containsObject:personWrapper]) {
        [self.recipients removeObject:personWrapper];
    } else {
        [self.recipients addObject:personWrapper];
    }
    [self.tableView reloadData];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    return [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
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
