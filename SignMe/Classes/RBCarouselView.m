//
//  RBCarouselView.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBCarouselView.h"
#import "PSIncludes.h"

NSDateFormatter *dateFormatter = nil;

@interface RBCarouselView ()

@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UILabel *label3;

- (void)updateLabelFrames;

@end

@implementation RBCarouselView

@synthesize label1 = label1_;
@synthesize label2 = label2_;
@synthesize label3 = label3_;
@synthesize isAddClientView = isAddClientView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [RBCarouselView class]) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    }
}

+ (RBCarouselView *)carouselView {
    return [[[RBCarouselView alloc] initWithFrame:kCarouselViewFrame] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        label1_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        label1_.font = [UIFont boldSystemFontOfSize:21];
        label1_.textColor = [UIColor whiteColor];
        label1_.backgroundColor = [UIColor clearColor];
        label1_.textAlignment = UITextAlignmentLeft;
        label1_.numberOfLines = 0;
        label1_.lineBreakMode = UILineBreakModeTailTruncation;
        
        label2_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label1_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label2_.font = [UIFont systemFontOfSize:15];
        label2_.textColor = [UIColor whiteColor];
        label2_.backgroundColor = [UIColor clearColor];
        label2_.textAlignment = UITextAlignmentLeft;
        
        label3_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label2_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label3_.font = [UIFont systemFontOfSize:15];
        label3_.textColor = [UIColor colorWithRed:0.7765f green:0.7333f blue:0.1137f alpha:1.0000f];
        label3_.backgroundColor = [UIColor clearColor];
        label3_.textAlignment = UITextAlignmentLeft;
    
        isAddClientView_ = NO;
        
        [self addSubview:label1_];
        [self addSubview:label2_];
        [self addSubview:label3_];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(label1_);
    MCRelease(label2_);
    MCRelease(label3_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBCarouselView
////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)text {
    self.label1.text = [text uppercaseString];
    
}

- (void)setFromFormStatus:(RBFormStatus)formType {
    self.label1.text = [RBFormStatusStringRepresentation(formType) uppercaseString];
    self.label2.text = @"XY TEMPLATES";
    self.label3.text = @"UPDATED ___";
    [self updateLabelFrames];
}

- (void)setFromForm:(RBForm *)form {
    [self setText:form.name];
}

- (void)setFromClient:(RBClient *)client {
    self.label1.text = [client.name uppercaseString];
    self.label2.text = [NSString stringWithFormat:@"%d DOCUMENTS", client.documents.count];
#pragma message("TODO: set last date, not any")
    if (client.documents.count > 0) {
        self.label3.text = [NSString stringWithFormat:@"UPDATED %@", [dateFormatter stringFromDate:[[client.documents anyObject] date]]]; 
    } else {
        self.label3.text = @"NEVER UPDATED";
    }
    
    [self updateLabelFrames];
}

- (void)updateLabelFrames {
    [self.label1 sizeToFit];
    self.label1.frameTop = 0.f;
    self.label1.frameWidth = self.bounds.size.width;
    
    [self.label2 positionUnderView:self.label1 padding:0 alignment:MTUIViewAlignmentLeftAligned];
    [self.label3 positionUnderView:self.label2 padding:0 alignment:MTUIViewAlignmentLeftAligned];
}

@end
