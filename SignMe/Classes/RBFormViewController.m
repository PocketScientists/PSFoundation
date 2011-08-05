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
#import "RBPersistenceManager.h"
#import "UIControl+RBForm.h"
#import "RBDocument.h"
#import "RBDocument+RBForm.h"
#import "AppDelegate.h"


#define kRBOffsetTop               212.f
#define kRBOffsetBottom             58.f

@interface RBFormViewController ()

@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) SSLineView *topLine;
@property (nonatomic, retain) SSLineView *bottomLine;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *doneButton;

- (void)handleCancelButtonPress:(id)sender;
- (void)handleDoneButtonPress:(id)sender;

- (void)updateFormFromControls;

@end

@implementation RBFormViewController

@synthesize form = form_;
@synthesize client = client_;
@synthesize document = document_;
@synthesize headerLabel = headerLabel_;
@synthesize topLine = topLine_;
@synthesize bottomLine = bottomLine_;
@synthesize formView = formView_;
@synthesize cancelButton = cancelButton_;
@synthesize doneButton = doneButton_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithForm:(RBForm *)form client:(RBClient *)client {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        form_ = [form retain];
        client_ = [client retain];
    }
    
    return self;
}

- (id)initWithDocument:(RBDocument *)document {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        document_ = [document retain];
        form_ = [document.form retain];
        client_ = [document.client retain];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(form_);
    MCRelease(document_);
    MCRelease(headerLabel_);
    MCRelease(topLine_);
    MCRelease(bottomLine_);
    MCRelease(formView_);
    MCRelease(client_);
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    RBUIGenerator *generator = [[[RBUIGenerator alloc] init] autorelease];
    
    self.formView = [generator viewWithFrame:CGRectMake(0, kRBOffsetTop, self.view.bounds.size.width, self.view.bounds.size.height-kRBOffsetTop-kRBOffsetBottom)
                                        form:self.form
                                      client:self.client
                                    document:self.document];
    
    self.headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30, 172, 580, 27)] autorelease];
    self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = kRBColorMain;
    self.headerLabel.textAlignment = UITextAlignmentLeft;
    self.headerLabel.font = [UIFont fontWithName:kRBFontName size:24.];
    self.headerLabel.text = [self.form.displayName stringByAppendingFormat:@": %@", self.client.name];
    
    self.topLine = [[[SSLineView alloc] initWithFrame:CGRectMake(30, 202, 690, 1)] autorelease];
    self.topLine.lineColor = [UIColor colorWithWhite:1.f alpha:0.3f];
    self.topLine.insetColor = nil;
    
    self.bottomLine = [[[SSLineView alloc] initWithFrame:CGRectMake(30, 700, 690, 1)] autorelease];
    self.bottomLine.lineColor = [UIColor colorWithWhite:1.f alpha:0.3f];
    self.bottomLine.insetColor = nil;
    
    UIImage *cancelImage = [UIImage imageNamed:@"AbortButton"];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setImage:cancelImage forState:UIControlStateNormal];
    self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.cancelButton.frame = CGRectMake(571, 165, cancelImage.size.width, cancelImage.size.height);
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *doneImage = [UIImage imageNamed:@"SaveButton"];
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setImage:doneImage forState:UIControlStateNormal];
    self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.doneButton.frame = CGRectMake(651, 165, doneImage.size.width, doneImage.size.height);
    [self.doneButton addTarget:self action:@selector(handleDoneButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.headerLabel];
    [self.view addSubview:self.topLine];
    [self.view addSubview:self.bottomLine];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
    [self.view addSubview:self.formView];
    [self.view addSubview:self.formView.pageControl];
    [self.view addSubview:self.formView.prevButton];
    [self.view addSubview:self.formView.nextButton]; 
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.formView = nil;
    self.headerLabel = nil;
    self.cancelButton = nil;
    self.doneButton = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.formView flashScrollIndicators];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleCancelButtonPress:(id)sender {
    PSAlertView *alertView = [PSAlertView alertWithTitle:self.form.displayName message:@"Do you want to discard your changes?"];
    
    [alertView addButtonWithTitle:@"Discard" block:^(void) {
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    [alertView setCancelButtonWithTitle:@"Don't discard" block:nil];
    
    [alertView show];
}

- (void)handleDoneButtonPress:(id)sender {
    // update form-property with new values entered into controls
    [self updateFormFromControls];
    
    // go back to HomeViewController
    [self dismissModalViewControllerAnimated:YES];
    
    RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
    
    if (self.document != nil) {
        [persistenceManager updateDocument:self.document usingForm:self.form recipients:self.formView.recipients subject:self.formView.subject];
    } else {
        // create a new document with the given form/client
        self.document = [persistenceManager persistedDocumentUsingForm:self.form client:self.client recipients:self.formView.recipients subject:self.formView.subject];
    }
    
    // upload files to box.net
    if (self.document != nil && [[RBBoxService box] isLoggedIn]) {
        [RBBoxService uploadDocument:self.document toFolderAtPath:RBPathToPreSignatureFolderForClientWithName(self.client.name)];
    }
    
    [MTApplicationDelegate.homeViewController updateUI];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)updateFormFromControls {
    // update the value in the form for each control
    for (UIControl *control in self.formView.formControls) {
        [self.form setValue:control.formTextValue forField:control.formID inSection:control.formSection];
    }
}

@end
