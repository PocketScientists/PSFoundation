//
//  RBTextField.m
//  SignMe
//
//  Created by Tretter Matthias on 05.08.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBTextField.h"
#import "PSIncludes.h"
#import "RBKeyboardAvoidingScrollView.h"
#import "UIView+RBForm.h"
#import "UIControl+RBForm.h"
#import "DDMathParser.h"
#import "RegexKitLite.h"


@interface RBTextField()
- (void)showDatePicker:(id)sender;
- (void)showItemPicker:(id)sender;
- (void)done:(id)sender;
- (void)dateChanged:(id)sender;
- (NSDateFormatter *)formatterForSubtype;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)gotoPrevField:(id)sender;
- (void)gotoNextField:(id)sender;
- (void)closeField:(id)sender;
@end


@implementation RBTextField

@synthesize nextField = nextField_;
@synthesize prevField = prevField_;
@synthesize popoverController = popoverController_;
@synthesize subtype = subtype_;
@synthesize items = items_;
@synthesize usePopover = usePopover_;
@synthesize calcVarFields = calcVarFields_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBTextField
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"TextFieldBackground.png"];
        self.background = [image stretchableImageWithLeftCapWidth:8 topCapHeight:15];

        UIToolbar *navToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 1024, 44)];
        navToolbar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *prevItem = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoPrevField:)];
        prevItem.enabled = NO;
        UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoNextField:)];
        nextItem.enabled = NO;
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeField:)];
        navToolbar.items = [NSArray arrayWithObjects:prevItem, nextItem, spaceItem, closeItem, nil];
        [self setInputAccessoryView:navToolbar];
    }
    
    return self;
}


- (void)dealloc {
    if (usePopover_) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
}


- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        UIImage *image = [UIImage imageNamed:@"TextFieldBackground.png"];
        self.background = [image stretchableImageWithLeftCapWidth:8 topCapHeight:15];
    }
    else {
        UIImage *image = [UIImage imageNamed:@"TextFieldBackgroundDisabled.png"];
        self.background = [image stretchableImageWithLeftCapWidth:8 topCapHeight:15];
    }
}


- (void)setUsePopover:(BOOL)usePopover {
    if (usePopover_ == usePopover) return;
    
    usePopover_ = usePopover;
    if (usePopover_) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}


- (void)setSubtype:(NSString *)newSubtype {
    subtype_ = newSubtype;
    if ([subtype_ isEqualToString:@"date"] || [subtype_ isEqualToString:@"time"] || [subtype_ isEqualToString:@"datetime"]) {
        if (usePopover_) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker:)];
            [self addGestureRecognizer:tap];
        }
        else {
            UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, PSAppWidth(), 300)];
            [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            if ([self.subtype isEqualToString:@"date"]) {
                datePicker.datePickerMode = UIDatePickerModeDate;
            }
            else if ([self.subtype isEqualToString:@"datetime"]) {
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            }
            else if ([self.subtype isEqualToString:@"time"]) {
                datePicker.datePickerMode = UIDatePickerModeTime;
            }
            self.inputView = datePicker;
        }
    }
    else if ([subtype_ isEqualToString:@"list"]) {
        if (usePopover_) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showItemPicker:)];
            [self addGestureRecognizer:tap];
        }
        else {
            UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, PSAppWidth(), 300)];
            pickerView.dataSource = self;
            pickerView.delegate = self;
            pickerView.showsSelectionIndicator = YES;
            self.inputView = pickerView;
        }
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
}


- (void)setPrevField:(UITextField *)prevField {
    prevField_ = prevField;
    
    if (prevField_ != nil) {
        ((UIBarButtonItem *)[((UIToolbar *)self.inputAccessoryView).items objectAtIndex:0]).enabled = YES;
    }
    else {
        ((UIBarButtonItem *)[((UIToolbar *)self.inputAccessoryView).items objectAtIndex:0]).enabled = NO;
    }
}


- (void)setNextField:(UITextField *)nextField {
    nextField_ = nextField;
    
    if (nextField_ != nil) {
        ((UIBarButtonItem *)[((UIToolbar *)self.inputAccessoryView).items objectAtIndex:1]).enabled = YES;
        self.returnKeyType = UIReturnKeyNext;
    }
    else {
        ((UIBarButtonItem *)[((UIToolbar *)self.inputAccessoryView).items objectAtIndex:1]).enabled = NO;
        self.returnKeyType = UIReturnKeyDone;
    }
}

- (void)gotoPrevField:(id)sender {
    UIView *firstResponder = self.prevField;
    if (firstResponder) {
        [firstResponder becomeFirstResponder];
        
        UIView *sv = self;
        while (sv && ![sv isKindOfClass:[RBKeyboardAvoidingScrollView class]]) {
            sv = sv.superview;
        }
        if ([sv isKindOfClass:[RBKeyboardAvoidingScrollView class]]) {
            [(RBKeyboardAvoidingScrollView *)sv moveResponderIntoPlace:firstResponder];
        }
        return;
    }
    
    [self resignFirstResponder];
}

- (void)gotoNextField:(id)sender {
    UIView *firstResponder = self.nextField;
    if (firstResponder) {
        [firstResponder becomeFirstResponder];
        
        UIView *sv = self;
        while (sv && ![sv isKindOfClass:[RBKeyboardAvoidingScrollView class]]) {
            sv = sv.superview;
        }
        if ([sv isKindOfClass:[RBKeyboardAvoidingScrollView class]]) {
            [(RBKeyboardAvoidingScrollView *)sv moveResponderIntoPlace:firstResponder];
        }
        return;
    }
    
    [self resignFirstResponder];
}


- (void)closeField:(id)sender {
    [self resignFirstResponder];
}


- (void)calculate 
{
    if (!self.formCalculate) {
        return;
    }
    
    NSMutableDictionary *s = [NSMutableDictionary dictionaryWithCapacity:self.calcVarFields.count];
    for (NSString *varName in [self.calcVarFields allKeys]) {
        UIControl *ctrl = [self.calcVarFields objectForKey:varName];
        if ([ctrl isKindOfClass:[RBTextField class]]) {
            RBTextField *textField = [self.calcVarFields objectForKey:varName];
            NSString *text = textField.text;
            if (textField.formTextFormat) {
                NSRange r = [textField.formTextFormat rangeOfString:@"%@"];
                if (r.location != NSNotFound) {
                    NSString *prefix = [textField.formTextFormat substringToIndex:r.location];
                    NSString *suffix = [textField.formTextFormat substringFromIndex:r.location + r.length];
                    prefix = [prefix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
                    suffix = [suffix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
                    if (([prefix length] == 0 || [text hasPrefix:prefix]) && ([suffix length] == 0 || [text hasSuffix:suffix])) {
                        int length = [text length] - [prefix length] - [suffix length];
                        text = [text substringWithRange:NSMakeRange(r.location, length)];
                    }
                }
            }
            NSNumber *num = [NSNumber numberWithFloat:[text floatValue]];
            [s setValue:num forKey:varName];
        }
        else {
            NSNumber *num = [NSNumber numberWithBool:[ctrl.formTextValue boolValue]];
            [s setValue:num forKey:varName];
        }
    }
    NSError *error = nil;
    NSNumber *result = [self.formCalculate numberByEvaluatingStringWithSubstitutions:s error:&error];
    if (error) {
        NSLog(@"error calculating field %@ by eval of expr %@: %@", self.formID, self.formCalculate, [error localizedDescription]);
    }
    else if (([result floatValue] == 0 && !self.formShowZero) || [[NSDecimalNumber notANumber] isEqualToNumber:result] || 
             [result doubleValue] == INFINITY || [result doubleValue] == -INFINITY) {
        self.text = @"";
    }
    else {
        if (self.formTextFormat) {
            self.text = [NSString stringWithFormat:self.formTextFormat, [result stringValue]];
        }
        else {
            self.text = [result stringValue];
        }
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
    if (usePopover_) {
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
    else {
        BOOL resp = [super becomeFirstResponder];
        if (resp) {
            if ([self.text length] == 0 && [self.inputView isKindOfClass:[UIPickerView class]] && [self.items count] > 0) {
                self.text = [self.items objectAtIndex:0];
            }
            if([self.text length] == 0 && [self.inputView isKindOfClass:[UIDatePicker class]]){
                self.text = [[self formatterForSubtype] stringFromDate:[NSDate date]];
            }
        }
        return resp;
    }
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
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [items addObject:item];
    
    toolbar.items = items;
    
    
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
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.delegate = self;
    }
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    [self.popoverController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    //release the popover content
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
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:item];
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [items addObject:item];
    
    toolbar.items = items;
    
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
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.delegate = self;
    }
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    [self.popoverController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //release the popover content
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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

#pragma mark - calculation observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"text"] && context == @"calculate") {
        [self calculate];
    }
    else if ([keyPath isEqual:@"selected"] && context == @"calculate") {
        [self calculate];
    }
}


@end
