//
//  RBCarouselView.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBCarouselView.h"
#import "PSIncludes.h"

// #define kUseBorderHack

@implementation RBCarouselView

@synthesize textLabel = textLabel_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (RBCarouselView *)carouselView {
    return [[[RBCarouselView alloc] initWithFrame:kCarouselViewFrame] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor darkGrayColor];
        
        textLabel_ = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds,1.f,1.f)];
        // [textLabel_ setCornerRadius:0 borderWidth:2 borderColor:[UIColor blackColor]];
        textLabel_.font = [UIFont boldSystemFontOfSize:16];
        textLabel_.textColor = [UIColor whiteColor];
        textLabel_.backgroundColor = [UIColor clearColor];
        textLabel_.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:textLabel_];
        
#ifdef kUseBorderHack
        // Hack: 1px on bottom is clipped - why??
        // This doubles the line on top for same-size border overall
        UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(1,self.bounds.size.height-4,self.bounds.size.width-2,1)] autorelease];
        lineView.backgroundColor = [UIColor blackColor];
        [self addSubview:lineView];
#endif
    }
    return self;
}

- (void)dealloc {
    MCRelease(textLabel_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBCarouselView
////////////////////////////////////////////////////////////////////////

- (void)setFromFormType:(RBFormType)formType {
    self.textLabel.text = RBFormTypeStringRepresentation(formType);
}

- (void)setFromClient:(RBClient *)client {
    self.textLabel.text = @"TODO: Client";
}
@end
