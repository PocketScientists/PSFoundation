//
//  RBFormViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBFormViewController.h"
#import "RBUIGenerator.h"
#import "PSIncludes.h"


@interface RBFormViewController ()

- (void)handleCancelButtonPress:(id)sender;
- (void)handleDoneButtonPress:(id)sender;

@end

@implementation RBFormViewController

@synthesize form = form_;
@synthesize formView = formView_;
@synthesize headerLabel = headerLabel_;
@synthesize cancelButton = cancelButton_;
@synthesize doneButton = doneButton_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithForm:(RBForm *)form {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        form_ = [form retain];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(form_);
    MCRelease(formView_);
    MCRelease(headerLabel_);
    MCRelease(cancelButton_);
    MCRelease(doneButton_);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RBUIGenerator *generator = [[[RBUIGenerator alloc] init] autorelease];
    
    self.formView = [generator viewFromForm:self.form withFrame:self.view.bounds];
    
    self.headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(134, 40, 500, 44)] autorelease];
    self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.textAlignment = UITextAlignmentCenter;
    self.headerLabel.font = [UIFont boldSystemFontOfSize:22];
    self.headerLabel.text = [self.form.name uppercaseString];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.cancelButton.frame = CGRectMake(550, 40, 80, 44);
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.doneButton.frame = CGRectMake(650, 40, 80, 44);
    [self.doneButton addTarget:self action:@selector(handleDoneButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.formView];
    [self.view addSubview:self.headerLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.formView.pageControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.formView = nil;
    self.headerLabel = nil;
    self.cancelButton = nil;
    self.doneButton = nil;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleCancelButtonPress:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleDoneButtonPress:(id)sender {
    
}

@end
