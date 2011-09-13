//
//  RBHomeViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 19.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "PSIncludes.h"
#import "RBHomeViewController.h"
#import "RBFormViewController.h"
#import "RBForm.h"
#import "RBArrowView.h"
#import "RBCarouselView.h"
#import "RBClient.h"
#import "RBDocument.h"
#import "RBClientEditViewController.h"
#import "RBPersistenceManager.h"
#import "RBClient+RBProperties.h"
#import "RBDocuSignService.h"

#define kMinNumberOfItemsToWrap   6

#define kAnimationDuration      0.25
#define kFormsYOffset            40.f
#define kClientsYOffset          65.f
#define kDetailViewHeight       170.f
#define kDetailYOffset           95.f

#define kViewpointOffsetX       (self.addNewClientButton.frameWidth/2 + kRBClientsCarouselItemWidth)


@interface RBHomeViewController ()

@property (nonatomic, readonly) NSFetchedResultsController *clientsFetchController;
@property (nonatomic, readonly) NSFetchedResultsController *documentsFetchController;

@property (nonatomic, assign) CGFloat formsViewDefaultY;
@property (nonatomic, assign) CGFloat clientsViewDefaultY;

@property (nonatomic, retain) UILabel *formsLabel;
@property (nonatomic, retain) UILabel *clientsLabel;

@property (nonatomic, retain) RBFormDetailView *detailView;
@property (nonatomic, retain) iCarousel *detailCarousel;
@property (nonatomic, retain) NSArray *emptyForms;

@property (nonatomic, readonly, getter = isDetailViewVisible) BOOL detailViewVisible;
@property (nonatomic, readonly, getter = isSearchScreenVisible) BOOL searchScreenVisible;
@property (nonatomic, readonly) BOOL clientCarouselShowsAddItem;

@property (nonatomic, assign) NSInteger detailCarouselSelectedIndex;
@property (nonatomic, assign) NSInteger clientsCarouselSelectedIndex;

@property (nonatomic, assign) BOOL formsCarouselChangeWasInitiatedByTap;

// header label for a carousel
- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text;

// move a view vertically
- (void)moveViewsWithFactor:(CGFloat)factor;

- (void)formsCarouselDidSelectItemAtIndex:(NSInteger)index;
- (void)clientsCarouselDidSelectItemAtIndex:(NSInteger)index;
- (void)detailCarouselDidSelectItem:(UIControl *)item atIndex:(NSInteger)index;

- (void)updateDetailViewWithFormStatus:(RBFormStatus)formStatus;
- (void)showDetailView; // delay = 0
- (void)showDetailViewWithDelay:(NSTimeInterval)delay;
- (void)hideDetailView;

- (void)showSearchScreenWithDuration:(NSTimeInterval)duration;
- (void)hideSearchScreenWithDuration:(NSTimeInterval)duration;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)updateClientsWithSearchTerm:(NSString *)searchTerm;

- (RBClient *)clientWithName:(NSString *)name;
- (void)editClient:(RBClient *)client;
- (void)presentFormIfPossible;
- (void)presentFormViewControllerForForm:(RBForm *)form client:(RBClient *)client;
- (void)presentFormViewControllerForDocument:(RBDocument *)document;

- (NSUInteger)numberOfDocumentsToDisplay;
- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus;
- (void)updateCarouselSelectionState:(iCarousel *)carousel selectedItem:(UIControl *)selectedItem;

- (void)handleClientLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;
- (NSUInteger)numberOfClients;

- (void)previewDocument:(RBDocument *)document;
- (void)finalizeDocument:(RBDocument *)document;

@end

@implementation RBHomeViewController

@synthesize clientsFetchController = clientsFetchController_;
@synthesize documentsFetchController = documentsFetchController_;
@synthesize formsViewDefaultY = formsViewDefaultY_;
@synthesize clientsViewDefaultY = clientsViewDefaultY_;
@synthesize formsLabel = formsLabel_;
@synthesize clientsLabel = clientsLabel_;
@synthesize formsView = formsView_;
@synthesize formsCarousel = formsCarousel_;
@synthesize clientsView = clientsView_;
@synthesize clientsCarousel = clientsCarousel_;
@synthesize addNewClientButton = addNewClientButton_;
@synthesize detailView = detailView_;
@synthesize detailCarousel = detailCarousel_;
@synthesize emptyForms = emptyForms_;
@synthesize searchField = searchField_;
@synthesize detailCarouselSelectedIndex = detailCarouselSelectedIndex_;
@synthesize clientsCarouselSelectedIndex = clientsCarouselSelectedIndex_;
@synthesize formsCarouselChangeWasInitiatedByTap = formsCarouselChangeWasInitiatedByTap_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        detailCarouselSelectedIndex_ = NSNotFound;
        clientsCarouselSelectedIndex_ = NSNotFound;
        formsCarouselChangeWasInitiatedByTap_ = NO;
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(clientsFetchController_);
    MCRelease(documentsFetchController_);
    MCRelease(formsLabel_);
    MCRelease(clientsLabel_);
    MCRelease(formsView_);
    MCRelease(formsCarousel_);
    MCRelease(clientsView_);
    MCRelease(clientsCarousel_);
    MCRelease(searchField_);
    MCRelease(addNewClientButton_);
    MCRelease(detailView_);
    MCRelease(detailCarousel_);
    MCRelease(emptyForms_);
    
    [super dealloc];
}

- (void)insertTempData {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([self numberOfClients] == 0) {
            RBClient *c = nil;
            
            c = [RBClient createEntity];
            c.name = @"Client 1";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Client 2";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Client 3";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Client 4";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Client 5";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Alfred";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Cabana Club";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Staples Center Club Nokia";
            c.street = @"Center Street";
            c.zip = @"1234";
            c.company = @"Nokia";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Judokus";
            c.visible = $B(YES);
            
            c = [RBClient createEntity];
            c.name = @"Quark";
            c.visible = $B(YES);
            
            [[NSManagedObjectContext defaultContext] saveOnMainThread];
        }
        
    });
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    emptyForms_ = [[RBForm allEmptyForms] retain];
    
    self.formsViewDefaultY = self.formsView.frameTop;
    self.clientsViewDefaultY = self.clientsView.frameTop;
    
    // Perform CoreData fetch
    NSError *error = nil;
	if (self.clientsFetchController != nil && ![self.clientsFetchController performFetch:&error]) {
		DDLogError(@"Unresolved error fetching clients %@, %@", error, [error userInfo]);
	} 
    error = nil;
    if (self.documentsFetchController != nil && ![self.documentsFetchController performFetch:&error]) {
		DDLogError(@"Unresolved error fetching documents %@, %@", error, [error userInfo]);
	}
    
    // TODO: remove
    [self insertTempData];
    
    self.formsLabel = [self headerLabelForView:self.formsCarousel text:@"Forms"];
    self.clientsLabel = [self headerLabelForView:self.clientsCarousel text:@"Clients"];
    
    [self.formsView addSubview:self.formsLabel];
    [self.clientsView addSubview:self.clientsLabel];
    
    self.searchField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)] autorelease];
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.rightView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchFieldRightView"]] autorelease];
    self.searchField.rightViewMode = UITextFieldViewModeAlways;
    
    // we control centering for this carousel on our own
    self.formsCarousel.centerItemWhenSelected = NO;
    // we inset the viewpoint s.t. items in both carousel have same x-pos (clientsCarousel has other frame than formsCarousel)
    // we also add another item width, s.t. the first item (that is ususally centered) appears on first position
    self.clientsCarousel.viewpointOffset = CGSizeMake(kViewpointOffsetX, 0);
    
    self.detailView = [[[RBFormDetailView alloc] initWithFrame:self.formsView.frame] autorelease];
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.detailView.frameHeight = kDetailViewHeight;
    self.detailView.alpha = 0.f;
    
    self.detailCarousel = [[[iCarousel alloc] initWithFrame:CGRectInset(self.detailView.bounds,0.f,15.f)] autorelease];
    self.detailCarousel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.detailCarousel.delegate = self;
    self.detailCarousel.dataSource = self;
    [self.detailView addSubview:self.detailCarousel];
    
    [self.view insertSubview:self.detailView belowSubview:self.formsView];
    
    [self syncBoxNet];
    
    // center 2nd item of formsCarousel
    [self.formsCarousel reloadData];
    [self.formsCarousel scrollToItemAtIndex:RBFormStatusPreSignature animated:NO];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    self.timeView = nil;
    self.formsLabel = nil;
    self.clientsLabel = nil;
    self.formsView = nil;
    self.formsCarousel = nil;
    self.detailCarousel = nil;
    self.clientsView = nil;
    self.addNewClientButton = nil;
    self.clientsCarousel = nil;
    self.detailView = nil;
    MCReleaseNil(clientsFetchController_);
    MCReleaseNil(documentsFetchController_);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.clientsFetchController.delegate = self;
    self.documentsFetchController.delegate = self;
    
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.clientsFetchController.delegate = nil;
    self.documentsFetchController.delegate = nil;
    
    [self updateCarouselSelectionState:self.detailCarousel selectedItem:nil];
    [self updateCarouselSelectionState:self.clientsCarousel selectedItem:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.clientsCarousel.viewpointOffset = CGSizeMake(kViewpointOffsetX, 0);
    }
    else {
        self.clientsCarousel.viewpointOffset = CGSizeMake(kViewpointOffsetX - 120.0, 0);
    }
    [self.clientsCarousel scrollToItemAtIndex:self.clientsCarousel.currentItemIndex animated:YES];
}

- (void)updateUI {
    self.emptyForms = [RBForm allEmptyForms];
    
    if ([self isViewLoaded]) {
        [self.formsCarousel reloadData];
        [self.clientsCarousel reloadData];
        [self.detailCarousel reloadData];
        
        ((UIControl *)self.formsCarousel.currentView).selected = self.detailViewVisible;
    }
}

- (void)syncBoxNet {    
    // only update forms once a day
    if ([RBBoxService shouldSyncFolder]) {
        [RBBoxService syncFolderWithID:[NSUserDefaults standardUserDefaults].folderID
                           startedFrom:self
                          successBlock:^(id boxObject) {
                              BoxFolder *formsFolder = (BoxFolder *)[boxObject objectAtFilePath:RBPathToEmptyForms()];
                              
                              // download empty forms and plists
                              if (formsFolder != nil) {
                                  for (BoxFile *file in [formsFolder filesWithExtensions:XARRAY(kRBFormDataType,kRBPDFDataType)]) {
                                      DDLogInfo(@"Downloading %@", file.objectName);
                                      [[RBBoxService box] downloadFile:file
                                                         progressBlock:nil
                                                       completionBlock:^(BoxResponseType resultType, NSData *fileData) {
                                                           // save id of file under name of file in userDefaults
                                                           // this is to retreive the stored files later from the folder Documents/box.net
                                                           // because they are stored with objectID and objectName
                                                           [[NSUserDefaults standardUserDefaults] setObjectID:file.objectId 
                                                                          forObjectWithNameIncludingExtension:file.objectName];
                                                           
                                                           // update forms carousel
                                                           self.emptyForms = [RBForm allEmptyForms];
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                               [NSUserDefaults standardUserDefaults].formsUpdateDate = [NSDate date];
                                                               [self updateUI];
                                                           });
                                                       }];
                                  }
                              }
                              
                              // create folder for muskateer (userName)
                              if ([boxObject objectAtFilePath:kRBFolderUser] == nil) {
                                  [[RBBoxService box] createFolder:kRBFolderUser
                                                          inFolder:boxObject
                                                   completionBlock:^(BoxResponseType resultTypeCreation, NSObject *boxObjectCreation) {
                                                       if (resultTypeCreation != BoxResponseSuccess) {
                                                           DDLogError(@"Error creating folder for muskateer: %@, %d", kRBFolderUser, resultTypeCreation);
                                                           [self showErrorMessage:[NSString stringWithFormat:@"Error creating box.net folder for user %@", [BoxUser savedUser].userName]];
                                                       }
                                                   }];
                              }
                              
                          } failureBlock:nil];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark iCarouselDataSource
////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (carousel == self.formsCarousel) {
        return RBFormStatusCount;
    }
    
    else if (carousel == self.clientsCarousel) {
        NSInteger numberOfRows = [self numberOfClients];
        
        // Show add client view in that case
        if (self.searchScreenVisible && !IsEmpty(self.searchField.text) && numberOfRows == 0) {
            return 1;
        }
        
        return numberOfRows;
    }
    
    else if (carousel == self.detailCarousel) {
        if (self.formsCarousel.currentItemIndex == RBFormStatusNew) {
            return MAX(1,self.emptyForms.count);
        } else {
            return MAX(1,[self numberOfDocumentsToDisplay]);
        }
    }
    
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index {
    RBCarouselView *view = nil;
    
    if (carousel == self.formsCarousel) {
        view = [RBCarouselView carouselViewWithWidth:kRBFormsCarouselItemWidth];
        RBFormStatus formStatus = RBFormStatusForIndex(index);
        NSUInteger documentCount = [self numberOfDocumentsWithFormStatus:formStatus];
        
        [view setFromFormStatus:formStatus count:documentCount];
    } 
    
    else if (carousel == self.clientsCarousel) {
        view = [RBCarouselView carouselViewWithWidth:kRBClientsCarouselItemWidth];
        
        // do we have to show add item?
        if ([self numberOfClients] == 0 && index == 0) {
            view.isAddClientView = YES;
            [view setText:[NSString stringWithFormat:@"Add client\n'%@'",self.searchField.text]]; 
        }
        else  {
            RBClient *client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [view setFromClient:client];
            
            // long-press on client triggers edit-screen
            UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleClientLongPress:)] autorelease];
            [view addGestureRecognizer:longPress];
        }
    }
    
    else if (carousel == self.detailCarousel) {
        view = [RBCarouselView carouselViewWithWidth:kRBDetailCarouselItemWidth];
        
        if (self.formsCarousel.currentItemIndex == RBFormStatusNew) {
            if (self.emptyForms.count == 0) {
                [view setText:@"No Templates yet."];
            } else {
                [view setFromForm:[self.emptyForms objectAtIndex:index]];
            }
        } else {
            if ([self numberOfDocumentsToDisplay] == 0) {
                [view setText:@"No Forms yet."];
            } else {
                RBDocument *document = [self.documentsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                [view setFromDocument:document];
            }
        }
    }
    
    return view;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark iCarouselDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)carouselShouldWrap:(iCarousel *)carousel {
    return carousel.numberOfItems >= kMinNumberOfItemsToWrap;
}

- (BOOL)carouselShouldDisableUserInteractionOnNonCenteredItems:(iCarousel *)carousel {
    return NO;
}

- (float)carouselItemWidth:(iCarousel *)carousel {
    if (carousel == self.formsCarousel) {
        return kRBFormsCarouselItemWidth * kRBCarouselItemWidthScaleFactor;
    } 
    
    else if (carousel == self.clientsCarousel) {
        return kRBClientsCarouselItemWidth * kRBCarouselItemWidthScaleFactor;
    }
    
    else if (carousel == self.detailCarousel) {
        return kRBDetailCarouselItemWidth * kRBCarouselItemWidthScaleFactor;
    }
    
    return 0.f;
}

- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel {        
    // update detail view if user scrolled to new form while detailView is visible
    if (carousel == self.formsCarousel && self.detailViewVisible) {
        if (!self.formsCarouselChangeWasInitiatedByTap) {
            [self updateCarouselSelectionState:carousel selectedItem:(UIControl *)[carousel currentView]];
        }
        self.detailCarouselSelectedIndex = NSNotFound;
        
        [self updateDetailViewWithFormStatus:RBFormStatusForIndex(carousel.currentItemIndex)];
        [self.detailView reloadData];
    }
    
    self.formsCarouselChangeWasInitiatedByTap = NO;
}

- (void)carousel:(iCarousel *)carousel didSelectItem:(UIView *)selectedItem atIndex:(NSInteger)index {    
    if (carousel == self.formsCarousel) {
        [self formsCarouselDidSelectItemAtIndex:index];
    }
    
    else if (carousel == self.clientsCarousel) {
        [self clientsCarouselDidSelectItemAtIndex:index];
    }
    
    else if (carousel == self.detailCarousel) {
        [self detailCarouselDidSelectItem:(UIControl *)selectedItem atIndex:index];
    }
    
    [self updateCarouselSelectionState:carousel selectedItem:(UIControl *)selectedItem];
}

- (void)formsCarouselDidSelectItemAtIndex:(NSInteger)index {
    self.formsCarouselChangeWasInitiatedByTap = YES;
    self.detailCarouselSelectedIndex = NSNotFound;
    
    if (self.detailViewVisible) {
        [self hideDetailView];
        
        [self performBlock:^(void) {
            if (self.formsCarousel.currentItemIndex != index) {
                [self.formsCarousel scrollToItemAtIndex:index animated:YES];
                [self showDetailViewWithDelay:0.4];
            }
        } afterDelay:kAnimationDuration];
    } 
    
    // detail view is not visible currently -> show it
    else {
        if (self.formsCarousel.currentItemIndex != index) {
            [self.formsCarousel scrollToItemAtIndex:index animated:YES];
            [self performBlock:^(void) {
                [self updateDetailViewWithFormStatus:RBFormStatusForIndex(index)];
                [self showDetailView];
            } afterDelay:0.4];
            
        } else {
            [self updateDetailViewWithFormStatus:RBFormStatusForIndex(index)];
            [self showDetailView];
        }
    }
}

- (void)clientsCarouselDidSelectItemAtIndex:(NSInteger)index {
    if (index == self.clientsCarouselSelectedIndex) {
        self.clientsCarouselSelectedIndex = NSNotFound;
    } else {
        self.clientsCarouselSelectedIndex = index;
    }
    
    if (self.clientCarouselShowsAddItem && index == 0) {
        RBClient *client = [self clientWithName:self.searchField.text];
        client.clientCreatedForEditing = YES;
        [self editClient:client];
    } else if (RBFormStatusForIndex(self.formsCarousel.currentItemIndex) != RBFormStatusNew) {
        [self updateDetailViewWithFormStatus:RBFormStatusForIndex(self.formsCarousel.currentItemIndex)];
    } else {
        [self presentFormIfPossible];
    }
}

- (void)detailCarouselDidSelectItem:(UIControl *)item atIndex:(NSInteger)index {
    self.detailCarouselSelectedIndex = index;
    
    RBFormStatus formStatus = RBFormStatusForIndex(self.formsCarousel.currentItemIndex);
    
    // create a new document if user has already been selected
    if (formStatus == RBFormStatusNew) {
        if (self.emptyForms.count > 0) {
            [self presentFormIfPossible];
        }
    } 
    
    // pre-signed documents can be viewed or edited
    else if (formStatus == RBFormStatusPreSignature) {
        if ([self numberOfDocumentsWithFormStatus:formStatus] > 0) {
            RBDocument *document = [self.documentsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            PSActionSheet *actionSheet = [PSActionSheet sheetWithTitle:[[NSString stringWithFormat:@"Document '%@'", document.name] uppercaseString]];
            NSTimeInterval delay = (index != self.detailCarousel.currentItemIndex) ? 0.4 : 0.0;
            
            [actionSheet addButtonWithTitle:@"Edit" block:^(void) {
                [self presentFormViewControllerForDocument:document];
            }];
            
            [actionSheet addButtonWithTitle:@"View" block:^(void) {
                [self previewDocument:document];
            }];
            
            // send to DocuSign
            [actionSheet addButtonWithTitle:@"Finalize" block:^(void) {
                if (document.recipients.count > 0) {
                    PSAlertView *alertView = [PSAlertView alertWithTitle:document.name message:[NSString stringWithFormat:@"Do you want to finalize this document for %@?",document.client.name]];
                    
                    [alertView addButtonWithTitle:@"Finalize" block:^(void) {
                        [self finalizeDocument:document];
                    }];
                    
                    [alertView setCancelButtonWithTitle:@"Cancel" block:nil];
                    
                    [alertView show];
                } else {
                    [self showErrorMessage:@"Document has no recipients, cannot send!"];
                }
            }];
            
            // delete document
            [actionSheet setDestructiveButtonWithTitle:@"Delete" block:^(void) {
                PSAlertView *alertView = [PSAlertView alertWithTitle:document.name message:[NSString stringWithFormat:@"Do you really want to delete this document for %@?",document.client.name]];
                
                [alertView addButtonWithTitle:@"Delete" block:^(void) {
                    RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
                    [persistenceManager deleteDocument:document];
                    [self.formsCarousel reloadData];
                    [self performSelector:@selector(showSuccessMessage:) withObject:@"Document deleted" afterDelay:0.5f];
                }];
                
                [alertView setCancelButtonWithTitle:@"Cancel" block:nil];
                
                [alertView show];
            }];
            
            [self performBlock:^(void) {
                [actionSheet showFromRect:[self.view convertRect:(CGRect){CGPointMake(item.frameLeft,item.frameTop-30),item.size} fromView:item] 
                                   inView:self.view 
                                 animated:YES];
            } afterDelay:delay];
        }
    } 
    // signed documents can only be displayed
    else if (formStatus == RBFormStatusSigned) {
        if ([self numberOfDocumentsWithFormStatus:formStatus] > 0) {
            NSTimeInterval delay = (index != self.detailCarousel.currentItemIndex) ? 0.4 : 0.0;
            [self performBlock:^(void) {
                [self previewDocument:[self.documentsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];
            } afterDelay:delay];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)textFieldDidChangeValue:(UITextField *)textField {
    [self updateClientsWithSearchTerm:textField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.clientCarouselShowsAddItem) {
        // show all clients again
        textField.text = @"";
        [self updateClientsWithSearchTerm:textField.text];
    }
    
    [textField resignFirstResponder];
}

- (IBAction)textFieldDidEndOnExit:(UITextField *)textField {
    if (self.clientCarouselShowsAddItem) {
        RBClient *client = [self clientWithName:textField.text];
        // add new client
        [self editClient:client];
    }
    
    [textField resignFirstResponder];
}

- (IBAction)handleAddNewClientPress:(id)sender {
    self.detailCarouselSelectedIndex = NSNotFound;
    [self editClient:nil];
}

- (IBAction)handleBackgroundPress:(id)sender {
    [self.searchField resignFirstResponder];
    
    if (self.detailViewVisible) {
        [self hideDetailView];
    }
    
    [self updateCarouselSelectionState:self.formsCarousel selectedItem:nil];
}

- (void)handleClientLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        id attachedObject = ((RBCarouselView *)gestureRecognizer.view).attachedObject;
        
        if ([attachedObject isKindOfClass:[RBClient class]]) {
            [self editClient:(RBClient *)attachedObject];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Core Data Persistence
////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)clientsFetchController {
    if (clientsFetchController_ != nil) {
        return clientsFetchController_;
    }
    
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([RBClient class])
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"visible = YES"]];
    
    NSSortDescriptor *idSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:idSortDescriptor]];
    
    // create sections for beginDate
    clientsFetchController_ = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                  managedObjectContext:[NSManagedObjectContext defaultContext]
                                                                    sectionNameKeyPath:nil
                                                                             cacheName:nil];
    clientsFetchController_.delegate = self;
    
    return clientsFetchController_;
}

- (NSFetchedResultsController *)documentsFetchController {
    if (documentsFetchController_ != nil) {
        return documentsFetchController_;
    }
    
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([RBDocument class])
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *idSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:idSortDescriptor]];
    
    // create sections for beginDate
    documentsFetchController_ = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[NSManagedObjectContext defaultContext]
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    documentsFetchController_.delegate = self;
    
    return documentsFetchController_;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
////////////////////////////////////////////////////////////////////////

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller { 
    if (controller == self.clientsFetchController) {
        [self.clientsCarousel reloadData];
    } else {
        [self.detailView reloadData];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Moving Animations
////////////////////////////////////////////////////////////////////////

- (void)showDetailView {
    [self showDetailViewWithDelay:0.];
}

- (void)showDetailViewWithDelay:(NSTimeInterval)delay {
    if (!self.detailViewVisible) {
        self.detailView.frameTop = self.formsView.frameBottom;
        self.detailView.frameHeight = 0;
        [self.view bringSubviewToFront:self.formsView];
        
        [UIView animateWithDuration:kAnimationDuration
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void) {
                             [self moveViewsWithFactor:1.f];
                         } completion:^(BOOL finished) {
                             [self.view bringSubviewToFront:self.detailView];
                         }];
    } else {
        DDLogInfo(@"Detail view already visible.");
    }
}

- (void)hideDetailView {
    self.detailCarouselSelectedIndex = NSNotFound;
    
    if (self.detailViewVisible) {
        [self.view bringSubviewToFront:self.formsView];
        
        [UIView animateWithDuration:kAnimationDuration
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void) {
                             [self moveViewsWithFactor:-1.f];
                         } completion:nil];
    } else {
        DDLogInfo(@"Detail view not visible.");
    }
}

- (void)moveViewsWithFactor:(CGFloat)factor {
    self.detailView.alpha = MIN(1.f, factor+1.f); // factor = 1 -> alpha = 1, factor = -1 -> alpha = 0
    
    self.formsView.frameTop -= kFormsYOffset * factor;
    self.clientsView.frameTop += kClientsYOffset * factor;
    
    self.detailView.frame = CGRectMake(self.detailView.frameLeft, self.detailView.frameTop - kFormsYOffset * factor,
                                       self.detailView.frameWidth, factor > 0 ? kDetailViewHeight : 0.f);
}

- (void)showSearchScreenWithDuration:(NSTimeInterval)duration {
    self.detailCarouselSelectedIndex = NSNotFound;
    self.clientsCarouselSelectedIndex = NSNotFound;
    self.formsView.userInteractionEnabled = NO;
    self.detailView.frameTop = self.formsViewDefaultY;
    self.detailView.alpha = 0.f;
    self.addNewClientButton.alpha = 0.f;
    [self updateCarouselSelectionState:self.formsCarousel selectedItem:nil];
    
    [UIView animateWithDuration:duration
                          delay:0.f 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         // 44.f = height of search-area -> clients-carousel is on same spot as forms-carousel before
                         CGFloat newClientsY = self.formsViewDefaultY - 44.f;
                         CGFloat diffY = self.clientsViewDefaultY - newClientsY;
                         
                         // Move views up
                         self.formsView.alpha = 0.2;
                         if (PSIsLandscape()) {
                             isMovedUp = YES;
                             self.formsView.frameTop = self.formsViewDefaultY - diffY;
                             self.clientsView.frameTop = newClientsY;
                             // Make clients-carousel expand width to cover add button
                             self.clientsCarousel.frame = CGRectMake(self.addNewClientButton.frameLeft, self.clientsCarousel.frameTop,
                                                                     self.clientsView.frameWidth - self.clientsLabel.frameWidth, self.clientsCarousel.frameHeight);
                             self.clientsCarousel.viewpointOffset = CGSizeMake(355.f, 0);
                         }
                     } 
                     completion:nil];
}

- (void)hideSearchScreenWithDuration:(NSTimeInterval)duration {
    self.formsView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:duration animations:^(void) {
        self.formsView.alpha = 1.f;
        if (isMovedUp) {
            isMovedUp = NO;
            self.formsView.frameTop = self.formsViewDefaultY;
            self.clientsView.frameTop = self.clientsViewDefaultY;
            // show add-button again
            // Make clients-carousel expand width to cover add button
            self.clientsCarousel.frame = CGRectMake(self.addNewClientButton.frameRight, self.clientsCarousel.frameTop,
                                                    self.clientsView.frameWidth - self.clientsLabel.frameWidth - self.addNewClientButton.frameWidth, self.clientsCarousel.frameHeight);
            self.clientsCarousel.viewpointOffset = CGSizeMake(kViewpointOffsetX, 0);
        }
        self.addNewClientButton.alpha = 1.f;
    }];
}

- (BOOL)isSearchScreenVisible {
    return self.formsView.userInteractionEnabled == NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIKeyboard Handling
////////////////////////////////////////////////////////////////////////

- (void)keyboardWillShow:(NSNotification *)notification {
    NSTimeInterval animationDuration;
    CGRect keyboardFrame;
    
    // retreive frame of keyboard
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    // retreive duration of animation
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (CGRectIntersectsRect(keyboardFrame, self.view.frame)) {
        [self showSearchScreenWithDuration:animationDuration];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval animationDuration;
    
    // retreive duration of animation
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self hideSearchScreenWithDuration:animationDuration];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate
////////////////////////////////////////////////////////////////////////

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [controller autorelease];
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action {
    return YES;
}

/*- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller;
 // Preview presented/dismissed on document.  Use to set up any HI underneath.
 
 - (void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller;
 - (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller;
 // Options menu presented/dismissed on document.  Use to set up any HI underneath.
 
 - (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller;
 - (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller;
 // Open in menu presented/dismissed on document.  Use to set up any HI underneath.
 
 - (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application;	 // bundle ID
 - (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application;
 // Synchronous.  May be called when inside preview.  Usually followed by app termination.  Can use willBegin... to set annotation.
 
 - (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action;*/

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 150.f, 40.f)] autorelease];
    
    label.text = [text uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    label.transform = CGAffineTransformMakeRotation(MTDegreesToRadian(90));
    label.backgroundColor = kRBColorDetail2;
    label.textColor = kRBColorMain;
    label.font = [UIFont fontWithName:kRBFontName size:22.f];
    label.frameLeft = 0;
    label.frameBottom = view.frameBottom;
    
    return label;
}

- (BOOL)isDetailViewVisible {
    return self.detailView.alpha > 0 && self.detailView.frameHeight == kDetailViewHeight;
}

- (BOOL)clientCarouselShowsAddItem {
    if (self.clientsCarousel.visibleViews.count == 1) {
        RBCarouselView *selectedView = self.clientsCarousel.visibleViews.anyObject;
        
        return selectedView.isAddClientView;
    }
    
    return NO;
}

- (void)updateDetailViewWithFormStatus:(RBFormStatus)formStatus {    
    if (formStatus != RBFormStatusNew) {
        RBClient *client = nil;
        NSPredicate *predicate = nil;
        
        if (self.clientsCarouselSelectedIndex != NSNotFound) {
            client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:self.clientsCarouselSelectedIndex inSection:0]];
        }
        
        if (client != nil) {
            predicate = [NSPredicate predicateWithFormat:@"status = %d AND client = %@", formStatus, client];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"status = %d", formStatus];
        }
        
        self.documentsFetchController.fetchRequest.predicate = predicate;
        
        NSError *error = nil;
        if (![self.documentsFetchController performFetch:&error]) {
            DDLogError(@"Unresolved error fetching documents %@, %@", error, [error userInfo]);
        }  
    }
    
    [self.detailView reloadData];
}

- (void)updateClientsWithSearchTerm:(NSString *)searchTerm {
    NSPredicate *predicate = nil;
    
    if (!IsEmpty(searchTerm)) {
        predicate = [NSPredicate predicateWithFormat:@"visible = YES AND name contains[cd] %@", searchTerm];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"visible = YES"];
    }
    
    self.clientsFetchController.fetchRequest.predicate = predicate;
	
    NSError *error = nil;
    if (![self.clientsFetchController performFetch:&error]) {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }  
    
    [self.clientsCarousel reloadData];
} 

- (RBClient *)clientWithName:(NSString *)name {
    RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
    
    return [persistenceManager clientWithName:name];
}

- (void)editClient:(RBClient *)client {
    RBClientEditViewController *editViewController = [[[RBClientEditViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    editViewController.client = client;
    editViewController.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
    editViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:editViewController animated:YES];
}

- (void)presentFormIfPossible {
    if (RBFormStatusForIndex(self.formsCarousel.currentItemIndex) == RBFormStatusNew 
        && self.detailCarouselSelectedIndex != NSNotFound 
        && self.clientsCarouselSelectedIndex != NSNotFound) {
        [self performBlock:^(void) {
            RBForm *form = [[[self.emptyForms objectAtIndex:self.detailCarouselSelectedIndex] copy] autorelease];
            RBClient *client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:self.clientsCarouselSelectedIndex inSection:0]];
            
            [self presentFormViewControllerForForm:form client:client];
        } afterDelay:0.4];
    }
}

- (void)presentFormViewControllerForForm:(RBForm *)form client:(RBClient *)client { 
    RBFormViewController *viewController = [[[RBFormViewController alloc] initWithForm:form client:client] autorelease];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:viewController animated:YES];
}

- (void)presentFormViewControllerForDocument:(RBDocument *)document {
    RBFormViewController *viewController = [[[RBFormViewController alloc] initWithDocument:document] autorelease];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:viewController animated:YES];
}

- (void)updateCarouselSelectionState:(iCarousel *)carousel selectedItem:(UIControl *)selectedItem {
    BOOL wasSelectedBefore = NO;
    
    // set selected of all views to no
    if (selectedItem.selected == YES) {
        wasSelectedBefore = YES;
    }
    
    // nil -> setSelected:NO
    [carousel.visibleViews makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
    
    if (selectedItem != nil && !wasSelectedBefore) {
        // select current active view
        selectedItem.selected = YES;
    } else {
        if (carousel == self.detailCarousel) {
            self.detailCarouselSelectedIndex = NSNotFound;
        } else if (carousel == self.clientsCarousel) {
            self.clientsCarouselSelectedIndex = NSNotFound;
        }
    }
}

- (NSUInteger)numberOfDocumentsToDisplay {
    NSUInteger numberOfRows = 0;
    
    if (self.documentsFetchController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.documentsFetchController.sections objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
    
}

- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus {
    RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
    
    switch (formStatus) {
        case RBFormStatusNew:
            return self.emptyForms.count;
            
        case RBFormStatusPreSignature:
        case RBFormStatusSigned:
            return [persistenceManager numberOfDocumentsWithFormStatus:formStatus];
            
        case RBFormStatusCount:
        case RBFormStatusUnknown:
            return 0;
    }
}

- (NSUInteger)numberOfClients {
    NSUInteger numberOfRows = 0;
    
    if (self.clientsFetchController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.clientsFetchController.sections objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Document Handling
////////////////////////////////////////////////////////////////////////

- (void)previewDocument:(RBDocument *)document {
    NSString *pdfFilePath = RBPathToPDFWithName(document.fileURL);
    NSURL *url = [NSURL fileURLWithPath:pdfFilePath];
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    
    documentController.delegate = self;
    
    if (![documentController presentPreviewAnimated:YES]) {
        DDLogInfo(@"Wasn't able to display file");
    } else {
        [documentController retain];
    }
}

- (void)finalizeDocument:(RBDocument *)document {
    [RBDocuSignService sendDocument:document];
}

@end
