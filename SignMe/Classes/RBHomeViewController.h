//
//  RBHomeViewController.h
//  SignMe
//
//  Created by Tretter Matthias on 19.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "PSBaseViewController.h"
#import "iCarousel.h"
#import "RBFormDetailView.h"


@interface RBHomeViewController : PSBaseViewController <iCarouselDataSource, iCarouselDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) UILabel *formsLabel;
@property (nonatomic, retain) iCarousel *formsCarousel;

@property (nonatomic, retain) UIView *clientsView;
@property (nonatomic, retain) UILabel *clientsLabel;
@property (nonatomic, retain) iCarousel *clientsCarousel;
@property (nonatomic, retain) UITextField *searchField;
@property (nonatomic, retain) UIButton *searchClientButton;
@property (nonatomic, retain) UIButton *addClientButton;

@property (nonatomic, retain) RBFormDetailView *detailView;
@property (nonatomic, retain) iCarousel *detailCarousel;

@property (nonatomic, readonly) NSFetchedResultsController *clientsFetchController;

@end
