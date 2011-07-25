//
//  RBHomeViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 19.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBHomeViewController.h"
#import "RBFormViewController.h"
#import "RBForm.h"
#import "RBCarouselView.h"
#import "RBClient.h"

#define kMinNumberOfItemsToWrap   6

#define kClientCacheName        @"RBClientCache"

#define kAnimationDuration      0.25
#define kFormsYOffset            80.f
#define kClientsYOffset         110.f
#define kDetailViewHeight       230.f
#define kDetailYOffset           95.f


@interface RBHomeViewController ()

// header label for a carousel
- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text;

// move a view vertically
- (void)moveViewsWithFactor:(CGFloat)factor;

- (BOOL)formsCarouselIsSelected;
- (BOOL)clientCarouselShowsAddItem;

- (void)formsCarouseldidSelectItemAtIndex:(NSInteger)index;
- (void)clientsCarouseldidSelectItemAtIndex:(NSInteger)index;

- (void)showDetailView; // delay = 0
- (void)showDetailViewWithDelay:(NSTimeInterval)delay;
- (void)hideDetailView;

- (void)showSearchScreenWithDuration:(NSTimeInterval)duration;
- (void)hideSearchScreenWithDuration:(NSTimeInterval)duration;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)updateClientsWithSearchTerm:(NSString *)searchTerm;

- (void)addNewClientWithName:(NSString *)name;

- (void)presentViewControllerForForm:(RBForm *)form;

@end

@implementation RBHomeViewController

@synthesize clientsFetchController = clientsFetchController_;
@synthesize formsViewDefaultY = formsViewDefaultY_;
@synthesize clientsViewDefaultY = clientsViewDefaultY_;
@synthesize timeView = timeView_;
@synthesize formsLabel = formsLabel_;
@synthesize clientsLabel = clientsLabel_;
@synthesize formsView = formsView_;
@synthesize formsCarousel = formsCarousel_;
@synthesize clientsView = clientsView_;
@synthesize clientsCarousel = clientsCarousel_;
@synthesize addNewClientButton = addNewClientButton_;
@synthesize detailView = detailView_;
@synthesize detailCarousel = detailCarousel_;
@synthesize searchField = searchField_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(timeView_);
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
    MCRelease(clientsFetchController_);
    
    [super dealloc];
}

- (void)insertTempData {
    [RBClient truncateAll];
    
    RBClient *c = nil;
    
    c = [RBClient createEntity];
    c.name = @"Client 1";
    
    c = [RBClient createEntity];
    c.name = @"Client 2";
    
    c = [RBClient createEntity];
    c.name = @"Client 3";
    
    c = [RBClient createEntity];
    c.name = @"Client 4";
    
    c = [RBClient createEntity];
    c.name = @"Client 5";
    
    c = [RBClient createEntity];
    c.name = @"Alfred";
    
    c = [RBClient createEntity];
    c.name = @"Judokus";
    
    c = [RBClient createEntity];
    c.name = @"Quark";
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: remove
    [self insertTempData];
    
    self.formsViewDefaultY = self.formsView.frameTop;
    self.clientsViewDefaultY = self.clientsView.frameTop;
    
    // Perform CoreData fetch
    NSError *error;
	if (self.clientsFetchController != nil && ![self.clientsFetchController performFetch:&error]) {
		DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
	} 
    
    self.formsLabel = [self headerLabelForView:self.formsCarousel text:@"Forms"];
    self.clientsLabel = [self headerLabelForView:self.addNewClientButton text:@"Clients"];
    
    [self.formsView addSubview:self.formsLabel];
    [self.clientsView addSubview:self.clientsLabel];
    
    // we control centering for this carousel on our own
    self.formsCarousel.centerItemWhenSelected = NO;
    // we inset the viewpoint s.t. items in both carousel have same x-pos (clientsCarousel has other frame than formsCarousel)
    // we also add another item width, s.t. the first item (that is ususally centered) appears on first position
    self.clientsCarousel.viewpointOffset = CGSizeMake(self.addNewClientButton.frameWidth/2 + kCarouselItemWidth, 0);
    
    // self.detailCarousel = [[[iCarousel alloc] initWithFrame:kFormsCarouselFrame] autorelease];
    // [self setupCarousel:self.detailCarousel];
    
    self.detailView = [[[RBFormDetailView alloc] initWithFrame:self.formsView.frame] autorelease];
    self.detailView.frameHeight = kDetailViewHeight;
    self.detailView.alpha = 0.f;
    
    [self.view insertSubview:self.detailView belowSubview:self.formsView];
    
    self.timeView = [[[RBTimeView alloc] initWithFrame:CGRectMake(920, 30, 70, 80)] autorelease];
    [self.view addSubview:self.timeView];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.clientsFetchController.delegate = self;
    
    [self.formsCarousel reloadData];
    [self.clientsCarousel reloadData];
    
    [self.formsCarousel scrollToItemAtIndex:RBFormStatusPreSignature animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.clientsFetchController.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
        NSInteger numberOfRows = 0;
        
        if (self.clientsFetchController.sections.count > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.clientsFetchController.sections objectAtIndex:0];
            numberOfRows = [sectionInfo numberOfObjects];
        }
        
        return numberOfRows;
    }
    
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index {
    RBCarouselView *view = [RBCarouselView carouselView];
    
    if (carousel == self.formsCarousel) {
        [view setFromFormStatus:RBFormStatusForIndex(index)];
    } 
    
    else if (carousel == self.clientsCarousel) {
        // Should not be needed, but even though count = 0 viewForItem gets called
        if ([self numberOfItemsInCarousel:carousel] > 0) {
            RBClient *client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [view setFromClient:client];
        } else {
            view.isAddClientView = YES;
            [view setText:[NSString stringWithFormat:@"Add client\n'%@'",self.searchField.text]];
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

- (float)carouselItemWidth:(iCarousel *)carousel {
    return kCarouselItemWidth;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    // update detail view if user scrolled to new form while detailView is visible
    if (carousel == self.formsCarousel && self.detailView.alpha == 1.f) {
        [self.detailView reloadData];
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (carousel == self.formsCarousel) {
        [self formsCarouseldidSelectItemAtIndex:index];
    }
    
    else if (carousel == self.clientsCarousel) {
        [self clientsCarouseldidSelectItemAtIndex:index];
    }
}

- (void)formsCarouseldidSelectItemAtIndex:(NSInteger)index {
    if ([self formsCarouselIsSelected]) {
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
            [self showDetailViewWithDelay:0.4];
        } else {
            [self showDetailViewWithDelay:0];
        }
    }
}

- (void)clientsCarouseldidSelectItemAtIndex:(NSInteger)index {
    if ([self clientCarouselShowsAddItem] && index == 0) {
        [self addNewClientWithName:self.searchField.text];
    } else {
        RBForm *form = [RBForm emptyFormWithName:@"W-9"];
        [self presentViewControllerForForm:form];
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
    if ([self clientCarouselShowsAddItem]) {
        // show all clients again
        textField.text = @"";
        [self updateClientsWithSearchTerm:textField.text];
    }
    
    [textField resignFirstResponder];
}

- (IBAction)textFieldDidEndOnExit:(UITextField *)textField {
    if ([self clientCarouselShowsAddItem]) {
        // add new client
        [self addNewClientWithName:textField.text];
    }
    
    [textField resignFirstResponder];
}

- (IBAction)handleAddNewClientPress:(id)sender {
    [self addNewClientWithName:@"New Client"];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
////////////////////////////////////////////////////////////////////////

// TODO: Y U NO GETTING FIRED??
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller { 
    [self.clientsCarousel reloadData];
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
                                                                             cacheName:kClientCacheName];
    clientsFetchController_.delegate = self;
    
    return clientsFetchController_;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Moving Animations
////////////////////////////////////////////////////////////////////////

- (void)showDetailView {
    [self showDetailViewWithDelay:0.];
}

- (void)showDetailViewWithDelay:(NSTimeInterval)delay {
    [self.view bringSubviewToFront:self.formsView];
    [self.detailView reloadData];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         [self moveViewsWithFactor:1.f];
                     } completion:^(BOOL finished) {
                         [self.view bringSubviewToFront:self.detailView];
                     }];
}

- (void)hideDetailView {
    [self.view bringSubviewToFront:self.formsView];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         [self moveViewsWithFactor:-1.f];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)moveViewsWithFactor:(CGFloat)factor {
    self.detailView.frameTop += kDetailYOffset * factor;
    self.detailView.alpha = MIN(1.f, factor+1.f); // factor = 1 -> alpha = 1, factor = -1 -> alpha = 0
    
    self.formsView.frameTop -= kFormsYOffset * factor;
    self.clientsView.frameTop += kClientsYOffset * factor;
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
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.height, view.frameLeft)] autorelease];
    
    label.text = text;
    label.textAlignment = UITextAlignmentCenter;
    label.transform = CGAffineTransformMakeRotation(MTDegreesToRadian(90));
    label.backgroundColor = [UIColor colorWithRed:0.7804f green:0.0000f blue:0.2941f alpha:1.0000f];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20.];
    label.frameLeft = 0;
    label.frameBottom = view.frameBottom;
    
    return label;
}

- (BOOL)formsCarouselIsSelected {
    return self.detailView.alpha > 0;
}

- (BOOL)clientCarouselShowsAddItem {
    if (self.clientsCarousel.visibleViews.count == 1) {
        RBCarouselView *selectedView = self.clientsCarousel.visibleViews.anyObject;
        
        return selectedView.isAddClientView;
    }
    
    return NO;
}

- (void)showSearchScreenWithDuration:(NSTimeInterval)duration {
    self.formsView.userInteractionEnabled = NO;
    self.detailView.frameTop = self.formsViewDefaultY;
    self.detailView.alpha = 0.f;
    
    [UIView animateWithDuration:duration
                          delay:0.f 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         // 44.f = height of search-area -> clients-carousel is on same spot as forms-carousel before
                         CGFloat newClientsY = self.formsViewDefaultY - 44.f;
                         CGFloat diffY = self.clientsViewDefaultY - newClientsY;
                         
                         // Move views up
                         self.formsView.alpha = 0.2;
                         self.formsView.frameTop = self.formsViewDefaultY - diffY;
                         self.clientsView.frameTop = newClientsY;
                         // Make clients-carousel expand width to cover add button
                         self.clientsCarousel.frame = CGRectMake(self.addNewClientButton.frameLeft, self.clientsCarousel.frameTop,
                                                                 self.clientsView.frameWidth - self.clientsLabel.frameWidth, self.clientsCarousel.frameHeight);
                     } 
                     completion:nil];
}

- (void)hideSearchScreenWithDuration:(NSTimeInterval)duration {
    self.formsView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:duration animations:^(void) {
        self.formsView.alpha = 1.f;
        self.formsView.frameTop = self.formsViewDefaultY;
        self.clientsView.frameTop = self.clientsViewDefaultY;
        // show add-button again
        // Make clients-carousel expand width to cover add button
        self.clientsCarousel.frame = CGRectMake(self.addNewClientButton.frameRight, self.clientsCarousel.frameTop,
                                                self.clientsView.frameWidth - self.clientsLabel.frameWidth - self.addNewClientButton.frameWidth, self.clientsCarousel.frameHeight);
    }];
}

- (void)updateClientsWithSearchTerm:(NSString *)searchTerm {
    NSPredicate *predicate = nil;
    
    if (!IsEmpty(searchTerm)) {
        predicate = [NSPredicate predicateWithFormat:@"visible = YES AND name contains[cd] %@", searchTerm];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"visible = YES"];
    }
    
    [NSFetchedResultsController deleteCacheWithName:kClientCacheName];
    self.clientsFetchController.fetchRequest.predicate = predicate;
	
    NSError *error = nil;
    if (![self.clientsFetchController performFetch:&error]) {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }  
    
    [self.clientsCarousel reloadData];
} 

- (void)addNewClientWithName:(NSString *)name {
    RBClient *newClient = [RBClient createEntity];
    
    newClient.name = name;
}

- (void)presentViewControllerForForm:(RBForm *)form {
    RBFormViewController *viewController = [[[RBFormViewController alloc] initWithForm:form] autorelease];
    
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentModalViewController:viewController animated:YES];
}

@end
