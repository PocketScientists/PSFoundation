//
//  RBCarouselView.m
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "RBCarouselView.h"
#import "PSIncludes.h"
#import "RBPersistenceManager.h"

@interface RBCarouselView ()

@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UILabel *label3;
@property (nonatomic, retain) UILabel *label4;

- (void)updateLabelFrames;

@end

@implementation RBCarouselView

@synthesize label1 = label1_;
@synthesize label2 = label2_;
@synthesize label3 = label3_;
@synthesize label4 = label4_;
@synthesize isAddClientView = isAddClientView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (RBCarouselView *)carouselViewWithWidth:(CGFloat)width {
    return [[[RBCarouselView alloc] initWithFrame:CGRectMake(0, 0, width, 120)] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        label1_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        label1_.textColor = [UIColor whiteColor];
        label1_.backgroundColor = [UIColor clearColor];
        label1_.textAlignment = UITextAlignmentLeft;
        label1_.lineBreakMode = UILineBreakModeClip;
        
        label2_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label1_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label2_.textColor = [UIColor whiteColor];
        label2_.backgroundColor = [UIColor clearColor];
        label2_.textAlignment = UITextAlignmentLeft;
        label2_.numberOfLines = 0;
        label2_.lineBreakMode = UILineBreakModeTailTruncation;
        
        label3_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label2_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label3_.textColor = [UIColor whiteColor];
        label3_.backgroundColor = [UIColor clearColor];
        label3_.textAlignment = UITextAlignmentLeft;
        
        label4_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label2_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label4_.textColor = [UIColor colorWithRed:0.7765f green:0.7333f blue:0.1137f alpha:1.0000f];
        label4_.backgroundColor = [UIColor clearColor];
        label4_.textAlignment = UITextAlignmentLeft;

        isAddClientView_ = NO;
        
        [self addSubview:label1_];
        [self addSubview:label2_];
        [self addSubview:label3_];
        [self addSubview:label4_];
    }
    
    return self;
}

- (void)dealloc {
    MCRelease(label1_);
    MCRelease(label2_);
    MCRelease(label3_);
    MCRelease(label4_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl
////////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected {
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RBCarouselView
////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)text {
    self.label2.text = [text uppercaseString];

    self.label2.frame = self.bounds;
    self.label2.textAlignment = UITextAlignmentCenter;
    self.label2.font = [UIFont fontWithName:kRBFontName size:22.];
}

- (void)setFromFormStatus:(RBFormStatus)formStatus count:(NSUInteger)count {
    NSString *description = formStatus == RBFormStatusNew ? @"TEMPLATE" : @"DOCUMENT";
    
    if (count != 1) {
        description = [description stringByAppendingString:@"S"];
    }
    
    
    self.label1.text = [RBFormStatusStringRepresentation(formStatus) uppercaseString];
    self.label2.text = @"AGREEMENTS";
    self.label3.text = [NSString stringWithFormat:@"%d %@", count, description];
    self.label4.text = @"UPDATED ___";
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:30.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:18.];
    self.label3.font = [UIFont fontWithName:kRBFontName size:14.];
    self.label4.font = [UIFont fontWithName:kRBFontName size:14.];
    
    [self updateLabelFrames];
}

- (void)setFromForm:(RBForm *)form {
    [self setText:form.name];
}

- (void)setFromClient:(RBClient *)client {
    NSString *upperCaseName = [client.name uppercaseString];
    NSArray *clientNameWords = [upperCaseName componentsSeparatedByString:@" "];
    
    // Only one word? -> set in on label2
    if (clientNameWords.count == 1) {
        self.label2.text = [upperCaseName uppercaseString];
    } 
    // More words
    else {
        self.label1.text = [clientNameWords objectAtIndex:0];
        
        NSArray *restOfNameWords = [clientNameWords subarrayWithRange:NSMakeRange(1, clientNameWords.count-1)];
        self.label2.text = [restOfNameWords componentsJoinedByString:@" "];
    }
    
    self.label3.text = [NSString stringWithFormat:@"%d DOCUMENTS", client.documents.count];

    if (client.documents.count > 0) {
        RBPersistenceManager *persistenceManager = [[[RBPersistenceManager alloc] init] autorelease];
        
        self.label4.text = [NSString stringWithFormat:@"UPDATED %@", RBFormattedDate([persistenceManager updateDateForClient:client])]; 
    } else {
        self.label4.text = @"NEVER UPDATED";
    }
    
    self.label2.numberOfLines = 2;
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:18.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:30.];
    self.label3.font = [UIFont fontWithName:kRBFontName size:14.];
    self.label4.font = [UIFont fontWithName:kRBFontName size:14.];
    
    [self updateLabelFrames];
}

- (void)updateLabelFrames {
    [self.label1 sizeToFit];
    self.label1.frameTop = 0.f;
    self.label1.frameWidth = self.bounds.size.width;
    
    [self.label2 sizeToFit];
    self.label2.frameWidth = self.bounds.size.width;
    [self.label2 positionUnderView:self.label1 padding:0 alignment:MTUIViewAlignmentLeftAligned];
    
    [self.label3 sizeToFit];
    self.label3.frameWidth = self.bounds.size.width;
    [self.label3 positionUnderView:self.label2 padding:5.f alignment:MTUIViewAlignmentLeftAligned];
    
    [self.label4 sizeToFit];
    self.label4.frameWidth = self.bounds.size.width;
    [self.label4 positionUnderView:self.label3 padding:0 alignment:MTUIViewAlignmentLeftAligned];
}

@end
