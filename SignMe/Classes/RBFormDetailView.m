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
        self.backgroundColor = kRBCarouselColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.clipsToBounds = NO;
        
        RBArrowView *arrowView = [[[RBArrowView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 20, -20, 40, 21)] autorelease];
        [self addSubview:arrowView];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat stroke = 1.0;
    CGContextRef c = UIGraphicsGetCurrentContext(); 
	
    [kRBCarouselViewColor set];
	CGContextSetLineWidth(c,stroke);
	
    // top border
    CGContextBeginPath(c);
    CGContextMoveToPoint(c,0,0);
    CGContextAddLineToPoint(c, self.bounds.size.width, 0);
    CGContextStrokePath(c);
    
    // bottom border
    CGContextBeginPath(c);
    CGContextMoveToPoint(c,0,self.bounds.size.height);
    CGContextAddLineToPoint(c, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(c);
}

@end
