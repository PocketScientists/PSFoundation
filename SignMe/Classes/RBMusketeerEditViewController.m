//
//  RBMusketeerEditViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 27.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBMusketeerEditViewController.h"
#import "PSIncludes.h"
#import "SSLineView.h"
#import "RBMusketeer+RBProperties.h"
#import "UIControl+RBForm.h"
#import "RBKeyboardAvoidingScrollView.h"
#import "RBUIGenerator.h"
#import "VCTitleCase.h"

#define kRBRowHeight    30

@interface RBMusketeerEditViewController ()

@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, assign) BOOL musketeerWasCreated;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) NSMutableArray *mappingTextFields;
@property (nonatomic, strong) UIToolbar *navToolbar;
@property (nonatomic, strong) NSArray *states;

- (void)handleCancelButtonPress:(id)sender;
- (void)handleDoneButtonPress:(id)sender;

- (void)addInputFieldWithLabel:(NSString *)label index:(int)index;
- (void)saveEnteredValuesToMusketeer;

- (void)gotoPrevField:(id)sender;
- (void)gotoNextField:(id)sender;

@end

@implementation RBMusketeerEditViewController

@synthesize currentY = currentY_;
@synthesize musketeer = musketeer_;
@synthesize musketeerWasCreated = musketeerWasCreated_;
@synthesize headerLabel = headerLabel_;
@synthesize doneButton = doneButton_;
@synthesize cancelButton = cancelButton_;
@synthesize mappingTextFields = mappingTextFields_;
@synthesize navToolbar = navToolbar_;
@synthesize states = states_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        mappingTextFields_ = [[NSMutableArray alloc] init];
        currentY_ = 90.f;
        states_ = stateList;
    }
    
    return self;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)loadView {
    // TODO: This is a quick-fix solution because my custom RBKeyboardAvoidingScrollView doesn't work here
    // this should be changed to RBKeyboardAvoidingScrollView when there's more time (and fixed of course)
    RBKeyboardAvoidingScrollView *scrollView = [[RBKeyboardAvoidingScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeView.hidden = YES;
    self.fullLogoImageView.hidden = YES;
    self.logoSignMe.hidden = YES;
    
    UIImage *cancelImage = [UIImage imageNamed:@"AbortButton"];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setImage:cancelImage forState:UIControlStateNormal];
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.cancelButton.frame = CGRectMake(585, 28, cancelImage.size.width, cancelImage.size.height);
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *doneImage = [UIImage imageNamed:@"SaveButton"];
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setImage:doneImage forState:UIControlStateNormal];
    self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.doneButton.frame = CGRectMake(665, 28, doneImage.size.width, doneImage.size.height);
    [self.doneButton addTarget:self action:@selector(handleDoneButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 28, 300, cancelImage.size.height)];
    self.headerLabel.font = [UIFont fontWithName:kRBFontName size:20];
    self.headerLabel.text = (self.musketeer != nil && !self.musketeer.musketeerCreatedForEditing) ? @"Edit Musketeer" : @"New Musketeer";
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = kRBColorMain;
    
    [self.view addSubview:self.headerLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
    
    if (self.musketeer == nil) {
        self.musketeerWasCreated = YES;
        self.musketeer = [RBMusketeer loadEntity];
    } else if (self.musketeer.musketeerCreatedForEditing) {
        self.musketeerWasCreated = YES;
    }
    
    // Add input fields
//    int i = 100;
//    first = 100;
//    last = [RBMusketeer propertyNamesForMapping].count + 99;
//    for (NSString *property in [RBMusketeer propertyNamesForMapping]) {
//        [self addInputFieldWithLabel:property index:i];
//        i++;
//    }
    first = 100;
    last = 103;
    [self addInputFieldWithLabel:@"firstname" index:100];
    [self addInputFieldWithLabel:@"lastname" index:101];
    [self addInputFieldWithLabel:@"role" index:102];
    [self addInputFieldWithLabel:@"email" index:103];
    
    self.navToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 1024, 44)];
    self.navToolbar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoPrevField:)];
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoNextField:)];
    self.navToolbar.items = [NSArray arrayWithObjects:prevItem, nextItem, nil];
    
    [(UIScrollView *)self.view setContentSize:CGSizeMake(1, self.currentY)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.cancelButton = nil;
    self.doneButton = nil;
    self.headerLabel = nil;
    self.navToolbar = nil;
    if (self.musketeerWasCreated) {
        self.musketeer = nil;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleCancelButtonPress:(id)sender {
    PSAlertView *alertView = [PSAlertView alertWithTitle:(IsEmpty(self.musketeer.firstname) ? @"Edit Musketeer" : self.musketeer.firstname) 
                                                 message:@"Do you want to discard your changes?"];
    
    [alertView addButtonWithTitle:@"Discard" block:^(void) {
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    [alertView setCancelButtonWithTitle:@"Don't discard" block:nil];
    
    [alertView show];
}

- (void)handleDoneButtonPress:(id)sender {
    [self saveEnteredValuesToMusketeer];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)gotoPrevField:(id)sender {
    UIView *firstResponder = [self.view viewWithTag:self.navToolbar.tag-1];
    if (firstResponder) {
        [firstResponder becomeFirstResponder];
        
        RBKeyboardAvoidingScrollView *sv = (RBKeyboardAvoidingScrollView *)self.view;
        [sv moveResponderIntoPlace:firstResponder];
        return;
    }
    
    [[self.view viewWithTag:self.navToolbar.tag] resignFirstResponder];
}

- (void)gotoNextField:(id)sender {
    UIView *firstResponder = [self.view viewWithTag:self.navToolbar.tag+1];
    if (firstResponder) {
        [firstResponder becomeFirstResponder];
        
        RBKeyboardAvoidingScrollView *sv = (RBKeyboardAvoidingScrollView *)self.view;
        [sv moveResponderIntoPlace:firstResponder];
        return;
    }
    
    [[self.view viewWithTag:self.navToolbar.tag] resignFirstResponder];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)addInputFieldWithLabel:(NSString *)label index:(int)index {
    UILabel *fieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, self.currentY, 472, 20)];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(35, self.currentY + 23, 472, kRBRowHeight)];
    
    fieldLabel.backgroundColor = [UIColor clearColor];
    fieldLabel.textColor = kRBColorMain;
    fieldLabel.text = [label titlecaseString];
    fieldLabel.font = [UIFont fontWithName:kRBFontName size:17];
    
    textField.borderStyle = UITextBorderStyleBezel;
    textField.backgroundColor = [UIColor whiteColor];
    textField.font = [UIFont fontWithName:kRBFontName size:18];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.text = [self.musketeer.firstname isEqualToString:@"Unknown"] ? @"" : [[self.musketeer valueForKey:label] description];
    textField.formMappingName = label;
    textField.tag = index;
    textField.delegate = self;
    textField.returnKeyType = index != last ? UIReturnKeyNext : UIReturnKeyDone;
    if ([label isEqualToString:@"state"]) {
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        pickerView.showsSelectionIndicator = YES;
        textField.inputView = pickerView;
        NSInteger i = [self.states indexOfObject:textField.text];
        if (i != NSNotFound) {
            [pickerView selectRow:i inComponent:0 animated:NO];
        }
    }
    else if ([label isEqualToString:@"zip"]) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    [self.view addSubview:fieldLabel];
    [self.view addSubview:textField];
    [self.mappingTextFields addObject:textField];
    
    self.currentY += kRBRowHeight + 35;
}

- (void)saveEnteredValuesToMusketeer {
    for (UITextField *textField in self.mappingTextFields) {
        NSString *stringValue = textField.text;
        
        [self.musketeer setStringValue:stringValue forKey:textField.formMappingName];
        [self.musketeer saveEntity];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.navToolbar.tag = textField.tag;
    if (textField.tag == first) {
        ((UIBarButtonItem *)[self.navToolbar.items objectAtIndex:0]).enabled = NO;
    }
    else {
        ((UIBarButtonItem *)[self.navToolbar.items objectAtIndex:0]).enabled = YES;
    }
    if (textField.tag == last) {
        ((UIBarButtonItem *)[self.navToolbar.items objectAtIndex:1]).enabled = NO;
    }
    else {
        ((UIBarButtonItem *)[self.navToolbar.items objectAtIndex:1]).enabled = YES;
    }
    [textField setInputAccessoryView:self.navToolbar];

    if ([textField.text length] == 0 && [textField.inputView isKindOfClass:[UIPickerView class]]) {
        textField.text = [self.states objectAtIndex:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *firstResponder = [self.view viewWithTag:textField.tag+1];
    if (firstResponder) {
        [firstResponder becomeFirstResponder];
        
        RBKeyboardAvoidingScrollView *sv = (RBKeyboardAvoidingScrollView *)self.view;
        [sv moveResponderIntoPlace:firstResponder];

        return YES;
    }
    
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag != 102) {
        [self performBlock:^{
            textField.text = [textField.text titlecaseString];
        } afterDelay:0];
    }
    return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark - picker datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.states count];
}


#pragma mark - picker delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.states objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    UIView *v = [self findFirstResponderBeneathView:self.view];
    if ([v isKindOfClass:[UITextField class]]) {
        ((UITextField *)v).text = [self.states objectAtIndex:row];
    }
}



@end
