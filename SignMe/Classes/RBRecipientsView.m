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
#import "ABMultiValue.h"
#import "VCTitleCase.h"
#import "AppDelegate.h"

#define NOSUPERIORGROUP 99999


@interface RBRecipientsView ()

@property (unsafe_unretained, nonatomic, readonly) PSBaseViewController *viewControllerResponder;
@property (nonatomic, strong) UIButton *routingOrderButton;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) NSArray *addContactButtons;
@property (nonatomic, strong) NSArray *recipientsForTypes;
@property (nonatomic, strong) UIPopoverController *recipientPopover;
@property (nonatomic, strong) RBRecipientPickerViewController *recPicTVC;
@property (nonatomic, assign) NSUInteger noOfCellPickerActive;
@property (nonatomic, strong) NSMutableDictionary * selectedRecipientsAtPosition;
@property (nonatomic, assign) BOOL rbAccountSignerSelected;

- (void)showPeoplePicker;
- (void)showNewContactScreen;
- (void)handleAddContactPress:(id)sender;
- (void)handleNewContactPress:(id)sender;
- (void)handleRoutingOrderPress:(id)sender;
- (void)redrawTableData:(UITableView *)tableView;
- (NSArray *)recipientTypes;
- (NSArray *)recipientsForType:(NSString *)type;
- (int)maxNumberOfRecipientsForType:(NSString *)type;
- (NSArray *)tabsForType:(NSString *)type;

@end

@implementation RBRecipientsView

@synthesize tableViews = tableViews_;
@synthesize addContactButtons = addContactButtons_;
@synthesize recipientsForTypes = recipientsForTypes_;
@synthesize tabs = tabs_;
@synthesize maxNumberOfRecipients = maxNumberOfRecipients_;
@synthesize routingOrderButton = routingOrderButton_;
@synthesize subjectTextField = subjectTextField_;
@synthesize useRoutingOrder = useRoutingOrder_;
@synthesize recipientPopover = recipientPopover_;
@synthesize recPicTVC = recPicTVC_;
@synthesize noOfCellPickerActive = noOfCellPickerActive_;
@synthesize selectedRecipientsAtPosition=selectedRecipientsAtPosition_;
@synthesize rbAccountSignerSelected = rbAccountSignerSelected_;



////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.tag = kRBRecipientsViewTag;
        
        selectedRecipientsAtPosition_ = [[NSMutableDictionary alloc] init];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10.f, 150, 31)];
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
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 210.f, 150, 35.f)];
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
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 245.f, 150, 55.f)];
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
        
        //RBHQ Change: Hide Routing Order Option
        label.hidden=YES;
        routingOrderButton_.hidden=YES;
        
        UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.f, 5.f, 1.f, self.bounds.size.height-10.f)];
        dividerView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.3f];
        dividerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:dividerView];
    }
    
    return self;
}


- (NSArray *)recipientTypes {
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSDictionary *tab in self.tabs) {
        NSString *rType = [tab objectForKey:kRBFormKeyTabKind];
        if (!rType) {
            rType = @"default";
        }
        if (![types containsObject:rType]) {
            [types addObject:rType];
        }
    }
    return types;
}

- (NSArray *)recipientsForType:(NSString *)type {
    int index = [self.recipientTypes indexOfObject:type];
    if (index != NSNotFound) {
        return [self.recipientsForTypes objectAtIndex:index];
    }
    return nil;
}

- (int)maxNumberOfRecipientsForType:(NSString *)type {
    int num = 0;
    for (NSDictionary *tab in self.tabs) {
        NSString *tabKind = [tab objectForKey:kRBFormKeyTabKind];
        if ((tabKind == nil && [type isEqualToString:@"default"]) || [type isEqualToString:tabKind]) num++;
    }
    return num;
}

- (NSArray *)tabsForType:(NSString *)type {
    NSMutableArray *tabs = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSDictionary *tab in self.tabs) {
        NSString *tabKind = [tab objectForKey:kRBFormKeyTabKind];
        if ((tabKind == nil && [type isEqualToString:@"default"]) || [type isEqualToString:tabKind]) {
            [tabs addObject:tab];
        }
    }
    return tabs;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        int i = 0;
        for (UIButton *addContactButton in self.addContactButtons) {
            NSString *type = [self.recipientTypes objectAtIndex:i];
            addContactButton.enabled = [self recipientsForType:type].count < [self maxNumberOfRecipientsForType:type];
            i++;
        }
        [self.tableViews makeObjectsPerformSelector:@selector(reloadData)];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

- (void)setRecipients:(NSArray *)recipients {
    NSMutableArray *r = [NSMutableArray array];
    for (NSString *type in self.recipientTypes) {
        NSMutableArray *recips = [NSMutableArray array];
        for (NSDictionary *recipient in recipients) {
            if ([[recipient objectForKey:kRBRecipientKind] isEqualToString:type]) {
                [recips addObject:recipient];
            }
        }
        [r addObject:recips];
    }
    self.recipientsForTypes = r;
}

- (NSArray *)recipients {
    NSMutableArray *r = [NSMutableArray array];
    for (NSArray *recips in self.recipientsForTypes) {
        [r addObjectsFromArray:recips];
    }
    return r;
}

- (void)setTabs:(NSArray *)tabs {
    
    if (tabs_ == tabs) return;
    
    tabs_ = tabs;
    [tableViews_ makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.tableViews = nil;
    self.addContactButtons = nil;
    if (tabs_) {
        NSMutableArray *tableViews = [NSMutableArray array];
        NSMutableArray *addContactButtons = [NSMutableArray array];
        
        int typeIndex = 0;
        CGFloat height = floorf((self.bounds.size.height - 10.f) / self.recipientTypes.count);
        for (NSString *recipientType in self.recipientTypes) {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 90.f)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 450, 35.f)];
            label.font = [UIFont fontWithName:kRBFontName size:19];
            label.textColor = kRBColorMain;
            label.backgroundColor = [UIColor clearColor];
            label.text = [NSString stringWithFormat:@"%@ Signers", [recipientType isEqualToString:@"default"] ? @"" : [recipientType titlecaseString]];
            [headerView addSubview:label];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(45.f, 40.f, 400.f, 35.f)];
            label.font = [UIFont fontWithName:kRBFontName size:18];
            label.textColor = kRBColorMain;
            label.backgroundColor = [UIColor clearColor];
            label.text = [NSString stringWithFormat:@"Add %@ Signer", [recipientType isEqualToString:@"default"] ? @"" : [recipientType titlecaseString]];
            [headerView addSubview:label];
            
            UIButton *addContactButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [addContactButton setImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
            addContactButton.frame = CGRectMake(0.f, label.frameTop, 35.f, 35.f);
            addContactButton.tag = typeIndex;
            [addContactButton addTarget:self action:@selector(handleAddContactPress:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:addContactButton];
            [addContactButtons addObject:addContactButton];
            
            //RBHQ Change: Hide Recipient Add For the RB-Signers
            if([recipientType isEqualToStringIgnoringCase:@"rb"]){
                label.hidden=YES,
                addContactButton.hidden=YES;
            }
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(545.f, 5.f + typeIndex * height, 450.f, height) style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            if (typeIndex == 0) {
                tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
            }
            else if (typeIndex == self.recipientTypes.count - 1) {
                tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
            }
            else {
                tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
            }
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            tableView.tableHeaderView = headerView; 
            tableView.tag = typeIndex;
            // tableView_.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
            tableView.editing = YES;
            [self addSubview:tableView];
            [tableViews addObject:tableView];
            typeIndex++;
        }
        self.tableViews = tableViews;
        self.addContactButtons = addContactButtons;
    }        
    
}

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
    return [self maxNumberOfRecipientsForType:[self.recipientTypes objectAtIndex:tableView.tag]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RBRecipientTableViewCell *cell = [RBRecipientTableViewCell cellForTableView:tableView style:UITableViewCellStyleDefault];
    cell.delegate = self;
    cell.image = nil;
    cell.mainText = nil;
    cell.detailText = nil;
    cell.code = 0;
    cell.signerType = 0;
    cell.idcheck = NO;
    [cell disableAuth];
    [cell disableTypeSelection];
        //RBHQ -> fix placeholder to RedBull Inc. if group 0
    if(tableView.tag == 1){
        NSString *type = [self.recipientTypes objectAtIndex:tableView.tag];
        cell.placeholderText = [[[self tabsForType:type] objectAtIndex:indexPath.row] objectForKey:kRBFormKeyTabLabel];}
    else{
        cell.placeholderText = [NSString stringWithFormat:@"Red Bull Inc. %d",indexPath.row+1];}
    
    if (indexPath.row < [[self.recipientsForTypes objectAtIndex:tableView.tag] count]) {
       
        NSDictionary *personDict = [[self.recipientsForTypes objectAtIndex:tableView.tag] objectAtIndex:indexPath.row];
         //RBHQ - Temp Cells - if RecipientPersonID = 0
        if([[personDict valueForKey:kRBRecipientPersonID] intValue] != 0){
        
        ABPerson *person;
        
            person = [[ABAddressBook sharedAddressBook] personWithRecordID:[[personDict valueForKey:kRBRecipientPersonID] intValue]];
            if (person.imageData != nil) {
                cell.image = [UIImage imageWithData:person.imageData];
            }
            else {
                cell.image = [UIImage imageNamed:@"EmptyContact"];
            }
            [cell enableTypeSelection];
            cell.mainText = person.fullName;
            cell.code = [personDict valueForKey:kRBRecipientCode] ? [[personDict valueForKey:kRBRecipientCode] intValue] : 0;
            cell.signerType = [personDict valueForKey:kRBRecipientType] ? [[personDict valueForKey:kRBRecipientType] intValue] : 0;
            cell.idcheck = [personDict valueForKey:kRBRecipientIDCheck] && [[personDict valueForKey:kRBRecipientIDCheck] intValue] > 0 ? YES : NO;
            cell.detailText = [person emailForID:[personDict valueForKey:kRBRecipientEmailID]];
            cell.placeholderText = nil;
        }
    }
    
    //RBHQ Add - give the rows in the first section ids to know wich popover belongs to which id
    if(tableView.tag == 0)
    {
        cell.orderOfSigner=indexPath.row+1;
    }else{
        cell.orderOfSigner=NOSUPERIORGROUP;
    }
    return cell;
}

// no cell is selectable

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)didSelectRowWithOrderOfSigner:(NSUInteger)orderType AndTouches:(NSSet *)touches{
    if(orderType != NOSUPERIORGROUP && orderType <3)
    {
    CGPoint point = [[touches anyObject] locationInView:self];
    self.recPicTVC = [[RBRecipientPickerViewController alloc] init];
    self.recPicTVC.delegate=self;
        
    NSArray *selectedEmails =[selectedRecipientsAtPosition_ allValues];
    NSArray * recipients = [RBAvailableRecipients findByAttribute:@"superiorGroup" withValue:[NSNumber numberWithInt:orderType]];
    NSMutableArray *recNames = [[NSMutableArray alloc] initWithArray:recipients];
    //Remove Recipients which are already selected
    for(RBAvailableRecipients *recip in recipients) {
        if([selectedEmails containsObject:recip.email]) {
            [recNames removeObject:recip];
        }
    }
        
    self.recPicTVC.recipientnames =recNames;
    self.recipientPopover = [[UIPopoverController alloc] initWithContentViewController:self.recPicTVC];
        
    self.noOfCellPickerActive=orderType-1;
    [recipientPopover_ presentPopoverFromRect:CGRectMake(point.x-20, point.y, 40, 20) inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   //Change RBHQ
   // only account signer cell is deletable
    RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ((rbAccountSignerSelected_ == 1 || cell.detailText.length > 0) && tableView.tag==1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [(NSMutableArray *)[self.recipientsForTypes objectAtIndex:tableView.tag] removeObjectAtIndex:indexPath.row];

        rbAccountSignerSelected_=NO;
        [self redrawTableData:tableView];
        ((UIButton *)[self.addContactButtons objectAtIndex:[self.tableViews indexOfObject:tableView]]).enabled = YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
   //Change RBHQ 
    
  //  RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  //  if (cell.mainText) {
  //      return YES;
  //  }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[tableView cellForRowAtIndexPath:proposedDestinationIndexPath];
    if (cell.mainText) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (destinationIndexPath.row < [[self.recipientsForTypes objectAtIndex:tableView.tag] count]) {
        [(NSMutableArray *)[self.recipientsForTypes objectAtIndex:tableView.tag] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    }
    else {
        [self redrawTableData:tableView];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)redrawTableData:(UITableView *)tableView {
    NSString *type = [self.recipientTypes objectAtIndex:tableView.tag];
    for (int i = 0; i < [[self tabsForType:type] count]; i++) {
        RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.image = nil;
        cell.mainText = nil;
        cell.code = 0;
        cell.signerType = 0;
        cell.idcheck = NO;
        cell.detailText = nil;
        if(tableView.tag == 1){
            cell.placeholderText = [[[self tabsForType:type] objectAtIndex:i] objectForKey:kRBFormKeyTabLabel];
            rbAccountSignerSelected_=NO;
            [cell setEditing:NO animated:NO];
            [tableView reloadData];
        }else{
            cell.placeholderText = [NSString stringWithFormat:@"Red Bull Inc. %d",i+1];
        }
        [cell disableAuth];
        [cell disableTypeSelection];
        
        if (i < [[self.recipientsForTypes objectAtIndex:tableView.tag] count]) {
            NSDictionary *personDict = [[self.recipientsForTypes objectAtIndex:tableView.tag] objectAtIndex:i];
      
            ABPerson *person=nil;
            person = [[ABAddressBook sharedAddressBook] personWithRecordID:[[personDict valueForKey:kRBRecipientPersonID] intValue]];
            if(person != nil){
            if (person.imageData != nil) {
                cell.image = [UIImage imageWithData:person.imageData];
            }
            else {
                cell.image = [UIImage imageNamed:@"EmptyContact"];
            }
            [cell enableTypeSelection];
            cell.mainText = person.fullName;
            cell.code = [personDict valueForKey:kRBRecipientCode] ? [[personDict valueForKey:kRBRecipientCode] intValue] : 0;
            cell.signerType = [personDict valueForKey:kRBRecipientType] ? [[personDict valueForKey:kRBRecipientType] intValue] : 0;
            cell.idcheck = [personDict valueForKey:kRBRecipientIDCheck] && [[personDict valueForKey:kRBRecipientIDCheck] intValue] > 0 ? YES : NO;
            cell.detailText = [person emailForID:[personDict valueForKey:kRBRecipientEmailID]];
            cell.placeholderText = nil;
            if(tableView.tag == 1) {
                rbAccountSignerSelected_=YES;
                [cell setEditing:YES animated:NO];
                [tableView reloadData];
                }
            }
        }
    }
}

- (void)cell:(RBRecipientTableViewCell *)cell changedCode:(int)code idCheck:(BOOL)idCheck {
    NSIndexPath *indexPath;
    UITableView *tableView;
    for (UITableView *tv in self.tableViews) {
        indexPath = [tv indexPathForCell:cell];
        if (indexPath) {
            tableView = tv;
            break;
        }
    }
    int index = indexPath.row;
    
    NSArray *r = [self.recipientsForTypes objectAtIndex:tableView.tag];
    if (index < [r count]) {
        [[r objectAtIndex:index] setObject:[NSNumber numberWithInt:code] forKey:kRBRecipientCode];
        [[r objectAtIndex:index] setObject:[NSNumber numberWithBool:idCheck] forKey:kRBRecipientIDCheck];
    }
}

- (void)cell:(RBRecipientTableViewCell *)cell changedSignerType:(int)type {
    NSIndexPath *indexPath;
    UITableView *tableView;
    for (UITableView *tv in self.tableViews) {
        indexPath = [tv indexPathForCell:cell];
        if (indexPath) {
            tableView = tv;
            break;
        }
    }
    int index = indexPath.row;
    
    NSArray *r = [self.recipientsForTypes objectAtIndex:tableView.tag];
    if (index < [r count]) {
        [[r objectAtIndex:index] setObject:[NSNumber numberWithInt:type] forKey:kRBRecipientType];
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
    NSString *type = [self.recipientTypes objectAtIndex:lastButtonPressed.tag];
    
    ABPerson *personWrapper = [[ABAddressBook sharedAddressBook] personWithRecordRef:person];
    NSMutableDictionary *personDict = XMDICT($I(personWrapper.recordID), kRBRecipientPersonID, $I(identifier), kRBRecipientEmailID, $I(kRBRecipientTypeInPerson), kRBRecipientType, type, kRBRecipientKind);
    
    if ([self.recipients indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([[obj objectForKey:kRBRecipientPersonID] intValue] == personWrapper.recordID) {
                *stop = YES;
                return YES;
            }
            ABPerson *p = [[ABAddressBook sharedAddressBook] personWithRecordID:[[obj valueForKey:kRBRecipientPersonID] intValue]];
            if ([[p getFirstName] isEqualToString:[personWrapper getFirstName]] &&
                [[p getLastName] isEqualToString:[personWrapper getLastName]]) {
                *stop = YES;
                return YES;
            }
            ABMultiValue *emails = [p valueForProperty:kABPersonEmailProperty];
            for (int i = 0; i < [emails count]; i++) {
                if ([[emails valueAtIndex:i] isEqualToStringIgnoringCase:[personWrapper emailForID:[personDict valueForKey:kRBRecipientEmailID]]]) {
                    *stop = YES;
                    return YES;
                }
            }
        }
        return NO;
    }] != NSNotFound) {
        [MTApplicationDelegate showErrorMessage:@"Recipient has been added already."];
    } else {
        [(NSMutableArray *)[self.recipientsForTypes objectAtIndex:lastButtonPressed.tag] addObject:personDict];
        [self redrawTableData:[self.tableViews objectAtIndex:lastButtonPressed.tag]];
    }
    
    if ([self recipientsForType:type].count >= [self maxNumberOfRecipientsForType:type]) {
        lastButtonPressed.enabled = NO;
        [self.viewControllerResponder dismissModalViewControllerAnimated:YES];
        [self.viewControllerResponder performSelector:@selector(showSuccessMessage:) 
                                           withObject:[NSString stringWithFormat:@"Maximum number of %@ signers for this form added.", [type isEqualToString:@"default"] ? @"" : type] 
                                           afterDelay:1.5];
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
    lastButtonPressed = (UIButton *)sender;
    NSString *type = [self.recipientTypes objectAtIndex:lastButtonPressed.tag];
    if ([self recipientsForType:type].count < [self maxNumberOfRecipientsForType:type]) {
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
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
	picker.displayedProperties = XARRAY([NSNumber numberWithInt:kABPersonEmailProperty]);
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
	// Show the picker 
	[self.viewControllerResponder presentModalViewController:picker animated:YES];
}

- (void)showNewContactScreen {
    ABNewPersonViewController *viewController = [[ABNewPersonViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
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

#pragma mark - Recipients Picker Delegate
- (void)didSelectRecipient:(RBAvailableRecipients *)recip{
    [self.recipientPopover dismissPopoverAnimated:YES];
    
    [selectedRecipientsAtPosition_ setObject:recip.email forKey:[NSNumber numberWithInt:noOfCellPickerActive_]];
    
    NSArray *people = [[ABAddressBook sharedAddressBook] allPeople];
    ABPerson *recipPerson = nil;
    //Look if Person already exist
    for (ABPerson *person in people) {
        if ([[person getFirstName] isEqualToStringIgnoringCase:recip.firstname] &&
            [[person getLastName] isEqualToStringIgnoringCase:recip.lastname]) {
            recipPerson = person;
            break;
        }
    }
    if (recipPerson == nil) {
        NSError *error;
        recipPerson = [[ABPerson alloc] init];
        if (recip.firstname) {
            [recipPerson setValue:recip.firstname forProperty:kABPersonFirstNameProperty error:nil];
        }
        if (recip.lastname) {
            [recipPerson setValue:recip.lastname forProperty:kABPersonLastNameProperty error:nil];
        }
        [[ABAddressBook sharedAddressBook] addRecord:recipPerson error:&error];
        [[ABAddressBook sharedAddressBook] save:&error];
    }
    
    ABMultiValue *emails = [recipPerson valueForProperty:kABPersonEmailProperty];
    if (emails == nil || [emails indexOfValue:recip.email] == (NSUInteger)-1L) {
        NSError *error;
        if (emails == nil) {
            emails = [[ABMutableMultiValue alloc] initWithPropertyType:kABPersonEmailProperty];
        }
        else {
            emails = [emails mutableCopy];
        }
        [(ABMutableMultiValue *)emails addValue:recip.email withLabel:(NSString *)kABWorkLabel identifier:nil];
        [recipPerson setValue:emails forProperty:kABPersonEmailProperty error:nil];
        [[ABAddressBook sharedAddressBook] save:&error];
        
        emails = [recipPerson valueForProperty:kABPersonEmailProperty];
    }
    ABMultiValueIdentifier identifier;
    for (int i = 0; i < [emails count]; i++) {
        if ([[emails valueAtIndex:i] isEqualToStringIgnoringCase:recip.email]) {
            identifier = [emails identifierAtIndex:i];
            break;
        }
    }
    
    NSMutableDictionary *personDict = XMDICT($I(recipPerson.recordID), kRBRecipientPersonID, $I(identifier), kRBRecipientEmailID, $I(kRBRecipientTypeInPerson), kRBRecipientType, @"RB", kRBRecipientKind);
    

    [(NSMutableArray *)[self.recipientsForTypes objectAtIndex:0] replaceObjectAtIndex:noOfCellPickerActive_ withObject:personDict];
    
    [self redrawTableData:[self.tableViews objectAtIndex:0]];
}

@end
