//
//  RBHomeViewController.m
//  SignMe
//
//  Created by Tretter Matthias on 19.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBHomeViewController.h"
#import "RBForm.h"
#import "RBCarouselView.h"
#import "RBClient.h"

#define kMinNumberOfItemsToEnableScrolling   5

#define kAnimationDuration      0.25
#define kFormsYOffset            80.f
#define kClientsYOffset         120.f
#define kDetailYOffset           95.f

#define kFormsCarouselFrame     CGRectMake(0.f,200.f,self.view.bounds.size.width,170.f)
#define kDetailViewFrame        CGRectMake(0.f,200.f,self.view.bounds.size.width,235.f)
#define kClientsViewFrame       CGRectMake(0.f,420.f,self.view.bounds.size.width,200.f)
#define kClientsCarouselFrame   CGRectMake(0.f,30.f,self.view.bounds.size.width,170.f)


@interface RBHomeViewController ()

// header label for a carousel
- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text;
- (void)setupCarousel:(iCarousel *)carousel;

// move a view vertically
- (void)moveViewsWithFactor:(CGFloat)factor;

- (BOOL)formsCarouselIsSelected;

- (void)formsCarouseldidSelectItemAtIndex:(NSInteger)index;
- (void)clientsCarouseldidSelectItemAtIndex:(NSInteger)index;

- (void)showDetailView; // delay = 0
- (void)showDetailViewWithDelay:(NSTimeInterval)delay;
- (void)hideDetailView;

- (void)toggleSearchScreen;

- (void)keyboardWillHide:(NSNotification *)notification;
- (void)handleSearchClientPress:(id)sender;

@end

@implementation RBHomeViewController

@synthesize formsLabel = formsLabel_;
@synthesize formsCarousel = formsCarousel_;
@synthesize clientsView = clientsView_;
@synthesize clientsCarousel = clientsCarousel_;
@synthesize clientsLabel = clientsLabel_;
@synthesize searchClientButton = searchClientButton_;
@synthesize addClientButton = addClientButton_;
@synthesize detailView = detailView_;
@synthesize detailCarousel = detailCarousel_;
@synthesize searchField = searchField_;
@synthesize clientsFetchController = clientsFetchController_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(formsLabel_);
    MCRelease(formsCarousel_);
    MCRelease(clientsView_);
    MCRelease(clientsCarousel_);
    MCRelease(clientsLabel_);
    MCRelease(searchField_);
    MCRelease(searchClientButton_);
    MCRelease(addClientButton_);
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
    
    [self insertTempData];
    
    // Perform CoreData fetch
    NSError *error;
	if (self.clientsFetchController != nil && ![self.clientsFetchController performFetch:&error]) {
		DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
	} 
    
    
    self.formsCarousel = [[[iCarousel alloc] initWithFrame:kFormsCarouselFrame] autorelease];
    [self setupCarousel:self.formsCarousel];
    self.formsCarousel.centerItemWhenSelected = NO;
    [self.formsCarousel scrollToItemAtIndex:RBFormStatusPreSignature animated:NO];
    self.formsLabel = [self headerLabelForView:self.formsCarousel text:@"FORMS"];
    
    self.clientsView = [[[UIView alloc] initWithFrame:kClientsViewFrame] autorelease];
    self.clientsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.clientsCarousel = [[[iCarousel alloc] initWithFrame:kClientsCarouselFrame] autorelease];
    [self setupCarousel:self.clientsCarousel];
    self.clientsLabel = [self headerLabelForView:self.clientsCarousel text:@"CLIENTS"];
    self.searchClientButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addClientButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //[self.searchClientButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchClientButton setTitle:@"Filter" forState:UIControlStateNormal];
    [self.addClientButton setTitle:@"New" forState:UIControlStateNormal];
    
    self.searchClientButton.frame = CGRectMake(0, 0, 60, 30);
    self.addClientButton.frame = CGRectMake(0, 0, 60, 30);
    self.searchClientButton.frameLeft = self.view.bounds.size.width - 140;
    self.addClientButton.frameLeft = self.view.bounds.size.width - 70;
    self.searchClientButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.addClientButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.searchClientButton addTarget:self action:@selector(handleSearchClientPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchField = [[[UITextField alloc] initWithFrame:CGRectMake(100, 152, 300, 27)] autorelease];
    self.searchField.backgroundColor = [UIColor clearColor];
    self.searchField.borderStyle = UITextBorderStyleNone;
    
    // self.detailCarousel = [[[iCarousel alloc] initWithFrame:kFormsCarouselFrame] autorelease];
    // [self setupCarousel:self.detailCarousel];
    
    self.detailView = [[[RBFormDetailView alloc] initWithFrame:kDetailViewFrame] autorelease];
    self.detailView.alpha = 0.f;
    
    
    
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.formsLabel];
    [self.view addSubview:self.formsCarousel];
    
    [self.clientsView addSubview:self.clientsLabel];
    [self.clientsView addSubview:self.clientsCarousel];
    [self.clientsView addSubview:self.searchClientButton];
    [self.clientsView addSubview:self.addClientButton];
    [self.view addSubview:self.clientsView];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    self.formsLabel = nil;
    self.formsCarousel = nil;
    self.detailCarousel = nil;
    self.clientsView = nil;
    self.searchClientButton = nil;
    self.addClientButton = nil;
    self.clientsLabel = nil;
    self.clientsCarousel = nil;
    self.detailView = nil;
    MCReleaseNil(clientsFetchController_);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.clientsFetchController.delegate = self;
    
    [self.formsCarousel reloadData];
    [self.clientsCarousel reloadData];
    
    //self.formsCarousel.scrollEnabled = self.formsCarousel.numberOfItems >= kMinNumberOfItemsToEnableScrolling;
    //self.clientsCarousel.scrollEnabled = self.clientsCarousel.numberOfItems >= kMinNumberOfItemsToEnableScrolling;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.clientsFetchController.delegate = nil;
    
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
        RBClient *client = [self.clientsFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [view setFromClient:client];
    }
    
    return view;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark iCarouselDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)carouselShouldWrap:(iCarousel *)carousel {
    return carousel == self.clientsCarousel;
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
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
////////////////////////////////////////////////////////////////////////

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
                                                                             cacheName:@"RBClientCache"];
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
    [self.view bringSubviewToFront:self.formsCarousel];
    
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
    
    self.formsCarousel.frameTop -= kFormsYOffset * factor;
    self.clientsView.frameTop += kClientsYOffset * factor;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handleSearchClientPress:(id)sender {
    [self toggleSearchScreen];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self toggleSearchScreen];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 25)] autorelease];
    
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:18.];
    label.frameLeft = view.frameLeft + 10.f;
    label.frameTop = view.frameTop - label.frameHeight - 5.f;
    
    return label;
}

- (void)setupCarousel:(iCarousel *)carousel {
    carousel.backgroundColor = kRBCarouselColor;
    carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    carousel.delegate = self;
    carousel.dataSource = self;
}

- (BOOL)formsCarouselIsSelected {
    return !CGRectEqualToRect(self.formsCarousel.frame, kFormsCarouselFrame);
}

- (void)toggleSearchScreen {
    if (self.searchField.superview == nil) {
        [UIView animateWithDuration:0.4 animations:^(void) {
            // Hide forms & detail
            self.formsLabel.alpha = 0.f;
            self.formsCarousel.alpha = 0.f;
            self.detailView.hidden = YES;
            
            // Move Clients-View up
            self.clientsView.frameTop = 150.f;
        } completion:^(BOOL finished) {
            self.clientsLabel.text = @"CLIENTS:";
            [self.view addSubview:self.searchField];
            [self.searchField becomeFirstResponder];
        }];
    }
    
    else {
        BOOL detailViewHidden = YES;
        
        [self.searchField resignFirstResponder];
        [self.searchField removeFromSuperview];
        self.clientsLabel.text = @"CLIENTS";
        
        if (self.detailView.alpha == 1.f) {
            self.detailView.alpha = 0.f;
            detailViewHidden = NO;
        }
        
        self.detailView.hidden = NO;
        
        [UIView animateWithDuration:0.4 animations:^(void) {
            // Show forms & detail
            self.formsLabel.alpha = 1.f;
            self.formsCarousel.alpha = 1.f;
            // Move Clients-View down to original position
            self.clientsView.frameTop = CGRectGetMinY(kClientsViewFrame) + ([self formsCarouselIsSelected] ? kClientsYOffset : 0);
            
            if (!detailViewHidden) {
                self.detailView.alpha = 1.0;
            }
        }];
    }
}

@end
