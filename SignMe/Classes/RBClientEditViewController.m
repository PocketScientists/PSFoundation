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
    UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeView.hidden = YES;
    self.emptyLogoImageView.hidden = YES;
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
    self.headerLabel.text = self.client != nil ? @"Edit Client" : @"New Client";
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = kRBColorMain;
    
    [self.view addSubview:self.headerLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
    
    if (self.client == nil) {
        self.clientWasCreated = YES;
        self.client = [RBClient createEntity];
    }
    
    // Add input fields
    for (NSString *property in [RBClient propertyNamesForMapping]) {
        [self addInputFieldWithLabel:property];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.cancelButton = nil;
    self.doneButton = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleCancelButtonPress:(id)sender {
    if (self.clientWasCreated) {
        [self.client deleteEntity];
    }
    
    [self dismissModalViewControllerAnimated:YES];
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
