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

@end

@implementation RBHomeViewController

@synthesize formsLabel = formsLabel_;
@synthesize formsCarousel = formsCarousel_;
@synthesize clientsView = clientsView_;
@synthesize clientsCarousel = clientsCarousel_;
@synthesize clientsLabel = clientsLabel_;
@synthesize searchClientButton = clientsFilter_;
@synthesize addClientButton = addClientButton_;
@synthesize detailView = detailView_;
@synthesize detailCarousel = detailCarousel_;

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
    MCRelease(clientsFilter_);
    MCRelease(addClientButton_);
    MCRelease(detailView_);
    MCRelease(detailCarousel_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formsCarousel = [[[iCarousel alloc] initWithFrame:kFormsCarouselFrame] autorelease];
    [self setupCarousel:self.formsCarousel];
    self.formsCarousel.centerItemWhenSelected = NO;
    [self.formsCarousel scrollToItemAtIndex:RBFormTypePreSignature animated:NO];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.formsCarousel reloadData];
    [self.clientsCarousel reloadData];
    
    self.formsCarousel.scrollEnabled = self.formsCarousel.numberOfItems >= kMinNumberOfItemsToEnableScrolling;
    self.clientsCarousel.scrollEnabled = self.clientsCarousel.numberOfItems >= kMinNumberOfItemsToEnableScrolling;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark iCarouselDataSource
////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (carousel == self.formsCarousel) {
        return RBFormTypeCount;
    }
    
    else if (carousel == self.clientsCarousel) {
        
    }
    
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index {
    RBCarouselView *view = [RBCarouselView carouselView];
    
    if (carousel == self.formsCarousel) {
        [view setFromFormType:RBFormTypeForIndex(index)];
    } 
    
    else if (carousel == self.clientsCarousel) {
        
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
            [self.formsCarousel scrollToItemAtIndex:index animated:YES];
            
            if (self.formsCarousel.currentItemIndex != index) {
                [self showDetailViewWithDelay:0.4];
            }
        } afterDelay:kAnimationDuration];
    } 
    
    // Is not selected currently -> item gets selected
    else {
        [self.formsCarousel scrollToItemAtIndex:index animated:YES];
        [self showDetailViewWithDelay:self.formsCarousel.currentItemIndex == index ? 0 : 0.4];
    }
}

- (void)clientsCarouseldidSelectItemAtIndex:(NSInteger)index {
    
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

@end
