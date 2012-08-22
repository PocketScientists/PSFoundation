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
#import "ASIHttpRequest.h"
#import "GDataXMLNode.h"


@interface RBHomeViewController : PSBaseViewController <iCarouselDataSource, iCarouselDelegate, NSFetchedResultsControllerDelegate, UIDocumentInteractionControllerDelegate, ASIHTTPRequestDelegate>
{
    BOOL isMovedUp;
}

@property (nonatomic, strong) IBOutlet UIView *formsView;
@property (nonatomic, strong) IBOutlet iCarousel *formsCarousel;
@property (nonatomic, strong) IBOutlet UIView *clientsView;
@property (nonatomic, strong) IBOutlet UIButton *addNewClientButton;
@property (nonatomic, strong) IBOutlet iCarousel *clientsCarousel;

@property (nonatomic, strong) IBOutlet UITextField *searchField;


- (IBAction)textFieldDidEndEditing:(UITextField *)textField;
- (IBAction)textFieldDidChangeValue:(UITextField *)textField;
- (IBAction)textFieldDidEndOnExit:(UITextField *)textField;

- (IBAction)handleAddNewClientPress:(id)sender;
- (IBAction)handleBackgroundPress:(id)sender;
- (IBAction)handleMusketeerPress:(id)sender;

- (void)updateUI;
- (void)syncBoxNet:(BOOL)forced;

-(void)updateDataViaWebservice;

@end
