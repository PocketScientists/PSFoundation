//
//  RBTimeView.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//


#define kMonthFontSize      22
#define kMonthFontColor     kRBColorMain
#define kMonthRect          CGRectMake(0,0,self.bounds.size.width,20)

#define kDayFontSize        42
#define kDayFontColor       kRBColorMain
#define kDayRect            CGRectMake(0,22,self.bounds.size.width,40)

#define kTimeFontSize       12
#define kTimeFontColor      kRBColorMain
#define kTimeRect           CGRectMake(0,62,self.bounds.size.width,20)

#import "RBTimeView.h"
#import "PSIncludes.h"

static NSDateFormatter *monthFormatter = nil;
static NSDateFormatter *dayFormatter = nil;
static NSDateFormatter *timeFormatter = nil;


@implementation RBTimeView

@synthesize updateTimer = updateTimer_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [RBTimeView class]) {
        monthFormatter = [[NSDateFormatter alloc] init];
        dayFormatter = [[NSDateFormatter alloc] init];
        timeFormatter = [[NSDateFormatter alloc] init];
        
        [monthFormatter setDateFormat:@"MMM"];
        [dayFormatter setDateFormat:@"dd"];
        // always use US-Locale for timeFormatter to display AM/PM instead of e.g. vorm/nachm for german locale
        [timeFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        [timeFormatter setDateFormat:@"h:mm aa"];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(updateTimer_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDate *now = [NSDate date];
    NSString *month = [[monthFormatter stringFromDate:now] uppercaseString];
    NSString *day = [dayFormatter stringFromDate:now];
    NSString *time = [timeFormatter stringFromDate:now];
    
    CGContextSaveGState(context);
    
    // draw Month, e.g. NOV
    [kMonthFontColor set];
    [month drawInRect:kMonthRect
             withFont:[UIFont fontWithName:kRBFontName size:kMonthFontSize] 
        lineBreakMode:UILineBreakModeClip
            alignment:UITextAlignmentRight];
    
    // draw Day, e.g. 12
    [kDayFontColor set];
    [day drawInRect:kDayRect 
           withFont:[UIFont fontWithName:kRBFontName size:kDayFontSize] 
      lineBreakMode:UILineBreakModeClip 
          alignment:UITextAlignmentRight];
    
    // draw Time, e.g. 02:34 am
    [kTimeFontColor set];
    [time drawInRect:kTimeRect
            withFont:[UIFont fontWithName:kRBFontName size:kTimeFontSize]
       lineBreakMode:UILineBreakModeClip 
           alignment:UITextAlignmentRight];
    
    CGContextRestoreGState(context);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // automatically start/stop timer if view is visible
    if (newSuperview != nil) {
        [self startUpdating];
    } else {
        [self stopUpdating];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Timer
////////////////////////////////////////////////////////////////////////

// update time display every 10 seconds
- (void)startUpdating {
    [self stopUpdating];
    
    __block RBTimeView *blockSelf = self;
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:MTTimeIntervalSeconds(10) block:^(void) {
        [blockSelf setNeedsDisplay];
    } repeats:YES];
}

// stops updating the time display
- (void)stopUpdating {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}
@end
