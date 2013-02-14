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
#import "SKPSMTPMessage.h"


@interface RBHomeViewController : PSBaseViewController <iCarouselDataSource, iCarouselDelegate, NSFetchedResultsControllerDelegate, UIDocumentInteractionControllerDelegate, ASIHTTPRequestDelegate,SKPSMTPMessageDelegate>
{
    BOOL isMovedUp;
    BOOL firstRequestFinished;
    BOOL oneRequestFailed;
}

@property (nonatomic, strong) IBOutlet UIView *formsView;
@property (nonatomic, strong) IBOutlet iCarousel *formsCarousel;
@property (nonatomic, strong) IBOutlet UIView *clientsView;
@property (nonatomic, strong) IBOutlet UIButton *addNewClientButton;
@property (nonatomic, strong) IBOutlet iCarousel *clientsCarousel;

@property (nonatomic, strong) IBOutlet UITextField *searchField;
@property (nonatomic, strong) IBOutlet UIButton *actualizeBtn;


- (IBAction)textFieldDidEndEditing:(UITextField *)textField;
- (IBAction)textFieldDidChangeValue:(UITextField *)textField;
- (IBAction)textFieldDidEndOnExit:(UITextField *)textField;
- (IBAction)textFieldDidBeginEditing:(UITextField *)textField;

- (IBAction)handleAddNewClientPress:(id)sender;
- (IBAction)handleBackgroundPress:(id)sender;
- (IBAction)handleMusketeerPress:(id)sender;
- (IBAction)clearSearchPressed;

- (void)updateUI;
- (void)syncBoxNet:(BOOL)forced;

-(void)updateClientWithCustomURLCallString:(NSString *)urlstring;
- (void)putOfflineClientDataToWebservice:(NSData *)clientData relativePathString:(NSString *)relativePath;

- (IBAction)updateDataViaWebservice;

- (void)sendEMailMessageInBackgroundWithPDFAttachment:(NSData *)pdfData contractName:(NSString *)contractName client:(NSString *)clientName;

@end
