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
#define kFormsYOffset           55.f
#define kClientsYOffset         110.f

#define kFormsCarouselFrame     CGRectMake(0,200,self.view.bounds.size.width,170)
#define kClientsCarouselFrame   CGRectMake(0,450,self.view.bounds.size.width,170)


@interface RBHomeViewController ()

// header label for a carousel
- (UILabel *)headerLabelForView:(UIView *)view text:(NSString *)text;
- (void)setupCarousel:(iCarousel *)carousel;

// move a view vertically
- (void)moveView:(UIView *)view upBy:(CGFloat)yOffset;
- (void)moveView:(UIView *)view downBy:(CGFloat)yOffset;

- (BOOL)formsCarouselIsSelected;

@end

@implementation RBHomeViewController

@synthesize formsLabel = formsLabel_;
@synthesize formsCarousel = formsCarousel_;
@synthesize clientsCarousel = clientsCarousel_;
@synthesize clientsLabel = clientsLabel_;
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
    self.detailCarousel = [[[iCarousel alloc] initWithFrame:kFormsCarouselFrame] autorelease];
    self.clientsCarousel = [[[iCarousel alloc] initWithFrame:kClientsCarouselFrame] autorelease];
    
    [self setupCarousel:self.formsCarousel];
    [self setupCarousel:self.clientsCarousel];
    [self setupCarousel:self.detailCarousel];
    
    [self.formsCarousel scrollToItemAtIndex:RBFormTypePreSignature animated:NO];
    self.formsCarousel.scrollEnabled = NO;
    
    self.formsLabel = [self headerLabelForView:self.formsCarousel text:@"FORMS"];
    self.clientsLabel = [self headerLabelForView:self.clientsCarousel text:@"CLIENTS"];
    
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
        if ([self formsCarouselIsSelected]) {
            [self.formsCarousel setFrame:kFormsCarouselFrame duration:kAnimationDuration];
            [self.clientsCarousel setFrame:kClientsCarouselFrame duration:kAnimationDuration];
            [self moveView:self.clientsLabel upBy:kClientsYOffset];
        } else {
            [self moveView:self.formsCarousel upBy:kFormsYOffset];
            [self moveView:self.clientsLabel downBy:kClientsYOffset];
            [self moveView:self.clientsCarousel downBy:kClientsYOffset];
        }
    }
    
    else if (carousel == self.clientsCarousel) {
        
    }
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
    label.font = [UIFont boldSystemFontOfSize:18];
    label.frameLeft = view.frameLeft + 10;
    label.frameTop = view.frameTop - label.frameHeight - 10;
    
    return label;
}

- (void)setupCarousel:(iCarousel *)carousel {
    carousel.backgroundColor = [UIColor lightGrayColor];
    carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    carousel.delegate = self;
    carousel.dataSource = self;
}

- (BOOL)formsCarouselIsSelected {
    return !CGRectEqualToRect(self.formsCarousel.frame, kFormsCarouselFrame);
}

- (void)moveView:(UIView *)view upBy:(CGFloat)yOffset {
    [view setFrame:CGRectMake(view.frameLeft,view.frameTop-yOffset,view.frameWidth,view.frameHeight) duration:kAnimationDuration];
}

- (void)moveView:(UIView *)view downBy:(CGFloat)yOffset {
    [self moveView:view upBy:-yOffset];
}

@end
