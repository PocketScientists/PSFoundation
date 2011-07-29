//
//  RBArrowView.m
//  SignMe
//
//  Created by Tretter Matthias on 21.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBArrowView.h"
#import "PSIncludes.h"

@implementation RBArrowView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat stroke = 1.0;
    CGContextRef c = UIGraphicsGetCurrentContext(); 
    CGFloat center = self.bounds.size.width/2;
	
    [kRBColorDetail set];
	CGContextSetLineWidth(c,stroke);
	
    // filled triangle
    CGContextBeginPath(c);
    CGContextMoveToPoint(c,0,self.bounds.size.height);
    CGContextAddLineToPoint(c, center, 0);
    CGContextAddLineToPoint(c, self.bounds.size.width, self.bounds.size.height);
    CGContextClosePath(c);
    CGContextFillPath(c);
}

@end
