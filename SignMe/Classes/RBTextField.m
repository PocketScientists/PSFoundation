//
//  RBTextField.m
//  SignMe
//
//  Created by Tretter Matthias on 05.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBTextField.h"
#import "PSIncludes.h"


@interface RBTextField()
- (void)showDatePicker:(id)sender;
- (void)showItemPicker:(id)sender;
- (void)done:(id)sender;
- (void)dateChanged:(id)sender;
- (NSDateFormatter *)formatterForSubtype;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
@end


@implementation RBTextField

@synthesize nextField = nextField_;
@synthesize prevField = prevField_;
@synthesize popoverController = popoverController_;
@synthesize subtype = subtype_;
@synthesize items = items_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBTextField
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"TextFieldBackground.png"];
        self.background = [image stretchableImageWithLeftCapWidth:8 topCapHeight:15];

//        UIToolbar *navToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 1024, 44)] autorelease];
//        navToolbar.barStyle = UIBarStyleBlack;
//        UIBarButtonItem *prevItem = [[[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoPrevField:)] autorelease];
//        UIBarButtonItem *nextItem = [[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoNextField:)] autorelease];
//        navToolbar.items = [NSArray arrayWithObjects:prevItem, nextItem, nil];
//        [self setInputAccessoryView:navToolbar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    MCRelease(popoverController_);
    MCRelease(subtype_);
    
    [super dealloc];
}


- (void)setSubtype:(NSString *)newSubtype {
    NSString *oldSubtype = subtype_;
    subtype_ = [newSubtype retain];
    if ([subtype_ isEqualToString:@"date"] || [subtype_ isEqualToString:@"time"] || [subtype_ isEqualToString:@"datetime"]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
//        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, PSAppWidth(), 300)];
//        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
//        if ([self.subtype isEqualToString:@"date"]) {
//            datePicker.datePickerMode = UIDatePickerModeDate;
//        }
//        else if ([self.subtype isEqualToString:@"datetime"]) {
//            datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//        }
//        else if ([self.subtype isEqualToString:@"time"]) {
//            datePicker.datePickerMode = UIDatePickerModeTime;
//        }
    }
    else if ([subtype_ isEqualToString:@"list"]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showItemPicker:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
//        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, PSAppWidth(), 300)];
//        pickerView.dataSource = self;
//        pickerView.delegate = self;
//        pickerView.showsSelectionIndicator = YES;
//        self.inputView = pickerView;
//        [pickerView release];
    }
    else if ([subtype_ isEqualToString:@"number"]) {
        self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([subtype_ isEqualToString:@"email"]) {
        self.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if ([subtype_ isEqualToString:@"phone"]) {
        self.keyboardType = UIKeyboardTypePhonePad;
    }
    else if ([subtype_ isEqualToString:@"url"]) {
        self.keyboardType = UIKeyboardTypeURL;
    }
    [oldSubtype release];
}


- (void)setNextField:(UITextField *)nextField {
    nextField_ = nextField;
    
    if (nextField_ != nil) {
        self.returnKeyType = UIReturnKeyNext;
    }
}

//- (void)setText:(NSString *)text {
//    [super setText:text];
//    
//    if ([subtype_ isEqualToString:@"date"] || [subtype_ isEqualToString:@"time"] || [subtype_ isEqualToString:@"datetime"]) {
//        UIDatePicker *datePicker = (UIDatePicker *)self.inputView;
//        NSDate *date = [[self formatterForSubtype] dateFromString:self.text];
//        if (date) datePicker.date = date;
//    }
//    else if ([subtype_ isEqualToString:@"list"]) {
//        UIPickerView *pickerView = (UIPickerView *)self.inputView;
//        NSInteger i = [self.items indexOfObject:self.text];
//        if (i != NSNotFound) {
//            [pickerView selectRow:i inComponent:0 animated:NO];
//        }
//    }
//}

- (BOOL)becomeFirstResponder {
    if (![self.subtype isEqualToString:@"list"] &&
        ![self.subtype isEqualToString:@"date"] &&
        ![self.subtype isEqualToString:@"datetime"] &&
        ![self.subtype isEqualToString:@"time"] ) {
        return [super becomeFirstResponder];
    }
    else {
        if ([subtype_ isEqualToString:@"date"] || [subtype_ isEqualToString:@"time"] || [subtype_ isEqualToString:@"datetime"]) {
            [self showDatePicker:self];
        }
        else if ([subtype_ isEqualToString:@"list"]) {
            [self showItemPicker:self];
        }
    }
    [self.prevField resignFirstResponder];
    return NO;
}


- (void)showDatePicker:(id)sender {
    //build our custom popover view
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 344)];
    popoverView.backgroundColor = [UIColor blackColor];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = kRBColorDetail;
    UIBarButtonItem *item;
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [items addObject:item];
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    [items addObject:item];
    
    toolbar.items = items;
    [items release];
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 320, 300)];
    datePicker.tag = 1;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    NSDate *date = [[self formatterForSubtype] dateFromString:self.text];
    if (date) datePicker.date = date;
    if ([self.subtype isEqualToString:@"date"]) {
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ([self.subtype isEqualToString:@"datetime"]) {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    else if ([self.subtype isEqualToString:@"time"]) {
        datePicker.datePickerMode = UIDatePickerModeTime;
    }

    [popoverView addSubview:toolbar];
    [popoverView addSubview:datePicker];        
    popoverContent.view = popoverView;
    
    //resize the popover view shown
    //in the current view to the view's size
    popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 244);
    
    //create a popover controller
    if (!self.popoverController) {
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:popoverContent] autorelease];
        self.popoverController.delegate = self;
    }
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    [self.popoverController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    //release the popover content
    [popoverView release];
    [popoverContent release];
    [datePicker release];
    [toolbar release];
}


- (void)showItemPicker:(id)sender {
    //build our custom popover view
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 344)];
    popoverView.backgroundColor = [UIColor blackColor];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = kRBColorDetail;
    UIBarButtonItem *item;
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [items addObject:item];
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    [items addObject:item];
    
    toolbar.items = items;
    [items release];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 300)];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.tag = 1;
    int index = [self.items indexOfObject:self.text];
    if (index != NSNotFound) {
        [pickerView selectRow:index inComponent:0 animated:NO];
    }
    [popoverView addSubview:toolbar];
    [popoverView addSubview:pickerView];        
    popoverContent.view = popoverView;
    
    //resize the popover view shown
    //in the current view to the view's size
    popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 244);
    
    //create a popover controller
    if (!self.popoverController) {
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:popoverContent] autorelease];
        self.popoverController.delegate = self;
    }
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    [self.popoverController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //release the popover content
    [popoverView release];
    [popoverContent release];
    [pickerView release];
    [toolbar release];
}



- (void)done:(id)sender {
    UIView *view = [self.popoverController.contentViewController.view viewWithTag:1];
    if (view && [view isKindOfClass:[UIDatePicker class]]) {
        self.text = [[self formatterForSubtype] stringFromDate:((UIDatePicker *)view).date];
    }
    else if (view && [view isKindOfClass:[UIPickerView class]]) {
        self.text = [self.items objectAtIndex:[((UIPickerView *)view) selectedRowInComponent:0]];
    }
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}


- (void)dateChanged:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    
    self.text = [[self formatterForSubtype] stringFromDate:datePicker.date];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIKeyboard Handling
////////////////////////////////////////////////////////////////////////

- (void)keyboardWillShow:(NSNotification *)notification {
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.popoverController) {
        if ([subtype_ isEqualToString:@"date"] || [subtype_ isEqualToString:@"time"] || [subtype_ isEqualToString:@"datetime"]) {
            [self performSelector:@selector(showDatePicker:) withObject:self afterDelay:0.5];
        }
        else if ([subtype_ isEqualToString:@"list"]) {
            [self performSelector:@selector(showItemPicker:) withObject:self afterDelay:0.5];
        }
    }
}


#pragma mark - picker datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.items count];
}


#pragma mark - picker delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.items objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.text = [self.items objectAtIndex:row];
}


#pragma mark - popover delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popoverController = nil;
}


- (NSDateFormatter *)formatterForSubtype {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    if ([self.subtype isEqualToString:@"date"]) {
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    }
    else if ([self.subtype isEqualToString:@"datetime"]) {
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    else if ([self.subtype isEqualToString:@"time"]) {
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    return formatter;
}

@end
