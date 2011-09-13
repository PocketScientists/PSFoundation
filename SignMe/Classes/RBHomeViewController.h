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


@interface RBHomeViewController : PSBaseViewController <iCarouselDataSource, iCarouselDelegate, NSFetchedResultsControllerDelegate, UIDocumentInteractionControllerDelegate>
{
    BOOL isMovedUp;
}

@property (nonatomic, retain) IBOutlet UIView *formsView;
@property (nonatomic, retain) IBOutlet iCarousel *formsCarousel;
@property (nonatomic, retain) IBOutlet UIView *clientsView;
@property (nonatomic, retain) IBOutlet UIButton *addNewClientButton;
@property (nonatomic, retain) IBOutlet iCarousel *clientsCarousel;

@property (nonatomic, retain) IBOutlet UITextField *searchField;


- (IBAction)textFieldDidEndEditing:(UITextField *)textField;
- (IBAction)textFieldDidChangeValue:(UITextField *)textField;
- (IBAction)textFieldDidEndOnExit:(UITextField *)textField;

- (IBAction)handleAddNewClientPress:(id)sender;
- (IBAction)handleBackgroundPress:(id)sender;

- (void)updateUI;
- (void)syncBoxNet;

@end
