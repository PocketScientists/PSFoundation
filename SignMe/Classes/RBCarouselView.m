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

@property (nonatomic, readwrite, retain) id attachedObject;

@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UILabel *label3;
@property (nonatomic, retain) UILabel *label4;

- (void)splitTextOnFirstTwoLabels:(NSString *)text;
- (void)updateLabelFrames;

@end

@implementation RBCarouselView

@synthesize attachedObject = attachedObject_;
@synthesize isAddClientView = isAddClientView_;
@synthesize label1 = label1_;
@synthesize label2 = label2_;
@synthesize label3 = label3_;
@synthesize label4 = label4_;

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
    MCRelease(attachedObject_);
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl
////////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        //[self setCornerRadius:0 borderWidth:1 borderColor:[UIColor redColor]];
    } else {
        //self.layer.borderWidth = 0.f;
    }
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
    self.attachedObject = $I(formStatus);
    
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
    self.attachedObject = form;
    
    self.label2.numberOfLines = 2;
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:30.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:18.];
    
    [self splitTextOnFirstTwoLabels:form.name];
    [self updateLabelFrames];
}

- (void)setFromClient:(RBClient *)client {
    self.attachedObject = client;
    
    [self splitTextOnFirstTwoLabels:client.name];
    
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

- (void)splitTextOnFirstTwoLabels:(NSString *)text {
    NSString *upperCaseText = [text uppercaseString];
    NSArray *words = [upperCaseText componentsSeparatedByString:@" "];
    
    // Only one word? -> set on bigger label
    if (words.count == 1) {
        UILabel *biggerLabel = self.label1.font.pointSize > self.label2.font.pointSize ? self.label1 : self.label2;
        biggerLabel.text = upperCaseText;
    } 
    // More words
    else {
        self.label1.text = [words objectAtIndex:0];
        
        NSArray *restOfWords = [words subarrayWithRange:NSMakeRange(1, words.count-1)];
        self.label2.text = [restOfWords componentsJoinedByString:@" "];
    }
}

- (void)updateLabelFrames {
    [self.label1 sizeToFit];
    self.label1.frameTop = 0.f;
    self.label1.frameWidth = self.bounds.size.width;
    
    // sizeToFit doesn't work with numberOfLines != 0, Bug?
    if (self.label2.numberOfLines != 0) {
        CGSize size = [self.label2.text sizeWithFont:self.label2.font
                                   constrainedToSize:CGSizeMake(self.bounds.size.width, self.label2.numberOfLines*32)
                                       lineBreakMode:self.label2.lineBreakMode];
        self.label2.frame = (CGRect){CGPointZero,size};
    } else {
        [self.label2 sizeToFit];
        self.label2.frameWidth = self.bounds.size.width;
    }
    
    [self.label2 positionUnderView:self.label1 padding:0 alignment:MTUIViewAlignmentLeftAligned];
    
    [self.label3 sizeToFit];
    self.label3.frameWidth = self.bounds.size.width;
    [self.label3 positionUnderView:self.label2 padding:5.f alignment:MTUIViewAlignmentLeftAligned];
    
    [self.label4 sizeToFit];
    self.label4.frameWidth = self.bounds.size.width;
    [self.label4 positionUnderView:self.label3 padding:0 alignment:MTUIViewAlignmentLeftAligned];
}

@end