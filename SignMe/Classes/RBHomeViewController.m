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
#import "RBRecipient.h"
#import "RBRecipient+RBDocuSign.h"
#import "RBClientEditViewController.h"
#import "RBMusketeerEditViewController.h"
#import "RBPersistenceManager.h"
#import "RBClient+RBProperties.h"
#import "RBDocuSignService.h"
#import "DocuSignService.h"
#import "NSData+Base64Additions.h"
#import "KeychainWrapper.h"


#define kMinNumberOfItemsToWrap   6

#define kAnimationDuration      0.25
#define kFormsYOffset            40.f
#define kClientsYOffset          65.f
#define kDetailViewHeight       170.f
#define kDetailYOffset           95.f

#define kLogoReq 42

#define kViewpointOffsetX       (self.addNewClientButton.frameWidth/2 + kRBClientsCarouselItemWidth)


@interface RBHomeViewController ()

@property (strong, nonatomic, readonly) NSFetchedResultsController *clientsFetchController;
@property (strong, nonatomic, readonly) NSFetchedResultsController *documentsFetchController;

@property (nonatomic, strong) NSMutableDictionary *currentNumberOfDocumentsInDetailCarousel;

@property (nonatomic, assign) CGFloat formsViewDefaultY;
@property (nonatomic, assign) CGFloat clientsViewDefaultY;

@property (nonatomic, strong) UILabel *formsLabel;
@property (nonatomic, strong) UILabel *clientsLabel;

@property (nonatomic, strong) RBFormDetailView *detailView;
@property (nonatomic, strong) iCarousel *detailCarousel;
@property (nonatomic, strong) NSArray *emptyForms;

@property (nonatomic, readonly, getter = isDetailViewVisible) BOOL detailViewVisible;
@property (nonatomic, readonly, getter = isSearchScreenVisible) BOOL searchScreenVisible;
@property (nonatomic, readonly) BOOL clientCarouselShowsAddItem;

@property (nonatomic, assign) NSInteger detailCarouselSelectedIndex;
@property (nonatomic, assign) NSInteger clientsCarouselSelectedIndex;

@property (nonatomic, strong) NSOperationQueue * ressourceLoadingHttpRequests;

@property (nonatomic, assign) BOOL formsCarouselChangeWasInitiatedByTap;

@property (nonatomic, strong) SKPSMTPMessage *emailMsg;

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
- (void)viewClient:(RBClient *)client;
- (void)presentFormIfPossible;
- (void)presentFormViewControllerForForm:(RBForm *)form client:(RBClient *)client;
- (void)presentFormViewControllerForDocument:(RBDocument *)document;

- (NSUInteger)numberOfDocumentsToDisplay;
- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus;
- (NSUInteger)actualNumberOfDocumentsWithFormStatus:(RBFormStatus)formStatus;
- (void)updateCarouselSelectionState:(iCarousel *)carousel selectedItem:(UIControl *)selectedItem;

- (void)handleClientLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;
- (NSUInteger)numberOfClients;

- (void)previewDocument:(RBDocument *)document;
- (void)previewDocumentOnDocuSign:(RBDocument *)document;
- (void)finalizeDocument:(RBDocument *)document;
- (void)cancelDocument:(RBDocument *)document;
- (void)signDocument:(RBDocument *)document recipient:(RBRecipient *)recipient;

- (void)startUpdate:(id)sender;

- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)outletRequestFinished:(ASIHTTPRequest *)request;
- (void)formRequestFinished:(ASIHTTPRequest *)request;
- (IBAction)mibHomeButtonPressed:(id)sender;

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
@synthesize actualizeBtn;
@synthesize detailCarouselSelectedIndex = detailCarouselSelectedIndex_;
@synthesize clientsCarouselSelectedIndex = clientsCarouselSelectedIndex_;
@synthesize formsCarouselChangeWasInitiatedByTap = formsCarouselChangeWasInitiatedByTap_;
@synthesize currentNumberOfDocumentsInDetailCarousel = currentNumberOfDocumentsInDetailCarousel_;
@synthesize ressourceLoadingHttpRequests=ressourceLoadingHttpRequests_;
@synthesize emailMsg = emailMsg_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        detailCarouselSelectedIndex_ = NSNotFound;
        clientsCarouselSelectedIndex_ = NSNotFound;
        formsCarouselChangeWasInitiatedByTap_ = NO;
        self.currentNumberOfDocumentsInDetailCarousel = [[NSMutableDictionary alloc] init];
    }
    
    return self;
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
    
    emptyForms_ = [RBForm allEmptyForms];
    
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
    //    [self insertTempData];
    
    self.formsLabel = [self headerLabelForView:self.formsCarousel text:@"Forms"];
    self.clientsLabel = [self headerLabelForView:self.clientsCarousel text:@"Clients"];
    
    [self.formsView addSubview:self.formsLabel];
    [self.clientsView addSubview:self.clientsLabel];
    
    self.searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchFieldRightView"]];
    self.searchField.rightViewMode = UITextFieldViewModeAlways;
    
    // we control centering for this carousel on our own
    self.formsCarousel.centerItemWhenSelected = NO;
    // we inset the viewpoint s.t. items in both carousel have same x-pos (clientsCarousel has other frame than formsCarousel)
    // we also add another item width, s.t. the first item (that is ususally centered) appears on first position
    self.clientsCarousel.viewpointOffset = CGSizeMake(kViewpointOffsetX + (UIInterfaceOrientationIsPortrait(PSAppStatusBarOrientation) ? -120 : 0), 0);
    
    self.detailView = [[RBFormDetailView alloc] initWithFrame:self.formsView.frame];
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.detailView.frameHeight = kDetailViewHeight;
    self.detailView.alpha = 0.f;
    
    self.detailCarousel = [[iCarousel alloc] initWithFrame:CGRectInset(self.detailView.bounds,0.f,15.f)];
    self.detailCarousel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.detailCarousel.delegate = self;
    self.detailCarousel.dataSource = self;
    [self.detailView addSubview:self.detailCarousel];
    
    [self.view insertSubview:self.detailView belowSubview:self.formsView];
    
    //[self syncBoxNet:NO];
    
    // center 2nd item of formsCarousel
    [self.formsCarousel reloadData];
    [self.formsCarousel scrollToItemAtIndex:RBFormStatusPreSignature animated:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startUpdate:)];
    [self.formsLabel addGestureRecognizer:tap];
}

- (void) viewDidUnload {
    [self setActualizeBtn:nil];
    [self setActualizeLabel:nil];
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


- (void)startUpdate:(id)sender {
    //[self syncBoxNet:YES];
}


- (void)updateUI {
    self.emptyForms = [RBForm allEmptyForms];
    if ([NSUserDefaults standardUserDefaults].webserviceUpdateDate) {
        //Update reload label-text
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd / HH:mm"];
        [self.actualizeLabel setText:[NSString stringWithFormat:@"Updated - %@",[dateFormat stringFromDate:[NSUserDefaults standardUserDefaults].webserviceUpdateDate]]];
    }
    
    if ([self isViewLoaded]) {
        [self.formsCarousel reloadData];
        [self.clientsCarousel reloadData];
        [self.detailCarousel reloadData];
        
        ((UIControl *)self.formsCarousel.currentView).selected = self.detailViewVisible;
    }
}

- (void)syncBoxNet:(BOOL)forced {
    // only update forms once a day
    if (forced || [RBBoxService shouldSyncFolder]) {
        [RBBoxService syncFolderWithID:[NSUserDefaults standardUserDefaults].folderID
                           startedFrom:self
                          successBlock:^(id boxObject) {
                              BoxFolder *formsFolder = (BoxFolder *)[boxObject objectAtFilePath:RBPathToEmptyForms()];
                              
                              // download empty forms and plists
                              if (formsFolder != nil) {
                                  [[NSUserDefaults standardUserDefaults] deleteStoredObjectNames];
                                  for (BoxFile *file in [formsFolder filesWithExtensions:XARRAY(kRBFormDataType,kRBPDFDataType)]) {
                                      DDLogInfo(@"Downloading %@", file.objectName);
                                      [[RBBoxService box] downloadFile:file
                                                         progressBlock:nil
                                                       completionBlock:^(BoxResponseType resultType, NSString *filePath) {
                                                           // save id of file under name of file in userDefaults
                                                           // this is to retreive the stored files later from the folder Documents/box.net
                                                           // because they are stored with objectID and objectName
                                                           [[NSUserDefaults standardUserDefaults] setObjectID:file.objectId
                                                                          forObjectWithNameIncludingExtension:file.objectName];
                                                           
                                                           if ([[file.objectName pathExtension] isEqualToString:@"plist"]) {
                                                               // update forms carousel
                                                               self.emptyForms = [RBForm allEmptyForms];
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                   [NSUserDefaults standardUserDefaults].formsUpdateDate = [NSDate date];
                                                                   [self updateUI];
                                                               });
                                                           }
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
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleClientLongPress:)];
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
    
    if (!(carousel == self.clientsCarousel && self.clientCarouselShowsAddItem && index == 0)){
        [self updateCarouselSelectionState:carousel selectedItem:(UIControl *)selectedItem];
    }
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
    
    // [self.formsCarousel reloadData];
    
    if (self.clientCarouselShowsAddItem && index == 0) {
        //RBClient *client = [self clientWithName:self.searchField.text];
        //client.clientCreatedForEditing = YES;
        self.clientsCarouselSelectedIndex=NSNotFound;
        [self.formsCarousel reloadData];
        [self editClient:nil];
    } else if (RBFormStatusForIndex(self.formsCarousel.currentItemIndex) != RBFormStatusNew) {
        [self.formsCarousel reloadData];
        [self updateDetailViewWithFormStatus:RBFormStatusForIndex(self.formsCarousel.currentItemIndex)];
    } else {
        [self.formsCarousel reloadData];
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
            
            [actionSheet addButtonWithTitle:@"View" block:^(void) {
                [self previewDocument:document];
            }];
            
            if (!IsEmpty(document.docuSignEnvelopeID)) {
                [actionSheet addButtonWithTitle:@"View on DocuSign" block:^(void) {
                    [self previewDocumentOnDocuSign:document];
                }];
            }
            
            if (IsEmpty(document.docuSignEnvelopeID)) {
                [actionSheet addButtonWithTitle:@"Edit" block:^(void) {
                    [self presentFormViewControllerForDocument:document];
                }];
            }
            
            if (!IsEmpty(document.docuSignEnvelopeID)
                && [document.lastDocuSignStatus intValue] != DSAPIService_EnvelopeStatusCode_Completed
                && [document.lastDocuSignStatus intValue] != DSAPIService_EnvelopeStatusCode_Voided
                && [document.lastDocuSignStatus intValue] != DSAPIService_EnvelopeStatusCode_Deleted
                && [document.lastDocuSignStatus intValue] != DSAPIService_EnvelopeStatusCode_Declined
                && [document.lastDocuSignStatus intValue] != DSAPIService_EnvelopeStatusCode_TimedOut) {
                //Add sort by order
                //First create temp array with slots
                NSMutableArray *recipients = [NSMutableArray array];
                for(int i = 0;i< 4;i++){
                    [recipients addObject: [NSNull null]];
                }
                
                //now insert recipients in the right slots
                NSLog(@"Number of recipients %d",document.recipients.count);
                for (RBRecipient *recipient in document.recipients) {
                    NSLog(@"order %@",recipient.order);
                    [recipients replaceObjectAtIndex:[recipient.order integerValue]-1 withObject:recipient];
                }
                [recipients removeObjectIdenticalTo:[NSNull null]];
                NSLog(@"%d",recipients.count);
                //finally add the buttons for the on device signers
                for (RBRecipient *recipient in recipients) {
                    if ([recipient.type intValue] == kRBRecipientTypeInPerson) {
                        NSDictionary *person = [recipient dictionaryRepresentation];
                        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Sign by %@", [person objectForKey:@"name"]] block:^(void) {
                            [self signDocument:document recipient:recipient];
                        }];
                    }
                }
                
                [actionSheet setDestructiveButtonWithTitle:@"Cancel signing" block:^(void) {
                    [self cancelDocument:document];
                }];
            }
            
            if (IsEmpty(document.docuSignEnvelopeID)) {
                // send to DocuSign
                [actionSheet addButtonWithTitle:@"Finalize" block:^(void) {
                    if (document.recipients.count > 0 && document.allRecipientsSet)  {
                        PSAlertView *alertView = [PSAlertView alertWithTitle:document.name message:[NSString stringWithFormat:@"Do you want to finalize this document for %@?",document.client.name]];
                        
                        [alertView addButtonWithTitle:@"Finalize" block:^(void) {
                            [self finalizeDocument:document];
                        }];
                        
                        [alertView setCancelButtonWithTitle:@"Cancel" block:nil];
                        
                        [alertView show];
                    } else {
                        [self showErrorMessage:@"Document has too less recipients, cannot send!"];
                    }
                }];
                
                // delete document
                [actionSheet setDestructiveButtonWithTitle:@"Delete" block:^(void) {
                    PSAlertView *alertView = [PSAlertView alertWithTitle:document.name message:[NSString stringWithFormat:@"Do you really want to delete this document for %@?",document.client.name]];
                    
                    [alertView addButtonWithTitle:@"Delete" block:^(void) {
                        RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
                        [persistenceManager deleteDocument:document];
                        [self.formsCarousel reloadData];
                        [self performSelector:@selector(showSuccessMessage:) withObject:@"Document deleted" afterDelay:0.5f];
                    }];
                    
                    [alertView setCancelButtonWithTitle:@"Cancel" block:nil];
                    
                    [alertView show];
                }];
            }
            
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
    [self updateDocumentsWithSearchTerm:textField.text];
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField{
    UIButton * cancelSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *btnimg = [UIImage imageNamed:@"11-x.png"];
    
    [cancelSearchBtn setFrame:searchField_.rightView.frame];
    [cancelSearchBtn setImage:btnimg forState:UIControlStateNormal];
    [cancelSearchBtn addTarget:self action:@selector(clearSearchPressed) forControlEvents:UIControlEventTouchUpInside];
    searchField_.rightView =cancelSearchBtn;//[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddButton"]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.clientCarouselShowsAddItem) {
        // show all clients again
        textField.text = @"";
        [self updateClientsWithSearchTerm:textField.text];
        [self updateDocumentsWithSearchTerm:textField.text];
    }
    self.searchField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchFieldRightView"]];
    
    [textField resignFirstResponder];
}

-(IBAction)clearSearchPressed{
    searchField_.text=@"";
    [self updateClientsWithSearchTerm:searchField_.text];
    [self updateDocumentsWithSearchTerm:searchField_.text];
}

- (IBAction)textFieldDidEndOnExit:(UITextField *)textField {
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

- (IBAction)handleMusketeerPress:(id)sender {
    RBMusketeerEditViewController *editViewController = [[RBMusketeerEditViewController alloc] initWithNibName:nil bundle:nil];
    
    editViewController.musketeer = [RBMusketeer loadEntity];
    editViewController.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
    editViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:editViewController animated:YES];
}

- (void)handleClientLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        id attachedObject = ((RBCarouselView *)gestureRecognizer.view).attachedObject;
        
        if ([attachedObject isKindOfClass:[RBClient class]]) {
            PSActionSheet *actionSheet = [PSActionSheet sheetWithTitle:[[NSString stringWithFormat:@"Client '%@'", ((RBClient *)attachedObject).name] uppercaseString]];
            
            [actionSheet addButtonWithTitle:@"Edit" block:^(void) {
                [self editClient:(RBClient *)attachedObject];
            }];
            
            [actionSheet addButtonWithTitle:@"View" block:^(void) {
                [self viewClient:(RBClient *)attachedObject];
            }];
            
            [self performBlock:^(void) {
                [actionSheet showFromRect:[self.view convertRect:(CGRect){CGPointMake(gestureRecognizer.view.frameLeft,gestureRecognizer.view.frameTop),gestureRecognizer.view.size} fromView:gestureRecognizer.view]
                                   inView:self.view
                                 animated:YES];
            } afterDelay:0];
        }
    }
}


- (IBAction)mibHomeButtonPressed:(id)sender {
    NSURL *urlForRequest = [NSURL URLWithString:[NSString stringWithFormat:@"%@://",kRBMIBURLPath]];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlForRequest]) {
        [[NSUserDefaults standardUserDefaults] setInteger:kRBMIBCallTypeJumpAction forKey:kRBMIBCallType];
        [[UIApplication sharedApplication] openURL:urlForRequest];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"M.I.B. App not found" message:@"The M.I.B. App is not installed. It must be installed to send the request." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
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
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([RBClient class])
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"visible = YES"]];
    
    NSSortDescriptor *idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([RBDocument class])
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
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
        [self.detailCarousel reloadData];
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
                         //self.formsView.alpha = 0.2;
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
            self.clientsCarousel.viewpointOffset = CGSizeMake(kViewpointOffsetX + (UIInterfaceOrientationIsPortrait(PSAppStatusBarOrientation) ? -120 : 0), 0);
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
    //    [controller autorelease];
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 150.f, 40.f)];
    
    label.text = [text uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    label.transform = CGAffineTransformMakeRotation(MTDegreesToRadian(90));
    label.backgroundColor = kRBColorDetail2;
    label.textColor = kRBColorMain;
    label.font = [UIFont fontWithName:kRBFontName size:22.f];
    label.frameLeft = 0;
    label.frameBottom = view.frameBottom;
    label.userInteractionEnabled = YES;
    
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
        NSPredicate *predicate=nil;
        RBClient *client=nil;
        
        if (self.clientsCarouselSelectedIndex != NSNotFound) {
            client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:self.clientsCarouselSelectedIndex inSection:0]];
        }
        
        if(![self.searchField.text isEqual:@""] && !(self.searchField.text == nil)){
            predicate = [NSPredicate predicateWithFormat:@"status = %d AND client.name contains[cd] %@ AND client.visible = YES",formStatus, self.searchField.text];
        }else{
            if (client != nil) {
                predicate = [NSPredicate predicateWithFormat:@"status = %d AND client = %@", formStatus, client];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"status = %d", formStatus];
            }
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
    
    [self.clientsCarousel.visibleViews makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];
    self.clientsCarouselSelectedIndex=NSNotFound;
    
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

-(void)updateDocumentsWithSearchTerm:(NSString *)searchTerm {
    [self updateDetailViewWithFormStatus:RBFormStatusForIndex(self.formsCarousel.currentItemIndex)];
    [self.formsCarousel reloadData];
    [self.detailCarousel reloadData];
}

- (RBClient *)clientWithName:(NSString *)name {
    RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
    
    return [persistenceManager clientWithName:name];
}

- (RBClient *)clientWithIdentifier:(NSString *)identifier {
    RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
    
    return [persistenceManager clientWithIdentifier:identifier];
}


- (void) viewClient: (RBClient *)client{
    RBClientEditViewController *clientVC= [[RBClientEditViewController alloc] init];
    clientVC.client=client;
    clientVC.editDisabled=YES;
    clientVC.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
    clientVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:clientVC animated:YES];
}

- (void)editClient:(RBClient *)client {
    NSURL *urlForRequest;
    //New client request if nil / else edit existing client
    if(client == nil){
        urlForRequest = [NSURL URLWithString:[NSString stringWithFormat:@"%@://sign_me/outlets/new",kRBMIBURLPath]];
        [[NSUserDefaults standardUserDefaults] setInteger:kRBMIBCallTypeAdd forKey:kRBMIBCallType];
        [[NSUserDefaults standardUserDefaults] setObject:@"nil" forKey:kRBMIBCallClientID];
        
    }else{
        NSString *classification;
        if (client.classification3 && client.classification3.length > 0) {
            classification = [NSString stringWithFormat:@"%@-%@-%@",client.classification1,client.classification2,client.classification3];
        } else if (client.classification2 && client.classification2.length > 0) {
            classification = [NSString stringWithFormat:@"%@-%@",client.classification1,client.classification2];
        } else {
            classification = client.classification1;
        }
        
        NSDictionary *dictToTransmit = @{@"id" : client.identifier,
                                         @"updated_at" : client.updated_at,
                                         @"name" : client.name,
                                         @"postal_code" : client.postalcode,
                                         @"city" : client.city,
                                         @"country" : client.country,
                                         @"country_iso" : client.country_iso,
                                         @"street" : client.street,
                                         @"classification" : classification
                                         };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictToTransmit
                                                           options:nil
                                                             error:nil];
        
        NSString *jsonString = [NSString stringWithFormat:@"%@",client.identifier];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        urlForRequest = [NSURL URLWithString:[NSString stringWithFormat:@"%@://sign_me/outlets/%@/edit",kRBMIBURLPath,jsonString]];
        NSLog(@"url: %@",urlForRequest);
        [[NSUserDefaults standardUserDefaults] setInteger:kRBMIBCallTypeEdit forKey:kRBMIBCallType];
        [[NSUserDefaults standardUserDefaults] setObject:client.identifier forKey:kRBMIBCallClientID];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlForRequest]) {
        [[UIApplication sharedApplication] openURL:urlForRequest];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"M.I.B. App not found" message:@"The M.I.B. App is not installed. It must be installed to send the request." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)presentFormIfPossible {
    
    if (RBFormStatusForIndex(self.formsCarousel.currentItemIndex) == RBFormStatusNew
        && self.detailCarouselSelectedIndex != NSNotFound
        && self.clientsCarouselSelectedIndex != NSNotFound) {
        if( [[NSUserDefaults standardUserDefaults] addressBookAccess] == YES){
            [self performBlock:^(void) {
                RBForm *form = [[self.emptyForms objectAtIndex:self.detailCarouselSelectedIndex] copy];
                //RBForm *form = [[RBForm alloc] initWithPath:[kRBFolderUserEmptyForms stringByAppendingPathComponent:@"aForm/PA_Form.plist"] name:@"aForm"];
                RBClient *client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:self.clientsCarouselSelectedIndex inSection:0]];
                //RBClient *client = [[RBClient alloc] init];
                [self presentFormViewControllerForForm:form client:client];
            } afterDelay:0.4];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"App has no permission to access the addressbook. Grant access in the ios settings to go on."
                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
    }
}

- (void)presentFormViewControllerForForm:(RBForm *)form client:(RBClient *)client {
    RBFormViewController *viewController = [[RBFormViewController alloc] initWithForm:form client:client];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:viewController animated:YES];
}

- (void)presentFormViewControllerForDocument:(RBDocument *)document {
    RBFormViewController *viewController = [[RBFormViewController alloc] initWithDocument:document];
    
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

//Deliver number of documents for section (considering searchterms and selected clients)
-(NSUInteger)actualNumberOfDocumentsWithFormStatus:(RBFormStatus)formStatus
{
    NSPredicate *predicate=nil;
    RBClient *client=nil;
    
    if(formStatus == RBFormStatusNew){
        return self.emptyForms.count;
    }
    
    if (self.clientsCarouselSelectedIndex != NSNotFound) {
        client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:self.clientsCarouselSelectedIndex inSection:0]];
    }
    
    if(![self.searchField.text isEqual:@""] && !(self.searchField.text == nil)){
        predicate = [NSPredicate predicateWithFormat:@"status = %d AND client.name contains[cd] %@ AND client.visible = YES",formStatus, self.searchField.text];
    }else{
        if (client != nil) {
            predicate = [NSPredicate predicateWithFormat:@"status = %d AND client = %@", formStatus, client];
        } else {
            if (formStatus) {
                predicate = [NSPredicate predicateWithFormat:@"status = %d", formStatus];
            } else {
                predicate = nil;
            }
            
        }
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([RBDocument class])
                                              inManagedObjectContext:[NSManagedObjectContext defaultContext]];
    [request setEntity:entity];
    
    request.predicate = predicate;
    if (predicate) {
        return [[NSManagedObjectContext defaultContext] countForFetchRequest:request error:nil];
    } else {
        return 0;
    }
    
}

- (NSUInteger)numberOfDocumentsWithFormStatus:(RBFormStatus)formStatus {
    
    switch (formStatus) {
        case RBFormStatusNew:
            return self.emptyForms.count;
            
        case RBFormStatusPreSignature:
        case RBFormStatusSigned:
            return [self actualNumberOfDocumentsWithFormStatus:formStatus];
            
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
#pragma mark Incoming Custom URL Call Handling
////////////////////////////////////////////////////////////////////////
-(void)updateClientWithCustomURLCallString:(NSString *)urlstring
{
    NSString *keypart;
    NSString *valuepart;
    RBClient *client=nil;
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSUInteger calltype = [[NSUserDefaults standardUserDefaults] integerForKey:kRBMIBCallType];
    NSString * clientid = [[NSUserDefaults standardUserDefaults] valueForKey:kRBMIBCallClientID];
    if(calltype == kRBMIBCallTypeDelete){
        RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
        client = [self clientWithIdentifier:clientid];
        [persistenceManager deleteClient:(RBClient *)client];
        [self performSelector:@selector(showSuccessMessage:) withObject:@"Client deleted" afterDelay:0.5f];
    }
    
    if(calltype == kRBMIBCallTypeAdd || calltype == kRBMIBCallTypeEdit){
        NSArray * informationparts = [urlstring componentsSeparatedByString:@"&"];
        for(NSString *informationsnippet in informationparts){
            valuepart =[informationsnippet substringAfterSubstring:@"="];
            keypart = nil;
            if([informationsnippet hasSubstring:@"="])
                keypart = [informationsnippet substringToIndex:[informationsnippet rangeOfString:@"="].location];
            if([keypart isEqualToString:@"id"]){
                client = [self clientWithIdentifier:valuepart];
            }else{
                if (valuepart != nil && valuepart.length > 0 && ![valuepart isEqualToStringIgnoringCase:@"undefined"]) {
                    [client setValue:valuepart forKey:keypart];
                }
            }
        }
        if(client != nil){
            [self performSelector:@selector(showSuccessMessage:) withObject:@"Clients successfully updated" afterDelay:0.5f];
        }else{
        //    [self performSelector:@selector(showErrorMessage:) withObject:@"Update Error - Client data is missing!" afterDelay:0.5f];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRBMIBCallType];
    }
    
    [[NSManagedObjectContext defaultContext] save];
    [self.clientsCarousel reloadData];
    [self.formsCarousel reloadData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Update Data from Webservice
////////////////////////////////////////////////////////////////////////

-(void)updateDataViaWebservice {
    NSURL *outleturl = [NSURL URLWithString:kReachabilityOutletsXML];
    NSURL *formurl = [NSURL URLWithString:kReachabilityFormsXML];
    self.ressourceLoadingHttpRequests = [[NSOperationQueue alloc] init];
    
    ASIHTTPRequest *outletreq = [ASIHTTPRequest requestWithURL:outleturl];
    outletreq.username = [RBMusketeer loadEntity].email;
    outletreq.password = [RBMusketeer loadEntity].token;
    [outletreq setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    outletreq.delegate = self;
    [outletreq setDidFinishSelector:@selector(outletRequestFinished:)];
    
    ASIHTTPRequest *formreq = [outletreq copy];
    formreq.url = formurl;
    [formreq setDidFinishSelector:@selector(formRequestFinished:)];
    
    firstRequestFinished=NO;
    oneRequestFailed=NO;
    [formreq startAsynchronous];
    [outletreq startAsynchronous];
    
    [self showLoadingMessage:(NSString *)@"Updating Clients and Forms!"];
}

-(void)formRequestFinished:(ASIHTTPRequest *)request{
    NSData *respData = [request responseData];
    NSString * elemcontent,*formname;
    NSString *downloadpath;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    [[NSUserDefaults standardUserDefaults] deleteStoredObjectNames];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:respData
                                                           options:0 error:nil];
    if (doc != nil){
        
        for(GDataXMLElement *form in [doc.rootElement elementsForName:@"form" ])
        {
            NSArray *elements = [form elementsForName:@"name"];
            if (elements.count > 0) {
                GDataXMLElement *content = (GDataXMLElement *)[elements firstObject];
                formname = content.stringValue;
            }
            
            downloadpath = [kRBFolderUserEmptyForms stringByAppendingPathComponent:formname];
            if (![manager fileExistsAtPath:downloadpath]) {
                [manager createDirectoryAtPath:downloadpath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            for(NSString *elementname in XARRAY(@"form_url",@"pdf_url",@"pdf_css")){
                elements = [form elementsForName:elementname];
                if (elements.count > 0) {
                    GDataXMLElement *content = (GDataXMLElement *)[elements firstObject];
                    elemcontent = content.stringValue;
                    if([elementname isEqualToString:@"form_url"]){
                        [[NSUserDefaults standardUserDefaults] setFormName:downloadpath forObjectWithNameIncludingExtension:[NSString stringWithFormat:@"%@___%@",formname,[elemcontent lastPathComponent]]];
                        NSLog(@"downloadpath %@ formanme %@",downloadpath,[NSString stringWithFormat:@"%@___%@",formname,[elemcontent lastPathComponent]]);
                    }
                    ASIHTTPRequest *ressourcereq = [ASIHTTPRequest requestWithURL:[RBFullFormRessourceURL(elemcontent) copy]];
                    [ressourcereq setDownloadDestinationPath:[downloadpath stringByAppendingPathComponent:[elemcontent lastPathComponent]]];
                    [ressourcereq setDelegate:self];
                    [self.ressourceLoadingHttpRequests addOperation:ressourcereq];
                }
            }
            
            elements = [form elementsForName:@"resources"];
            if(elements.count > 0){
                GDataXMLElement *resources = [elements firstObject];
                elements = [resources elementsForName:@"url"];
                for(GDataXMLElement *urlress in elements){
                    elemcontent =urlress.stringValue;
                    ASIHTTPRequest *ressourcereq = [ASIHTTPRequest requestWithURL:RBFullFormRessourceURL(elemcontent)];
                    [ressourcereq setDownloadDestinationPath:[downloadpath stringByAppendingPathComponent:[elemcontent lastPathComponent]]];
                    [ressourcereq setDelegate:self];
                    [self.ressourceLoadingHttpRequests addOperation:ressourcereq];
                }
            }
        }
    }
    
    [NSUserDefaults standardUserDefaults].formsUpdateDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] synchronize];
    emptyForms_ = [RBForm allEmptyForms];
    
    //if request for Outlets already finished
    if(firstRequestFinished){
        [NSUserDefaults standardUserDefaults].webserviceUpdateDate = [NSDate date];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self performSelector:@selector(showSuccessMessage:) withObject:@"Finished Update!" afterDelay:1.0f];
            [self performSelector:@selector(updateUI) afterDelay:1.0];
            [self.clientsCarousel scrollToItemAtIndex:0 animated:YES];
        });
    }else{
        firstRequestFinished=YES;
    }
}

-(void)outletRequestFinished:(ASIHTTPRequest *)request {
    RBClient *client=nil;
    NSData *respData = [request responseData];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:respData
                                                           options:0 error:nil];
    NSDate *lastSyncDate = nil;
    if (doc != nil) {
        lastSyncDate = [NSDate date];
        
        NSArray *elementstoload = [NSArray arrayWithObjects:@"updated_at",@"name",@"street",@"city",@"postalcode",@"region",@"country",
                                   @"country_iso",@"classification1",@"classification2",@"classification3",nil];
        
        for(GDataXMLElement *outlet in [doc.rootElement elementsForName:@"outlet"]) {
            //Special routine for id because of keyword conflict
            NSString * ident;
            NSArray *elements = [outlet elementsForName:@"id"];
            if (elements.count > 0) {
                GDataXMLElement *content = (GDataXMLElement *) [elements objectAtIndex:0];
                ident = content.stringValue;
            }
            
            client= [RBClient findFirstByAttribute:@"identifier" withValue:ident];
            
            if (client == nil) {
                client = [RBClient createEntity];
                client.identifier = ident;
            }
            
            client.visible=$B(YES);
            //Special routine for Logo - add logo request
            elements = [outlet elementsForName:@"logo_url"];
            if (elements.count > 0) {
                GDataXMLElement *content = (GDataXMLElement *) [elements objectAtIndex:0];
                client.logo_url = content.stringValue;
                if(client.logo_url.length > 0){
                    ASIHTTPRequest *logoreq = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:client.logo_url ]];
                    [logoreq setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@.jpg",kRBLogoSavedDirectorypath,client.identifier]];
                    [logoreq setDelegate:self];
                    logoreq.tag = kLogoReq;
                    [self.ressourceLoadingHttpRequests addOperation:logoreq];
                }
            }
            
            //Load the remaining objects
            for(NSString *elem in elementstoload){
                elements = [outlet elementsForName:elem];
                if (elements.count > 0) {
                    GDataXMLElement *content = (GDataXMLElement *) [elements objectAtIndex:0];
                    [client setValue:content.stringValue forKey:elem];
                }
            }
            client.zip = client.postalcode;
            client.lastSyncDate = lastSyncDate;
        }
    } else {
        NSLog(@"Parser Error");
    }
    
    if (lastSyncDate) {
        NSArray *serverSideDeletedClients = [RBClient findAllWithPredicate:[NSPredicate predicateWithFormat:@"lastSyncDate <> %@",lastSyncDate]];
        for (RBClient *clientToDelete in serverSideDeletedClients) {
            [clientToDelete deleteEntity];
        }
    }
    
    [[NSManagedObjectContext defaultContext] save];
    
    //if request for Forms already finished
    if(firstRequestFinished){
        [NSUserDefaults standardUserDefaults].webserviceUpdateDate = [NSDate date];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self performSelector:@selector(showSuccessMessage:) withObject:@"Finished Update!" afterDelay:1.0f];
            [self performSelector:@selector(updateUI) afterDelay:1.0];
            [self.clientsCarousel scrollToItemAtIndex:0 animated:YES];
        });
    } else {
        firstRequestFinished=YES;
    }
    NSLog(@"outlet finished");
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"req failed - code %d %@",[request responseStatusCode],[[request url] absoluteString]);
    //Display Error msg only once (Display no error message if a request for a logo fails - because they are optional)
    if(!oneRequestFailed && request.tag != kLogoReq) {
        [self performSelector:@selector(showErrorMessage:) withObject:@"Update Error" afterDelay:0.5f];
        oneRequestFailed=YES;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Update Data to Webservice
////////////////////////////////////////////////////////////////////////

- (void)putOfflineClientDataToWebservice:(NSData *)clientData relativePathString:(NSString *)relativePath {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kReachabilityData,relativePath]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:clientData];
    [request setRequestMethod:@"PUT"];
    request.username = [RBMusketeer loadEntity].email;
    request.password = [RBMusketeer loadEntity].token;
    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    request.delegate = self;
    [request setDidFinishSelector:@selector(putClientDataRequestFinished:)];
    [request setDidFailSelector:@selector(putClientDataRequestFailed:)];
    [request startAsynchronous];
}

- (void)putClientDataRequestFinished:(ASIHTTPRequest *)request {
    NSString *deletedOutletID = [request.url lastPathComponent];
    deletedOutletID = [deletedOutletID substringToIndex:deletedOutletID.length - 5];
    NSLog(@"Push successful delete keychain entry %@",deletedOutletID);
    
    [KeychainWrapper clearOutletJSONFromKeychain:deletedOutletID];
}

- (void)putClientDataRequestFailed:(ASIHTTPRequest *)request {
    NSLog(@"req failed - code %d %@",[request responseStatusCode],[[request url] absoluteString]);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Email Messaging
////////////////////////////////////////////////////////////////////////
- (void)sendEMailMessageInBackgroundWithPDFAttachment:(NSData *)pdfData contractName:(NSString *)contractName client:(NSString *)clientName{
    
    self.emailMsg = [[SKPSMTPMessage alloc] init];
    RBMusketeer *musketeer = [RBMusketeer loadEntity];
    
    emailMsg_.fromEmail = [[NSUserDefaults standardUserDefaults] stringForKey:@"kRBMailConfigFromEmail"];
    emailMsg_.toEmail = musketeer.adminemail;
    emailMsg_.relayHost =[[NSUserDefaults standardUserDefaults] stringForKey:@"kRBMailConfigHost"];
    emailMsg_.requiresAuth = YES;
    emailMsg_.login = [[NSUserDefaults standardUserDefaults] stringForKey:@"kRBMailConfigLoginUser"];
    emailMsg_.pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"kRBMailConfigLoginPwd"];
    emailMsg_.wantsSecure = YES;
    emailMsg_.subject = [NSString stringWithFormat:@"SignMe: The contract for %@ has been completed",clientName];
    emailMsg_.delegate = self;
    
    NSLog(@"From:%@ To:%@ host:%@ login:%@ pass:%@",emailMsg_.fromEmail,emailMsg_.toEmail,emailMsg_.relayHost,emailMsg_.login,emailMsg_.pass);
    
    //email contents
    NSString * bodyMessage = [NSString stringWithFormat:@"The following user has completed a contract:\n### Contract Info ###\n-Type: %@ \n\n### Musketeer Info ####\n-Firstname: %@ \n-Lastname: %@\n-E-Mail: %@ \n\n If you experience any problems or do have questions with the current eMail or any other SignMe functionality, please contact your local IT team or send a Sales Tools Support request via your Lotus Notes Home page.",
                              contractName,musketeer.firstname,musketeer.lastname,musketeer.email];
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               bodyMessage ,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    NSDictionary *attachmentPart = [NSDictionary dictionaryWithObjectsAndKeys:@"application/pdf;\r\n\tx-unix-mode=0644;\r\n\tname=\"contract.pdf\"",kSKPSMTPPartContentTypeKey,
                                    @"inline;\r\n\tfilename=\"contract.pdf\"",kSKPSMTPPartContentDispositionKey,[pdfData encodeWrappedBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    emailMsg_.parts = [NSArray arrayWithObjects:plainPart,attachmentPart,nil];
    
    if(emailMsg_.fromEmail && emailMsg_.toEmail && emailMsg_.relayHost && emailMsg_.login && emailMsg_.pass){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [emailMsg_ send];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self performSelector:@selector(showErrorMessage:) withObject:@"E-Mail function in SignMe Settings not fully conigurated." afterDelay:3.0f];
        });
        self.emailMsg=nil;
    }
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self performSelector:@selector(showSuccessMessage:) withObject:@"E-Mail with signed agreement has been successfully sent!" afterDelay:3.0f];
    });
    self.emailMsg = nil;
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self performSelector:@selector(showErrorMessage:) withObject:@"E-Mail with signed agreement hasn't been successfully sent!" afterDelay:3.0f];
    });
    self.emailMsg = nil;
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
    }
}

- (void)previewDocumentOnDocuSign:(RBDocument *)document {
    [RBDocuSignService previewDocument:document];
}

- (void)finalizeDocument:(RBDocument *)document {
    //Delete recipients which are not needed
    NSMutableArray *neededRecipients = [[NSMutableArray alloc] init];
    
    for(RBRecipient *recip in document.recipients){
        if([[recip valueForKey:kRBisNeededSigner] isEqualToNumber:kRBisNeededSignerTRUE]){
            [neededRecipients addObject:recip];
        }
    }
    [document setRecipients:[NSSet setWithArray:neededRecipients]];
    [RBDocuSignService sendDocument:document];
}

- (void)cancelDocument:(RBDocument *)document {
    [RBDocuSignService cancelDocument:document];
}

- (void)signDocument:(RBDocument *)document recipient:(RBRecipient *)recipient {
    [RBDocuSignService signDocument:document recipient:[recipient dictionaryRepresentation]];
}

@end
