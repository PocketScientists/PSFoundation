//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>


// TODO: completely remove this class and replace it with RBKeyboardAvoidingScrollView
// RBKeyboardAvScrView doesn't work yet with Edit Client - screen

@interface TPKeyboardAvoidingScrollView : UIScrollView {
    CGRect priorFrame;
}

@end
