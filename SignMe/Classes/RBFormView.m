//
//  RBFormView.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBFormView.h"
#import "PSIncludes.h"

@interface RBFormView ()

- (void)handlePrevButtonPress:(id)sender;
- (void)handleNextButtonPress:(id)sender;
- (void)handlePageChange:(id)sender;

- (void)updateUI;

@end

@implementation RBFormView

@synthesize innerScrollView = innerScrollView_;
@synthesize pageControl = pageControl_;
@synthesize prevButton = prevButton_;
@synthesize nextButton = nextButton_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.pagingEnabled = YES;
        self.directionalLockEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.clipsToBounds = YES;
        
        innerScrollView_ = [[UIScrollView alloc] initWithFrame:CGRectZero];
        innerScrollView_.scrollEnabled = NO;
        
        UIImage *prevImage = [UIImage imageNamed:@"PrevButton"];
        prevButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [prevButton_ setImage:prevImage forState:UIControlStateNormal];
        prevButton_.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        prevButton_.frame = CGRectMake(30, 702, prevImage.size.width, prevImage.size.height);
        [prevButton_ addTarget:self action:@selector(handlePrevButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        prevButton_.alpha = 0.f;
        
        UIImage *nextImage = [UIImage imageNamed:@"NextButton"];
        nextButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [nextButton_ setImage:nextImage forState:UIControlStateNormal];
        nextButton_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        nextButton_.frame = CGRectMake(651, 702, nextImage.size.width, nextImage.size.height);
        [nextButton_ addTarget:self action:@selector(handleNextButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        pageControl_ = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 100, 705, 200, 30)];
        pageControl_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        pageControl_.hidesForSinglePage = YES;
        [pageControl_ addTarget:self action:@selector(handlePageChange:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:innerScrollView_];
}
    
    return self;
}

- (void)dealloc {
    MCRelease(innerScrollView_);
    MCRelease(pageControl_);
    MCRelease(prevButton_);
    MCRelease(nextButton_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBFormView
////////////////////////////////////////////////////////////////////////

- (void)setInnerScrollViewSize:(CGSize)size {
    self.innerScrollView.contentSize = size;
    self.innerScrollView.frame = (CGRect){CGPointZero,size};
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handlePrevButtonPress:(id)sender {
    NSInteger newPage = MAX(0,self.pageControl.currentPage - 1);

    self.pageControl.currentPage = newPage;
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:YES];
    [self.innerScrollView setContentOffset:CGPointMake(newPage*self.bounds.size.width,0) animated:YES];
    [self updateUI];
}

- (void)handleNextButtonPress:(id)sender {
    NSInteger newPage = MIN(self.pageControl.numberOfPages - 1,self.pageControl.currentPage + 1);

    self.pageControl.currentPage = newPage;
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:YES];
    [self.innerScrollView setContentOffset:CGPointMake(newPage*self.bounds.size.width,0) animated:YES];
    [self updateUI];
}

- (void)handlePageChange:(id)sender {
    int newPage = self.pageControl.currentPage;
	
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:YES];
	[self.innerScrollView setContentOffset:CGPointMake(newPage*self.bounds.size.width,0) animated:YES];
    [self updateUI];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
    if (self.pageControl.currentPage == 0) {
        [self.prevButton setAlpha:0.f duration:0.3f];
    } else {
        [self.prevButton setAlpha:1.f duration:0.3f];
    }
    
    if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
        [self.nextButton setAlpha:0.f duration:0.3f];
    } else {
        [self.nextButton setAlpha:1.f duration:0.3f];
    }
}

@end
