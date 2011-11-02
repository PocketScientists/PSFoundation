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
#import "VCTitleCase.h"
#import "AppDelegate.h"


@interface RBRecipientsView ()

@property (nonatomic, readonly) PSBaseViewController *viewControllerResponder;
@property (nonatomic, retain) UIButton *addContactButton;
@property (nonatomic, retain) UIButton *addInPersonContactButton;
@property (nonatomic, retain) UIButton *routingOrderButton;
@property (nonatomic, retain) UITextField *subjectTextField;

- (void)showPeoplePicker;
- (void)showNewContactScreen;
- (void)handleAddContactPress:(id)sender;
- (void)handleAddInPersonContactPress:(id)sender;
- (void)handleNewContactPress:(id)sender;
- (void)handleRoutingOrderPress:(id)sender;
- (void)redrawTableData;

@end

@implementation RBRecipientsView

@synthesize tableView = tableView_;
@synthesize recipients = recipients_;
@synthesize tabs = tabs_;
@synthesize maxNumberOfRecipients = maxNumberOfRecipients_;
@synthesize addContactButton = addContactButton_;
@synthesize addInPersonContactButton = addInPersonContactButton_;
@synthesize routingOrderButton = routingOrderButton_;
@synthesize subjectTextField = subjectTextField_;
@synthesize useRoutingOrder = useRoutingOrder_;


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
        subjectTextField_.delegate = self;
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
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 155.f, 150, 55.f)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Add Captive Recipient";
        label.numberOfLines = 2;
        [self addSubview:label];
        
        addInPersonContactButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [addInPersonContactButton_ setImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
        addInPersonContactButton_.frame = CGRectMake(190.f, label.frameTop+10, 35.f, 35.f);
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
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(30, 245.f, 150, 55.f)] autorelease];
        label.font = [UIFont fontWithName:kRBFontName size:18];
        label.textColor = kRBColorMain;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Obey Routing Order";
        label.numberOfLines = 2;
        [self addSubview:label];
        
        self.routingOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [routingOrderButton_ setImage:[UIImage imageNamed:@"CheckButton2"] forState:UIControlStateNormal];
        [routingOrderButton_ setImage:[UIImage imageNamed:@"CheckButton2Selected"] forState:UIControlStateSelected];
        routingOrderButton_.frame = CGRectMake(190.f, label.frameTop+10, 35.f, 35.f);
        [routingOrderButton_ addTarget:self action:@selector(handleRoutingOrderPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:routingOrderButton_];
        
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
    MCRelease(routingOrderButton_);
    MCRelease(subjectTextField_);
    MCRelease(tabs_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        self.addContactButton.enabled = self.recipients.count < self.maxNumberOfRecipients;
        self.addInPersonContactButton.enabled = self.addContactButton.enabled;
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

- (void)setUseRoutingOrder:(BOOL)useRoutingOrder {
    useRoutingOrder_ = useRoutingOrder;
    self.routingOrderButton.selected = useRoutingOrder;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tabs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RBRecipientTableViewCell *cell = [RBRecipientTableViewCell cellForTableView:tableView style:UITableViewCellStyleDefault];
    cell.delegate = self;
    
    if (indexPath.row < self.recipients.count) {
        NSDictionary *personDict = [self.recipients objectAtIndex:indexPath.row];
        ABPerson *person = [[ABAddressBook sharedAddressBook] personWithRecordID:[[personDict valueForKey:kRBRecipientPersonID] intValue]];
        
        if (person.imageData != nil) {
            cell.image = [UIImage imageWithData:person.imageData];
        }
        else {
            cell.image = [UIImage imageNamed:@"EmptyContact"];
        }
        if ([[personDict valueForKey:kRBRecipientType] boolValue] == kRBRecipientTypeInPerson) {
            cell.mainText = [NSString stringWithFormat:@"%@ (C)", person.fullName];
            [cell disableAuth];
        }
        else {
            cell.mainText = person.fullName;
            [cell enableAuth];
        }
        cell.code = [personDict valueForKey:kRBRecipientCode] ? [[personDict valueForKey:kRBRecipientCode] intValue] : 0;
        cell.idcheck = [personDict valueForKey:kRBRecipientIDCheck] && [[personDict valueForKey:kRBRecipientIDCheck] intValue] > 0 ? YES : NO;
        cell.detailText = [person emailForID:[personDict valueForKey:kRBRecipientEmailID]];
        cell.placeholderText = nil;
    }
    else {
        cell.image = nil;
        cell.mainText = nil;
        cell.detailText = nil;
        cell.code = 0;
        cell.idcheck = NO;
        [cell disableAuth];
        cell.placeholderText = [[self.tabs objectAtIndex:indexPath.row] objectForKey:kRBFormKeyTabLabel];
    }
    
    return cell;
}

// no cell is selectable
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.mainText) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.recipients removeObjectAtIndex:indexPath.row];

        [self redrawTableData];
        
        self.addContactButton.enabled = YES;
        self.addInPersonContactButton.enabled = YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.mainText) {
        return YES;
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[self.tableView cellForRowAtIndexPath:proposedDestinationIndexPath];
    if (cell.mainText) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (destinationIndexPath.row < self.recipients.count) {
        [self.recipients exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    }
    else {
        [self redrawTableData];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)redrawTableData {
    for (int i = 0; i < self.tabs.count; i++) {
        RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i < self.recipients.count) {
            NSDictionary *personDict = [self.recipients objectAtIndex:i];
            ABPerson *person = [[ABAddressBook sharedAddressBook] personWithRecordID:[[personDict valueForKey:kRBRecipientPersonID] intValue]];
            
            if (person.imageData != nil) {
                cell.image = [UIImage imageWithData:person.imageData];
            }
            else {
                cell.image = [UIImage imageNamed:@"EmptyContact"];
            }
            if ([[personDict valueForKey:kRBRecipientType] boolValue] == kRBRecipientTypeInPerson) {
                cell.mainText = [NSString stringWithFormat:@"%@ (C)", person.fullName];
                [cell disableAuth];
            }
            else {
                cell.mainText = person.fullName;
                [cell enableAuth];
            }
            cell.code = [personDict valueForKey:kRBRecipientCode] ? [[personDict valueForKey:kRBRecipientCode] intValue] : 0;
            cell.idcheck = [personDict valueForKey:kRBRecipientIDCheck] && [[personDict valueForKey:kRBRecipientIDCheck] intValue] > 0 ? YES : NO;
            cell.detailText = [person emailForID:[personDict valueForKey:kRBRecipientEmailID]];
            cell.placeholderText = nil;
        }
        else {
            cell.image = nil;
            cell.mainText = nil;
            cell.code = 0;
            cell.idcheck = NO;
            cell.detailText = nil;
            cell.placeholderText = [[self.tabs objectAtIndex:i] objectForKey:kRBFormKeyTabLabel];
            [cell disableAuth];
        }
    }
    self.tableView.editing = NO;
    self.tableView.editing = YES;
}

- (void)cell:(RBRecipientTableViewCell *)cell changedCode:(int)code idCheck:(BOOL)idCheck {
    int index = [self.tableView indexPathForCell:cell].row;
    
    if (index < self.recipients.count) {
        [[self.recipients objectAtIndex:index] setObject:[NSNumber numberWithInt:code] forKey:kRBRecipientCode];
        [[self.recipients objectAtIndex:index] setObject:[NSNumber numberWithBool:idCheck] forKey:kRBRecipientIDCheck];
    }
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
    NSMutableDictionary *personDict = XMDICT($I(personWrapper.recordID), kRBRecipientPersonID, $I(identifier), kRBRecipientEmailID, isInPerson ? $I(kRBRecipientTypeInPerson) : $I(kRBRecipientTypeRemote), kRBRecipientType);
    
    if ([self.recipients containsObject:personDict]) {
        [MTApplicationDelegate showErrorMessage:@"Recipient has been added already."];
    } else {
        [self.recipients addObject:personDict];
        [self redrawTableData];
    }
    
    if (self.recipients.count >= self.maxNumberOfRecipients) {
        self.addContactButton.enabled = NO;
        self.addInPersonContactButton.enabled = NO;
        [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
        [self.viewControllerResponder performSelector:@selector(showSuccessMessage:) withObject:@"Maximum number of recipients for this form added." afterDelay:1.5];
    }
    
    [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ABNewPersonViewControllerDelegate
////////////////////////////////////////////////////////////////////////

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
    
    if (person) {
        [self.viewControllerResponder performSelector:@selector(showSuccessMessage:) withObject:@"Contact added" afterDelay:1.5f];
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

- (void)handleRoutingOrderPress:(id)sender {
    self.useRoutingOrder = !self.useRoutingOrder;
    self.routingOrderButton.selected = self.useRoutingOrder;
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

#pragma mark - textfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performBlock:^{
        textField.text = [textField.text titlecaseString];
    } afterDelay:0];
    return YES;
}

@end
