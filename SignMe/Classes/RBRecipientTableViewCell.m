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
static UIFont *placeholderTextFont = nil;


@interface RBRecipientTableViewCell()
@property (nonatomic, retain) UIButton *codeBtn;
@property (nonatomic, retain) UIButton *idBtn;

- (void)changeCode:(UIButton *)button;
- (void)changeIDAuth:(UIButton *)button;
@end

@implementation RBRecipientTableViewCell

@synthesize codeBtn;
@synthesize idBtn;
@synthesize image = image_;
@synthesize mainText = mainText_;
@synthesize detailText = detailText_;
@synthesize placeholderText = placeholderText_;
@synthesize code = code_;
@synthesize idcheck = idcheck_;
@synthesize delegate;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [RBRecipientTableViewCell class]) {
        mainTextFont = [[UIFont fontWithName:kRBFontName size:16] retain];
        detailTextFont = [[UIFont fontWithName:kRBFontName size:14] retain];
        placeholderTextFont = [[UIFont fontWithName:kRBFontName size:16] retain];
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
        //image_ = [[UIImage imageNamed:@"EmptyContact"] retain];
        self.codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize size = [UIImage imageNamed:@"Code"].size;
        [codeBtn setImage:[UIImage imageNamed:@"Code"] forState:UIControlStateNormal];
        [codeBtn setImage:[UIImage imageNamed:@"CodeSelected"] forState:UIControlStateSelected];
        [codeBtn addTarget:self action:@selector(changeCode:) forControlEvents:UIControlEventTouchUpInside];
        codeBtn.frame = CGRectMake(self.frameWidth - size.width - 50, 7, size.width, size.height);
        codeBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        codeBtn.hidden = YES;
        [self addSubview:codeBtn];

        self.idBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        size = [UIImage imageNamed:@"IDCard"].size;
        [idBtn setImage:[UIImage imageNamed:@"IDCard"] forState:UIControlStateNormal];
        [idBtn setImage:[UIImage imageNamed:@"IDCardSelected"] forState:UIControlStateSelected];
        [idBtn addTarget:self action:@selector(changeIDAuth:) forControlEvents:UIControlEventTouchUpInside];
        idBtn.frame = CGRectMake(self.frameWidth - size.width - 90, 12, size.width, size.height);
        idBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        idBtn.hidden = YES;
        [self addSubview:idBtn];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(image_);
    MCRelease(mainText_);
    MCRelease(detailText_);
    MCRelease(placeholderText_);
    MCRelease(codeBtn);
    MCRelease(idBtn);
    
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

- (void)setPlaceholderText:(NSString *)placeholderText {
	if (placeholderText != placeholderText_) {
        [placeholderText_ release];
        placeholderText_ = [placeholderText copy];
    }
    
	[self setNeedsDisplay];
}

- (void)setCode:(int)code {
    code_ = code;
    if (code_ > 0) {
        codeBtn.selected = YES;
    }
    else {
        codeBtn.selected = NO;
    }
}

- (void)setIdcheck:(BOOL)idcheck {
    idcheck_ = idcheck_;
    if (idcheck_) {
        idBtn.selected = YES;
    }
    else {
        idBtn.selected = NO;
    }
}

- (void)enableAuth {
    idBtn.hidden = NO;
    codeBtn.hidden = NO;
}


- (void)disableAuth {
    idBtn.hidden = YES;
    codeBtn.hidden = YES;
}


- (void)changeCode:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        code_ = 1000 + arc4random_uniform(9000);
        PSAlertView *alertView = [PSAlertView alertWithTitle:@"Access Code" message:[NSString stringWithFormat:@"Please tell %@ this access code:\n%d", self.mainText ? self.mainText : @"the signer", self.code]];
        [alertView addButtonWithTitle:@"Ok" block:nil];
        [alertView show];
    }
    else {
        code_ = 0;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(cell:changedCode:idCheck:)]) {
        [delegate cell:self changedCode:self.code idCheck:self.idcheck];
    }
}

- (void)changeIDAuth:(UIButton *)button {
    button.selected = !button.selected;
    idcheck_ = button.selected;
    
    if (delegate && [delegate respondsToSelector:@selector(cell:changedCode:idCheck:)]) {
        [delegate cell:self changedCode:self.code idCheck:self.idcheck];
    }
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
    UIColor *placeholderTextColor = kRBColorMain;
    CGPoint p = CGPointMake(50.f, 5.f);
    
    // change colors when selected
	if(highlighted) {
        [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] set];
        CGContextFillRect(context, r);
        mainTextColor   = kRBColorDetail;
	}
    
    // draw image
    if (image_ != nil) {
        [image_ drawInRect:CGRectMake(50.f, 5.f, self.height-10.f, self.height-10.f)];
        p.x += (self.height+5.f);
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

    // draw placeholder text
    p.y = 13.f;
    [placeholderTextColor set];
    textToDraw = [self.placeholderText stringByTruncatingToWidth:self.frame.size.width - p.x - 20.f withFont:placeholderTextFont];
    [textToDraw drawAtPoint:p withFont:placeholderTextFont];
}

@end
