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

@synthesize image = image_;
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
        image_ = [[UIImage imageNamed:@"EmptyContact"] retain];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(image_);
    MCRelease(mainText_);
    MCRelease(detailText_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter
////////////////////////////////////////////////////////////////////////

- (void)setImage:(UIImage *)image {
	if (image_ != image) {
        [image_ release];
        image_ = [image copy];
    }
    
	[self setNeedsDisplay];
}


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
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *mainTextColor = kRBColorMain;
    UIColor *detailTextColor = kRBColorDetail;
    CGPoint p = CGPointMake(45.f, 5.f);
    
    // change colors when selected
	if(highlighted) {
        [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] set];
        CGContextFillRect(context, r);
        mainTextColor   = kRBColorDetail;
	}
    
    // draw image
    if (image_ != nil) {
        [image_ drawInRect:CGRectMake(45.f, 5.f, self.height-10.f, self.height-10.f)];
        p.x += self.height;
    }
    
    // draw main text
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
