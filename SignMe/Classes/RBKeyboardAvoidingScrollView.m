//
//  RBKeyboardAvoidingScrollView.m
//
//  Created by Matthias Tretter
//  Copyright 2011 NOUS Wissensmagement GmbH. All rights reserved.
//

#import "RBKeyboardAvoidingScrollView.h"

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface RBKeyboardAvoidingScrollView ()

@property (nonatomic, assign) CGRect priorFrame;

- (UIView *)findFirstResponderBeneathView:(UIView *)view;

- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;
@end

@implementation RBKeyboardAvoidingScrollView

@synthesize priorFrame;

- (void)setup {
    if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
        self.contentSize = self.bounds.size;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    if ( !CGRectEqualToRect(priorFrame, CGRectZero) ) return;
    
    UIView *firstResponder = [self findFirstResponderBeneathView:[self.subviews objectAtIndex:0]];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    priorFrame = self.frame;
    
    // keyboard frame is in window coordinates
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
	// convert own frame to window coordinates, frame is in superview's coordinates
	CGRect ownFrame = [self.window convertRect:self.frame fromView:self.superview];
    
	// calculate the area of own frame that is covered by keyboard
	CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);
    
	// now this might be rotated, so convert it back
	coveredFrame = [self.window convertRect:coveredFrame toView:self.superview];
    
    CGRect responderFrame = firstResponder.frame;
    
    // switch frames because of landscape
    keyboardFrame = CGRectMake(keyboardFrame.origin.y, keyboardFrame.origin.x, keyboardFrame.size.height, keyboardFrame.size.width);
    responderFrame.origin.y += self.frame.origin.y - self.contentOffset.y;
    
    CGPoint responderLeftBottom = CGPointMake(responderFrame.origin.x, responderFrame.origin.y + responderFrame.size.height);
    
	// set inset to make up for covered array at bottom
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    {{
        self.contentInset = UIEdgeInsetsMake(0, 0, coveredFrame.size.height, 0);
        self.scrollIndicatorInsets = self.contentInset;
        // If active text field is hidden by keyboard, scroll it so it's visible
        if (responderLeftBottom.y >= keyboardFrame.origin.y && responderLeftBottom.y <= keyboardFrame.origin.y + keyboardFrame.size.height) {
            CGFloat diff = fabs(responderLeftBottom.y - coveredFrame.origin.y) + 5.f;
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y+diff) animated:YES];
        }
    }}
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    if ( CGRectEqualToRect(priorFrame, CGRectZero) ) return;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    {{
        self.contentInset = UIEdgeInsetsZero;
        self.scrollIndicatorInsets = UIEdgeInsetsZero;
    }}
    [UIView commitAnimations];
    
    priorFrame = CGRectZero;
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

@end
