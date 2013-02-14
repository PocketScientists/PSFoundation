//
//  RBFormView.m
//  SignMe
//
//  Created by Tretter Matthias on 25.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBFormView.h"
#import "PSIncludes.h"
#import "RBForm.h"
#import "UIControl+RBForm.h"
#import "RBRecipientsView.h"
#import "RBTextField.h"
#import "VCTitleCase.h"
#import "RBUIGenerator.h"
#import "RegexKitLite.h"
#import "RBMultiValueTextField.h"


@interface RBFormView ()

- (void)handlePrevButtonPress:(id)sender;
- (void)handleNextButtonPress:(id)sender;
- (void)handlePageChange:(id)sender;

- (void)validateTextField:(UITextField *)textField;
- (void)updateUI;

@end

@implementation RBFormView

@synthesize innerScrollView = innerScrollView_;
@synthesize pageControl = pageControl_;
@synthesize prevButton = prevButton_;
@synthesize nextButton = nextButton_;
@synthesize formLayoutData = formLayoutData_;
@synthesize form = form_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame form:(RBForm *)form {
    if (self = [super initWithFrame:frame]) {
        form_ = form;
        
        self.directionalLockEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.clipsToBounds = YES;
        
        formLayoutData_ = [[NSMutableDictionary alloc] initWithCapacity:20];
        
        innerScrollView_ = [[UIScrollView alloc] initWithFrame:CGRectZero];
        innerScrollView_.scrollEnabled = NO;
        innerScrollView_.pagingEnabled = YES;
        innerScrollView_.delegate = self;
        
        UIImage *prevImage = [UIImage imageNamed:@"PrevButton"];
        prevButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [prevButton_ setImage:prevImage forState:UIControlStateNormal];
        prevButton_.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        prevButton_.frame = CGRectMake(30, 702, prevImage.size.width, prevImage.size.height);
        [prevButton_ addTarget:self action:@selector(handlePrevButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        prevButton_.alpha = 0.f;
        
        UIImage *nextImage = [UIImage imageNamed:@"NextButton"];
        nextButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton_ setImage:nextImage forState:UIControlStateNormal];
        nextButton_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        nextButton_.frame = CGRectMake( self.bounds.size.width - 97, 702, nextImage.size.width, nextImage.size.height);
        [nextButton_ addTarget:self action:@selector(handleNextButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        pageControl_ = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 250, 705, 500, 30)];
        pageControl_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        pageControl_.hidesForSinglePage = YES;
        [pageControl_ addTarget:self action:@selector(handlePageChange:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:innerScrollView_];
}
    
    return self;
}



- (void)layoutSubviews {
    if (CGSizeEqualToSize(lastFormSize, self.bounds.size)) return;
    
    lastFormSize = self.bounds.size;
    [RBUIGenerator resizeFormView:self withForm:self.form];
}


- (void)forceLayout {
    lastFormSize = self.bounds.size;
    id tmpDelegate = innerScrollView_.delegate;
    innerScrollView_.delegate = nil;
    [RBUIGenerator resizeFormView:self withForm:self.form];
    innerScrollView_.delegate = tmpDelegate;
    [self setupResponderChain];
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBFormView
////////////////////////////////////////////////////////////////////////

- (void)setInnerScrollViewSize:(CGSize)size {
    self.innerScrollView.contentSize = size;
    self.innerScrollView.frame = (CGRect){CGPointZero,size};
}

- (NSArray *)formControls {
    // retreive all subviews, that are meant to be controls
    return [self.innerScrollView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject tag] == kRBFormControlTag) {
            return YES;
        }
        
        return NO;
    }]];
}

- (NSArray *)recipients {
    RBRecipientsView *recipientsView = (RBRecipientsView *)[self.innerScrollView viewWithTag:kRBRecipientsViewTag];
    return [recipientsView.recipients copy];
}

- (NSString *)subject {
    RBRecipientsView *recipientsView = (RBRecipientsView *)[self.innerScrollView viewWithTag:kRBRecipientsViewTag];
    return recipientsView.subject;
}

- (BOOL)obeyRoutingOrder {
    RBRecipientsView *recipientsView = (RBRecipientsView *)[self.innerScrollView viewWithTag:kRBRecipientsViewTag];
    return recipientsView.useRoutingOrder;
}

- (void)validate {
    for (id control in [self formControls]) {
        if ([control isKindOfClass:[UITextField class]]) {
            [self validateTextField:(UITextField *)control];
        }
    }
}

- (void)updateRecipientsView {
    RBRecipientsView *recipientsView = (RBRecipientsView *)[self.innerScrollView viewWithTag:kRBRecipientsViewTag];
    for (UITableView *tableView in recipientsView.tableViews) {
        tableView.editing = NO;
        tableView.editing = YES;
    }
}

- (void)setupResponderChain {
    NSInteger section = 0;
    RBTextField *previousTextField = nil;
    
    for (UIControl *inputField in self.formControls) {
        if (inputField.formSection != section) {
            previousTextField = nil;
            section = inputField.formSection;
        }
        // ================ Setup chain to go from one textfield to the next ================
        if (!inputField.formCalculate || [inputField.formCalculate length] == 0) {
            if ([inputField isKindOfClass:[RBTextField class]] && ![inputField.formDatatype isEqualToString:kRBFormDataTypeLabel]) {
                RBTextField *textField = (RBTextField *)inputField;
                textField.delegate = self;
                
                previousTextField.nextField = textField;
                textField.prevField = previousTextField;
                previousTextField = textField;
            }
            else if ([inputField isKindOfClass:[RBMultiValueTextField class]]) {
                for (RBTextField *textField in ((RBMultiValueTextField *)inputField).textFields) {
                    textField.delegate = self;
                    
                    previousTextField.nextField = textField;
                    textField.prevField = previousTextField;
                    previousTextField = textField;
                }
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Target/Action
////////////////////////////////////////////////////////////////////////

- (void)handlePrevButtonPress:(id)sender {
    NSInteger newPage = MAX(0,self.pageControl.currentPage - 1);

    self.pageControl.currentPage = newPage;
    [self.innerScrollView setContentOffset:CGPointMake(newPage*self.bounds.size.width,0) animated:YES];
    [self updateUI];
}

- (void)handleNextButtonPress:(id)sender {
    NSInteger newPage = MIN(self.pageControl.numberOfPages - 1,self.pageControl.currentPage + 1);

    self.pageControl.currentPage = newPage;
    [self.innerScrollView setContentOffset:CGPointMake(newPage*self.bounds.size.width,0) animated:YES];
    [self updateUI];
}

- (void)handlePageChange:(id)sender {
    int newPage = self.pageControl.currentPage;
	
	[self.innerScrollView setContentOffset:CGPointMake(newPage*self.bounds.size.width,0) animated:YES];
    [self updateUI];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //Fix RBHQ / ios6 - set animated:NO (otherwise we have shifted forms.
    [self setContentOffset:CGPointMake(self.contentOffset.x, 0.0) animated:NO];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSArray *subviewsOnCurrentPage = [scrollView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject tag] == kRBFormControlTag && [evaluatedObject formSection] == self.pageControl.currentPage) {
            return YES;
        }
        
        return NO;
    }]];
    
    self.contentSize = CGSizeMake(self.contentSize.width, CGRectGetMaxY([[subviewsOnCurrentPage lastObject] frame]));
    [self flashScrollIndicators];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isKindOfClass:[RBTextField class]]) {
        if (((RBTextField *)textField).nextField) {
            UIView *firstResponder = ((RBTextField *)textField).nextField;
            [firstResponder becomeFirstResponder]; 
            [self moveResponderIntoPlace:firstResponder];

            return YES;
        }
    }
    
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) {
        return NO;
    }
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.formTextFormat) {
        NSRange r = [textField.formTextFormat rangeOfString:@"%@"];
        if (r.location != NSNotFound) {
            NSString *prefix = [textField.formTextFormat substringToIndex:r.location];
            NSString *suffix = [textField.formTextFormat substringFromIndex:r.location + r.length];
            prefix = [prefix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
            suffix = [suffix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
            if (([prefix length] == 0 || [textField.text hasPrefix:prefix]) && ([suffix length] == 0 || [textField.text hasSuffix:suffix])) {
                int length = [textField.text length] - [prefix length] - [suffix length];
                textField.text = [textField.text substringWithRange:NSMakeRange(r.location, length)];
            }
        }
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self validateTextField:textField];
    if (textField.formTextFormat && [textField.text length] > 0) {
        NSRange r = [textField.formTextFormat rangeOfString:@"%@"];
        if (r.location != NSNotFound) {
            //Add to RBHQ -> If Contract Total changes -> update number of necessary signers
            if([textField.formID isEqualToString:@"total"]){
                RBRecipientsView *recipientsView = (RBRecipientsView *)[self.innerScrollView viewWithTag:kRBRecipientsViewTag];
                //[recipientsView setNumberOfRBSigners:RBNumberOfSignersForContractSum([textField.formTextValue integerValue])];
            }
            
            NSString *prefix = [textField.formTextFormat substringToIndex:r.location];
            NSString *suffix = [textField.formTextFormat substringFromIndex:r.location + r.length];
            prefix = [prefix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
            suffix = [suffix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
            if (([prefix length] == 0 || [textField.text hasPrefix:prefix]) && ([suffix length] == 0 || [textField.text hasSuffix:suffix])) {
                textField.text = [textField.text titlecaseString];
            }
            else {
                textField.text = [NSString stringWithFormat:textField.formTextFormat, [textField.text titlecaseString]];
            }
        }
        else {
            textField.text = [textField.text titlecaseString];
        }
    }
    else {
        textField.text = [textField.text titlecaseString];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performBlock:^{
        textField.text = [textField.text titlecaseString];
        
        UITextPosition *pos = [textField positionFromPosition:[textField beginningOfDocument] offset:range.location + 1 - range.length];
        if (pos) {
            UITextRange *selectedRange = [textField textRangeFromPosition:pos toPosition:pos];
            textField.selectedTextRange = selectedRange;
        }
    } afterDelay:0];

    return YES;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

- (void)validateTextField:(UITextField *)textField {
    if (textField.formValidationRegEx && [textField.text length] > 0) {
        NSRange matchedRange = [textField.text rangeOfRegex:textField.formValidationRegEx];
        if (matchedRange.location == NSNotFound) {
            NSString *msg = textField.formValidationMsg ? textField.formValidationMsg : @"Error";
            UILabel *errorMsg = [[UILabel alloc] initWithFrame:textField.bounds];
            errorMsg.tag = 8989;
            errorMsg.backgroundColor = kRBColorError;
            errorMsg.textColor = [UIColor whiteColor];
            errorMsg.font = [UIFont boldSystemFontOfSize:12];
            errorMsg.textAlignment = UITextAlignmentCenter;
            errorMsg.text = msg; 
            errorMsg.frameLeft = 5;
            errorMsg.frameWidth = [msg sizeWithFont:errorMsg.font].width + 10;
            errorMsg.frameHeight = 20;
            errorMsg.frameBottom = 5;
            textField.clipsToBounds = NO;
            [textField addSubview:errorMsg];
        }
        else {
            [[textField viewWithTag:8989] removeFromSuperview];
        }
    }
    else {
        [[textField viewWithTag:8989] removeFromSuperview];
    }
}


- (void)updateUI {
    if (self.pageControl.currentPage == 0) {
        [self.prevButton setAlpha:0.f duration:0.3f];
    } else {
        [self.prevButton setAlpha:1.f duration:0.3f];
    }
    
    if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
        [self.nextButton setAlpha:0.f duration:0.3f];
    } else {
        [self.nextButton setAlpha:1.f duration:0.3f];
    }
}

@end
