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

#define kAnimationDuration      0.25
#define kFormsYOffset            80.f
#define kClientsYOffset         120.f
#define kDetailYOffset           95.f

#define kFormsCarouselFrame     CGRectMake(0,200,self.view.bounds.size.width,170)
#define kDetailViewFrame        CGRectMake(0,200,self.view.bounds.size.width,240)
#define kClientsCarouselFrame   CGRectMake(0,450,self.view.bounds.size.width,170)


@interface RBHomeViewController ()

// header label for a carousel
- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text;
- (void)setupCarousel:(iCarousel *)carousel;

// move a view vertically
- (void)moveViewsWithFactor:(CGFloat)factor;

- (BOOL)formsCarouselIsSelected;

- (void)formsCarouseldidSelectItemAtIndex:(NSInteger)index;
- (void)clientsCarouseldidSelectItemAtIndex:(NSInteger)index;

- (void)showDetailViewWithDelay:(NSTimeInterval)delay;
- (void)hideDetailView;

@end

@implementation RBHomeViewController

@synthesize formsLabel = formsLabel_;
@synthesize formsCarousel = formsCarousel_;
@synthesize clientsCarousel = clientsCarousel_;
@synthesize clientsLabel = clientsLabel_;
@synthesize detailView = detailView_;
@synthesize detailCarousel = detailCarousel_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    MCRelease(formsLabel_);
    MCRelease(formsCarousel_);
    MCRelease(clientsCarousel_);
    MCRelease(clientsLabel_);
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
    self.clientsCarousel = [[[iCarousel alloc] initWithFrame:kClientsCarouselFrame] autorelease];
    
    self.detailView = [[[RBFormDetailView alloc] initWithFrame:kDetailViewFrame] autorelease];
    // self.detailCarousel = [[[iCarousel alloc] initWithFrame:kFormsCarouselFrame] autorelease];
    
    [self setupCarousel:self.formsCarousel];
    [self setupCarousel:self.clientsCarousel];
    [self setupCarousel:self.detailCarousel];
    
    self.detailView.alpha = 0.f;
    
    [self.formsCarousel scrollToItemAtIndex:RBFormTypePreSignature animated:NO];
    self.formsCarousel.scrollEnabled = NO;
    
    self.formsLabel = [self headerLabelForView:self.formsCarousel text:@"FORMS"];
    self.clientsLabel = [self headerLabelForView:self.clientsCarousel text:@"CLIENTS"];
    
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.formsLabel];
    [self.view addSubview:self.formsCarousel];
    [self.view addSubview:self.clientsLabel];
    [self.view addSubview:self.clientsCarousel];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    self.formsLabel = nil;
    self.formsCarousel = nil;
    self.detailCarousel = nil;
    self.clientsLabel = nil;
    self.clientsCarousel = nil;
    self.detailView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.formsCarousel reloadData];
    [self.clientsCarousel reloadData];
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
        self.formsCarousel.centerItemWhenSelected = YES;
    } 
    
    // Is not selected currently -> item gets selected
    else {
        [self showDetailViewWithDelay:self.formsCarousel.currentItemIndex == index ? 0 : 0.4];
        self.formsCarousel.centerItemWhenSelected = NO;
    }
}

- (void)clientsCarouseldidSelectItemAtIndex:(NSInteger)index {
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Moving Animations
////////////////////////////////////////////////////////////////////////

- (void)showDetailViewWithDelay:(NSTimeInterval)delay {
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
    self.clientsLabel.frameTop += kClientsYOffset * factor;
    self.clientsCarousel.frameTop += kClientsYOffset * factor;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)] autorelease];
    
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
