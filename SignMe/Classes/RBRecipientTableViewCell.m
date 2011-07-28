//
//  RBRecipientTableViewCell.m
//  SignMe
//
//  Created by Tretter Matthias on 28.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBRecipientTableViewCell.h"
#import "PSIncludes.h"


// fonts needed to draw the cell
static UIFont *mainTextFont = nil;
static UIFont *detailTextFont = nil;

@implementation RBRecipientTableViewCell

@synthesize mainText = mainText_;
@synthesize detailText = detailText_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [RBRecipientTableViewCell class]) {
        mainTextFont = [[UIFont fontWithName:kRBFontName size:16] retain];
        detailTextFont = [[UIFont fontWithName:kRBFontName size:14] retain];
    }
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

+ (id)cellForTableView:(UITableView *)tableView style:(UITableViewCellStyle)style {
    NSString *cellID = [self cellIdentifier];
    RBRecipientTableViewCell *cell = (RBRecipientTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[[self alloc] initWithStyle:style reuseIdentifier:cellID] autorelease];
    }
    
    return cell;    
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(mainText_);
    MCRelease(detailText_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter
////////////////////////////////////////////////////////////////////////

- (void)setMainText:(NSString *)mainText {
	if (mainText != mainText_) {
        [mainText_ release];
        mainText_ = [mainText copy];
    }
    
	[self setNeedsDisplay];
}

- (void)setDetailText:(NSString *)detailText {
	if (detailText != detailText_) {
        [detailText_ release];
        detailText_ = [detailText copy];
    }
    
	[self setNeedsDisplay];
}
////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Editing
////////////////////////////////////////////////////////////////////////

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
 	[self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Drawing
////////////////////////////////////////////////////////////////////////

- (void)drawContentView:(CGRect)r highlighted:(BOOL)highlighted {
	UIColor *mainTextColor = kRBColorMain;
    UIColor *detailTextColor = kRBColorDetail;
    CGPoint p;
    
    // change colors when selected
	if(highlighted) {
        mainTextColor   = [UIColor whiteColor];
        detailTextColor   = [UIColor whiteColor];
	}
    
    
    // draw main text
    p.x = 20.f;
    p.y = 4.f;
    [mainTextColor set];
    NSString *textToDraw = [self.mainText stringByTruncatingToWidth:self.frame.size.width - p.x - 20.f withFont:mainTextFont];
    [textToDraw drawAtPoint:p withFont:mainTextFont];
    
    // draw detail text
    p.y = 23.f;
    [detailTextColor set];
    textToDraw = [self.detailText stringByTruncatingToWidth:self.frame.size.width - p.x - 20.f withFont:detailTextFont];
    [textToDraw drawAtPoint:p withFont:detailTextFont];
}

@end
