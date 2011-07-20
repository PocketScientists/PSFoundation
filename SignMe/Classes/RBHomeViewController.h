//
//  RBHomeViewController.h
//  SignMe
//
//  Created by Tretter Matthias on 19.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "PSBaseViewController.h"
#import "iCarousel.h"


@interface RBHomeViewController : PSBaseViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, retain) UILabel *formsLabel;
@property (nonatomic, retain) iCarousel *formsCarousel;

@property (nonatomic, retain) UILabel *clientsLabel;
@property (nonatomic, retain) iCarousel *clientsCarousel;

@property (nonatomic, retain) iCarousel *detailCarousel;

@end
