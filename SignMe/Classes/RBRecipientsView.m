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

@property (nonatomic, readonly) PSBaseViewController *viewControllerResponder;
@property (nonatomic, retain) UIButton *addContactButton;
@property (nonatomic, retain) UIButton *addInPersonContactButton;
@property (nonatomic, retain) UITextField *subjectTextField;

- (void)showPeoplePicker;
- (void)showNewContactScreen;
- (void)handleAddContactPress:(id)sender;
- (void)handleAddInPersonContactPress:(id)sender;
- (void)handleNewContactPress:(id)sender;

@end

@implementation RBRecipientsView

@synthesize tableView = tableView_;
@synthesize recipients = recipients_;
@synthesize maxNumberOfRecipients = maxNumberOfRecipients_;
@synthesize addContactButton = addContactButton_;
@synthesize addInPersonContactButton = addInPersonContactButton_;
@synthesize subjectTextField = subjectTextField_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.tag = kRBRecipientsViewTag;
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 10.f, 150, 31)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Subject";
        [self addSubview:label];
        
        subjectTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(30.f, 50.f, self.bounds.size.width/2.f - 60.0f, 35.f)];
        subjectTextField_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        subjectTextField_.borderStyle = UITextBorderStyleBezel;
        subjectTextField_.backgroundColor = [UIColor whiteColor];
        subjectTextField_.font = [UIFont fontWithName:kRBFontName size:18];
        subjectTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        subjectTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
        subjectTextField_.placeholder = @"DocuSign Subject";
        [self addSubview:subjectTextField_];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 120.f, 150, 35.f)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Add Recipient";
        [self addSubview:label];
        
        addContactButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [addContactButton_ setImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
        addContactButton_.frame = CGRectMake(190.f, label.frameTop, 35.f, 35.f);
        [addContactButton_ addTarget:self action:@selector(handleAddContactPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addContactButton_];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 165.f, 150, 35.f)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Add In Person Signer";
        [self addSubview:label];
        
        addInPersonContactButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [addInPersonContactButton_ setImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
        addInPersonContactButton_.frame = CGRectMake(190.f, label.frameTop, 35.f, 35.f);
        [addInPersonContactButton_ addTarget:self action:@selector(handleAddInPersonContactPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addInPersonContactButton_];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 210.f, 150, 35.f)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"New Contact";
        [self addSubview:label];
        
        UIButton *newContactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [newContactButton setImage:[UIImage imageNamed:@"NewContactButton"] forState:UIControlStateNormal];
        newContactButton.frame = CGRectMake(190.f, label.frameTop, 35.f, 35.f);
        [newContactButton addTarget:self action:@selector(handleNewContactPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:newContactButton];
        
        UIView *dividerView = [[[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.f, 5.f, 1.f, self.bounds.size.height-10.f)] autorelease];
        dividerView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.3f];
        dividerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:dividerView];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 35.f)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:19];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Recipients";
        
        tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(545.f, 5.f, 450.f, self.bounds.size.height-10.f) style:UITableViewStylePlain];
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        tableView_.backgroundColor = [UIColor clearColor];
        tableView_.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        tableView_.tableHeaderView = label; 
        // tableView_.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
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
    MCRelease(subjectTextField_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        self.addContactButton.enabled = self.recipients.count < self.maxNumberOfRecipients;
        [self.tableView reloadData];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (void)setSubject:(NSString *)subject {
    self.subjectTextField.text = subject;
}

- (NSString *)subject {
    return self.subjectTextField.text;
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
    ABPerson *person = [[ABAddressBook sharedAddressBook] personWithRecordID:[[personDict valueForKey:kRBRecipientPersonID] intValue]];
    
    if (person.imageData != nil) {
        cell.image = [UIImage imageWithData:person.imageData];
    }
    cell.mainText = person.fullName;
    cell.detailText = [person emailForID:[personDict valueForKey:kRBRecipientEmailID]];
    
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.recipients exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
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

//- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue


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
    NSDictionary *personDict = XDICT($I(personWrapper.recordID), kRBRecipientPersonID, $I(identifier), kRBRecipientEmailID, isInPerson ? $I(kRBRecipientTypeInPerson) : $I(kRBRecipientTypeRemote), kRBRecipientType);
    
    if ([self.recipients containsObject:personDict]) {
        NSInteger index = [self.recipients indexOfObject:personDict];
        
        [self.recipients removeObject:personDict];
        [self.tableView deleteRowsAtIndexPaths:XARRAY([NSIndexPath indexPathForRow:index inSection:0]) withRowAnimation:UITableViewRowAnimationMiddle];
    } else {
        [self.recipients addObject:personDict];
        NSInteger index = [self.recipients indexOfObject:personDict];
        [self.tableView insertRowsAtIndexPaths:XARRAY([NSIndexPath indexPathForRow:index inSection:0]) withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    if (self.recipients.count >= self.maxNumberOfRecipients) {
        self.addContactButton.enabled = NO;
        self.addInPersonContactButton.enabled = NO;
        [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
        [self.viewControllerResponder performSelector:@selector(showSuccessMessage:) withObject:@"All recipients added" afterDelay:0.5];
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ABNewPersonViewControllerDelegate
////////////////////////////////////////////////////////////////////////

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
    
    if (person) {
        [self.viewControllerResponder performSelector:@selector(showSuccessMessage:) withObject:@"Contact added" afterDelay:0.5f];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleAddContactPress:(id)sender {
    if (self.recipients.count < self.maxNumberOfRecipients) {
        isInPerson = NO;
        [self showPeoplePicker];
    }
}

- (void)handleAddInPersonContactPress:(id)sender {
    if (self.recipients.count < self.maxNumberOfRecipients) {
        isInPerson = YES;
        [self showPeoplePicker];
    }
}

- (void)handleNewContactPress:(id)sender {
    [self showNewContactScreen];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

// retreives the first viewController in the responder chain
- (PSBaseViewController *)viewControllerResponder {
    UIResponder *responder = self.nextResponder;
    
    while (responder != nil && ![responder isKindOfClass:[PSBaseViewController class]]) {
        responder = responder.nextResponder;
    }
    
    return (PSBaseViewController *)responder;
}

- (void)showPeoplePicker {
    ABPeoplePickerNavigationController *picker = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
    
    picker.peoplePickerDelegate = self;
	picker.displayedProperties = XARRAY([NSNumber numberWithInt:kABPersonEmailProperty]);
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
	// Show the picker 
	[self.viewControllerResponder presentModalViewController:picker animated:YES];
}

- (void)showNewContactScreen {
    ABNewPersonViewController *viewController = [[[ABNewPersonViewController alloc] init] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    
    viewController.newPersonViewDelegate = self;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.viewControllerResponder presentModalViewController:navigationController animated:YES];
    
}

@end
