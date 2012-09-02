//
//  RBRecipientPickerViewController.h
//  SignMe
//
//  Created by Michael Schwarz on 30.08.12.
//
//

#import <UIKit/UIKit.h>
#import "RBRecipient.h"

@protocol RBRecipientPickerDelegate<NSObject>
- (void)didSelectRecipient:(RBRecipient *)recip;
@end

@interface RBRecipientPickerViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *recipientnames;
@property (nonatomic, unsafe_unretained) id<RBRecipientPickerDelegate> delegate;

@end
