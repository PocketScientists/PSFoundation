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
#import "RBTimeView.h"


@interface RBHomeViewController : PSBaseViewController <iCarouselDataSource, iCarouselDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) NSFetchedResultsController *clientsFetchController;

@property (nonatomic, assign) CGFloat formsViewDefaultY;
@property (nonatomic, assign) CGFloat clientsViewDefaultY;

@property (nonatomic, retain) RBTimeView *timeView;
@property (nonatomic, retain) UILabel *formsLabel;
@property (nonatomic, retain) UILabel *clientsLabel;

@property (nonatomic, retain) RBFormDetailView *detailView;
@property (nonatomic, retain) iCarousel *detailCarousel;

@property (nonatomic, retain) IBOutlet UIView *formsView;
@property (nonatomic, retain) IBOutlet iCarousel *formsCarousel;
@property (nonatomic, retain) IBOutlet UIView *clientsView;
@property (nonatomic, retain) IBOutlet iCarousel *clientsCarousel;

@property (nonatomic, retain) IBOutlet UITextField *searchField;
@property (nonatomic, retain) UIButton *addClientButton;


- (IBAction)textFieldDidEndEditing:(UITextField *)textField;
- (IBAction)textFieldDidChangeValue:(UITextField *)textField;

@end
