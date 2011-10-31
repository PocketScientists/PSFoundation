//
//  RBClientEditViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 27.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBClientEditViewController.h"
#import "PSIncludes.h"
#import "SSLineView.h"
#import "RBClient+RBProperties.h"
#import "UIControl+RBForm.h"
#import "TPKeyboardAvoidingScrollView.h"


#define kRBRowHeight    30

@interface RBClientEditViewController ()

@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, assign) BOOL clientWasCreated;
@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) NSMutableArray *mappingTextFields;

- (void)handleCancelButtonPress:(id)sender;
- (void)handleDoneButtonPress:(id)sender;

- (void)addInputFieldWithLabel:(NSString *)label;
- (void)saveEnteredValuesToClient;

@end

@implementation RBClientEditViewController

@synthesize currentY = currentY_;
@synthesize client = client_;
@synthesize clientWasCreated = clientWasCreated_;
@synthesize headerLabel = headerLabel_;
@synthesize doneButton = doneButton_;
@synthesize cancelButton = cancelButton_;
@synthesize mappingTextFields = mappingTextFields_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        mappingTextFields_ = [[NSMutableArray alloc] init];
        currentY_ = 90.f;
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(client_);
    MCRelease(headerLabel_);
    MCRelease(doneButton_);
    MCRelease(cancelButton_);
    MCRelease(mappingTextFields_);
    
    [super dealloc];
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
    TPKeyboardAvoidingScrollView *scrollView = [[[TPKeyboardAvoidingScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    
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
    
    self.headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 28, 300, cancelImage.size.height)] autorelease];
    self.headerLabel.font = [UIFont fontWithName:kRBFontName size:20];
    self.headerLabel.text = (self.client != nil && !self.client.clientCreatedForEditing) ? @"Edit Client" : @"New Client";
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = kRBColorMain;
    
    [self.view addSubview:self.headerLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
    
    if (self.client == nil) {
        self.clientWasCreated = YES;
        self.client = [RBClient createEntity];
    } else if (self.client.clientCreatedForEditing) {
        self.clientWasCreated = YES;
    }
    
    // Add input fields
    for (NSString *property in [RBClient propertyNamesForMapping]) {
        [self addInputFieldWithLabel:property];
    }
        
    [(UIScrollView *)self.view setContentSize:CGSizeMake(1, self.currentY)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.cancelButton = nil;
    self.doneButton = nil;
    self.headerLabel = nil;
    if (self.clientWasCreated) {
        self.client = nil;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleCancelButtonPress:(id)sender {
    PSAlertView *alertView = [PSAlertView alertWithTitle:(IsEmpty(self.client.name) ? @"Edit Client" : self.client.name) 
                                                 message:@"Do you want to discard your changes?"];
    
    [alertView addButtonWithTitle:@"Discard" block:^(void) {
        if (self.clientWasCreated) {
            [self.client deleteEntity];
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    [alertView setCancelButtonWithTitle:@"Don't discard" block:nil];
    
    [alertView show];
}

- (void)handleDoneButtonPress:(id)sender {
    [self saveEnteredValuesToClient];
    
    [self dismissModalViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)addInputFieldWithLabel:(NSString *)label {
    UILabel *fieldLabel = [[[UILabel alloc] initWithFrame:CGRectMake(35, self.currentY, 472, 20)] autorelease];
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(35, self.currentY + 23, 472, kRBRowHeight)] autorelease];
    
    fieldLabel.backgroundColor = [UIColor clearColor];
    fieldLabel.textColor = kRBColorMain;
    fieldLabel.text = [label capitalizedString];
    fieldLabel.font = [UIFont fontWithName:kRBFontName size:17];
    
    textField.borderStyle = UITextBorderStyleBezel;
    textField.backgroundColor = [UIColor whiteColor];
    textField.font = [UIFont fontWithName:kRBFontName size:18];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.text = [self.client.name isEqualToString:@"Unknown"] ? @"" : [[self.client valueForKey:label] description];
    textField.formMappingName = label;
    
    [self.view addSubview:fieldLabel];
    [self.view addSubview:textField];
    [self.mappingTextFields addObject:textField];
    
    self.currentY += kRBRowHeight + 35;
}

- (void)saveEnteredValuesToClient {
    for (UITextField *textField in self.mappingTextFields) {
        NSString *stringValue = textField.text;
        
        [self.client setStringValue:stringValue forKey:textField.formMappingName];
    }
}

@end