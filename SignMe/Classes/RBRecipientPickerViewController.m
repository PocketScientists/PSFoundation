//
//  RBRecipientPickerViewController.m
//  SignMe
//
//  Created by Michael Schwarz on 30.08.12.
//
//

#import "RBRecipientPickerViewController.h"

#define POPOVERWIDTH 300
#define POPOVERHEIGHT 240

@interface RBRecipientPickerViewController ()

@end

@implementation RBRecipientPickerViewController

@synthesize delegate=delegate_;
@synthesize recipientnames=recipientnames_;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(POPOVERWIDTH, POPOVERHEIGHT);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recipientnames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    RBAvailableRecipients *recip = [self.recipientnames objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@ %@",recip.firstname,recip.lastname];
    
    cell.textLabel.text=name;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(didSelectRecipient:)])
    {
        [self.delegate didSelectRecipient:[self.recipientnames objectAtIndex:indexPath.row]];
    }
}

@end
