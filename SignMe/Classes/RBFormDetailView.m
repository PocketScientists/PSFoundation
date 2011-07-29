//
//  RBFormDetailView.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBFormDetailView.h"
#import "PSIncludes.h"
#import "RBArrowView.h"

@implementation RBFormDetailView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setGradientBackgroundWithStartColor:kRBDetailGradientStartColor
                                         endColor:kRBDetailGradientEndColor];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = YES;
        
        RBArrowView *arrow = [[[RBArrowView alloc] initWithFrame:CGRectMake(frame.size.width/2, 5, 18, 14)] autorelease];
        [self addSubview:arrow];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // resize gradient background-layer
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.bounds;
        }
    }
}

- (void)reloadData {
    for (UIView *view in self.subviews) {
        if ([view respondsToSelector:@selector(reloadData)]) {
            [view performSelector:@selector(reloadData)];
        }
    }
}

@end
