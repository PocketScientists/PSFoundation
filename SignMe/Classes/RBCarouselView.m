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
#import "DocuSignService.h"

@interface RBCarouselView ()

@property (nonatomic, readwrite, strong) id attachedObject;

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;
@property (nonatomic, strong) UILabel *label4;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *statusView;

- (void)splitTextOnFirstTwoLabels:(NSString *)text;
- (void)updateLabelFrames;
- (void)updateStatusView;

@end

@implementation RBCarouselView

@synthesize attachedObject = attachedObject_;
@synthesize isAddClientView = isAddClientView_;
@synthesize topMargin = topMargin_;
@synthesize label1 = label1_;
@synthesize label2 = label2_;
@synthesize label3 = label3_;
@synthesize label4 = label4_;
@synthesize lineView = lineView_;
@synthesize backgroundView = backgroundView_;
@synthesize statusView = statusView_;

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

+ (RBCarouselView *)carouselViewWithWidth:(CGFloat)width {
    return [[RBCarouselView alloc] initWithFrame:CGRectMake(0, 0, width, 120)];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = NO;
        
        topMargin_ = 0.f;
        
        label1_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        label1_.textColor = kRBColorMain;
        label1_.backgroundColor = [UIColor clearColor];
        label1_.textAlignment = UITextAlignmentLeft;
        label1_.lineBreakMode = UILineBreakModeClip;
        
        label2_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label1_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label2_.textColor = kRBColorMain;
        label2_.backgroundColor = [UIColor clearColor];
        label2_.textAlignment = UITextAlignmentLeft;
        label2_.numberOfLines = 0;
        label2_.lineBreakMode = UILineBreakModeTailTruncation;
        
        label3_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label2_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label3_.textColor = kRBColorMain;
        label3_.backgroundColor = [UIColor clearColor];
        label3_.textAlignment = UITextAlignmentLeft;
        
        label4_ = [[UILabel alloc] initWithFrame:CGRectMake(0, label2_.frameBottom, self.bounds.size.width, self.bounds.size.height*0.2)];
        label4_.textColor = kRBColorDetail;
        label4_.backgroundColor = [UIColor clearColor];
        label4_.textAlignment = UITextAlignmentLeft;
        
        lineView_ = [[UIView alloc] initWithFrame:CGRectMake(-15, 2, 1, self.bounds.size.height-4)];
        lineView_.autoresizingMask = UIViewAutoresizingNone;
        lineView_.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.2f];
        lineView_.opaque = NO;
        
        backgroundView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CarouselDetailBackground"]];
        backgroundView_.contentMode =  UIViewContentModeScaleAspectFill;
        backgroundView_.frame = self.bounds;
        backgroundView_.hidden = YES;
        
        statusView_ = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-28, self.bounds.size.height-44, 34, 34)];
        statusView_.hidden = YES;
        
        isAddClientView_ = NO;
        
        [self addCenteredSubview:backgroundView_];
        [self addSubview:label1_];
        [self addSubview:label2_];
        [self addSubview:label3_];
        [self addSubview:label4_];
        [self addSubview:lineView_];
        [self addSubview:statusView_];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl
////////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    CALayer * theLayer = self.layer;
    
    if (selected) {
        if ([theLayer respondsToSelector:@selector(setShadowPath:)] && [theLayer respondsToSelector:@selector(shadowPath)]) {
            if (theLayer.shadowRadius != 40.f) {
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddRect(path, NULL, theLayer.bounds);
                theLayer.shadowPath = path;
                CGPathRelease(path);
            }
			
            theLayer.shadowOffset = CGSizeZero;     
            theLayer.shadowColor = [UIColor colorWithWhite:1.f alpha:0.3].CGColor;
            theLayer.shadowRadius = 40.f;            
            theLayer.shadowOpacity = 1.0;                
        }
    } else {
        theLayer.shadowOpacity = 0.0;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setters
////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)text {
    self.topMargin = 0.f;
    self.label2.text = [text uppercaseString];
    self.backgroundView.hidden = NO;
    self.lineView.hidden = YES;
    
    self.label2.frame = self.bounds;
    self.label2.textAlignment = UITextAlignmentCenter;
    self.label2.font = [UIFont fontWithName:kRBFontName size:22.];
}

- (void)setFromFormStatus:(RBFormStatus)formStatus count:(NSUInteger)count {
    self.topMargin = 0.f;
    self.attachedObject = $I(formStatus);
    self.backgroundView.hidden = YES;
    self.lineView.hidden = NO;
    
    NSString *description = formStatus == RBFormStatusNew ? @"TEMPLATE" : @"DOCUMENT";
    
    if (count != 1) {
        description = [description stringByAppendingString:@"S"];
    }
    
    
    self.label1.text = [RBFormStatusStringRepresentation(formStatus) uppercaseString];
    self.label2.text = @"AGREEMENTS";
    self.label3.text = [NSString stringWithFormat:@"%d %@", count, description];
    self.label4.text = RBUpdateStringForFormStatus(formStatus);
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:30.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:18.];
    self.label3.font = [UIFont fontWithName:kRBFontName size:14.];
    self.label4.font = [UIFont fontWithName:kRBFontName size:14.];
    
    [self updateLabelFrames];
    [self updateStatusView];
}

- (void)setFromForm:(RBForm *)form {
    self.topMargin = 22.f;
    self.attachedObject = form;
    self.backgroundView.hidden = NO;
    self.lineView.hidden = YES;
    
    self.label2.numberOfLines = 2;
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:30.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:18.];
    
    [self splitTextOnFirstTwoLabels:form.displayName];
    
    if (IsEmpty(self.label2.text)) {
        self.label2.text = @"FORM";
    }
    
    [self updateLabelFrames];
    [self updateStatusView];
}

- (void)setFromClient:(RBClient *)client {
    self.topMargin = 0.f;
    self.attachedObject = client;
    self.backgroundView.hidden = YES;
    self.lineView.hidden = NO;
    
    self.label1.text = [client.name uppercaseString];
    self.label1.numberOfLines = 2;
    
    self.label2.text = [NSString stringWithFormat:@"%@\n%@, %@ %@", client.street, client.city, client.country_iso, client.postalcode];
    self.label2.numberOfLines = 3;
    
    if(client.classification3.length > 0){
        self.label3.text = [NSString stringWithFormat:@"%@ / %@ / %@", client.classification1, client.classification2, client.classification3];
    }else if(client.classification2.length > 0){
         self.label3.text = [NSString stringWithFormat:@"%@ / %@ ", client.classification1, client.classification2];
    }else{
       self.label3.text = [NSString stringWithFormat:@"%@ ", client.classification1]; 
    }
    
        self.label4.text = [NSString stringWithFormat:NSLocalizedString(@"%d DOCUMENTS", @"%d DOCUMENTS"), client.documents.count];
    
    //    if (client.documents.count > 0) {
    //        RBPersistenceManager *persistenceManager = [[RBPersistenceManager alloc] init];
    //
    //        self.label4.text = [NSString stringWithFormat:NSLocalizedString(@"UPDATED %@", @"UPDATED %@"), RBFormattedDateWithFormat([persistenceManager updateDateForClient:client], kRBDateFormat)];
    //    } else {
    //        self.label4.text = NSLocalizedString(@"NEVER UPDATED", @"NEVER UPDATED");
    //    }
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:20.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:12.];
    self.label3.font = [UIFont fontWithName:kRBFontName size:14.];
    self.label4.font = [UIFont fontWithName:kRBFontName size:14.];
    
    [self updateLabelFrames];
    [self updateStatusView];
}

- (void)setFromDocument:(RBDocument *)document {
    self.topMargin = 5.f;
    self.attachedObject = document;
    self.backgroundView.hidden = NO;
    self.lineView.hidden = YES;
    
    [self splitTextOnFirstTwoLabels:[document.client.name uppercaseString]];
    self.label3.text = [document.name uppercaseString];
    self.label4.text = RBFormattedDateWithFormat(document.date, kRBDateTime2Format);
    
    self.label2.numberOfLines = 2;
    
    self.label1.font = [UIFont fontWithName:kRBFontName size:16.];
    self.label2.font = [UIFont fontWithName:kRBFontName size:25.];
    self.label3.font = [UIFont fontWithName:kRBFontName size:14.];
    self.label4.font = [UIFont fontWithName:kRBFontName size:14.];
    
    [self updateLabelFrames];
    [self updateStatusView];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

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
        BOOL twoWordsInFirstLine = NO;
        
        if (words.count >= 3) {
            // try if two words fit
            NSString *firstLabelString = [[words objectAtIndex:0] stringByAppendingFormat:@" %@", [words objectAtIndex:1]];
            CGSize sizeNeeded = [firstLabelString sizeWithFont:self.label1.font];
            
            // two words fit
            if (sizeNeeded.width < self.size.width) {
                NSArray *restOfWords = [words subarrayWithRange:NSMakeRange(2, words.count-2)];
                
                twoWordsInFirstLine = YES;
                
                self.label1.text = firstLabelString;
                self.label2.text = [restOfWords componentsJoinedByString:@" "];
            }
        } 
        
        if (!twoWordsInFirstLine) {
            self.label1.text = [words objectAtIndex:0];
            
            NSArray *restOfWords = [words subarrayWithRange:NSMakeRange(1, words.count-1)];
            self.label2.text = [restOfWords componentsJoinedByString:@" "];
        }
    }
}

- (void)updateLabelFrames {
    [self.label1 sizeToFit];
    self.label1.frameTop = self.topMargin;
    self.label1.frameWidth = self.bounds.size.width;
    
    // sizeToFit doesn't work with numberOfLines != 0, Bug?
    if (self.label2.numberOfLines != 0) { 
        CGSize size = [self.label2.text sizeWithFont:self.label2.font
                                   constrainedToSize:CGSizeMake(self.bounds.size.width, self.label2.numberOfLines*self.label2.font.lineHeight)
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

- (void)updateStatusView {
    if ([self.attachedObject isKindOfClass:[RBDocument class]]) {
        RBDocument *document = (RBDocument *)self.attachedObject;
        RBFormStatus formStatus = RBFormStatusForIndex([document.status intValue]);
        
        if (formStatus == RBFormStatusPreSignature && !IsEmpty(document.docuSignEnvelopeID)) {
            DSAPIService_EnvelopeStatusCode docuSignStatus = [document.lastDocuSignStatus intValue];
            
            switch (docuSignStatus) {
                    // Unknown branch
                case DSAPIService_EnvelopeStatusCode_none:
                case DSAPIService_EnvelopeStatusCode_Any:
                    self.statusView.hidden = YES;
                    break;
                    
                    // waiting branch
                case DSAPIService_EnvelopeStatusCode_Processing:
                case DSAPIService_EnvelopeStatusCode_Template:
                case DSAPIService_EnvelopeStatusCode_Created:
                case DSAPIService_EnvelopeStatusCode_Sent:
                case DSAPIService_EnvelopeStatusCode_Delivered:
                case DSAPIService_EnvelopeStatusCode_Signed:
                    self.statusView.image = [UIImage imageNamed:@"StatusYellow"];
                    self.statusView.hidden = NO;
                    break;
                    
                    // finished branch
                case DSAPIService_EnvelopeStatusCode_Completed:
                    self.statusView.image = [UIImage imageNamed:@"StatusGreen"];
                    self.statusView.hidden = NO;
                    break;
                    
                    // Error branch
                case DSAPIService_EnvelopeStatusCode_Voided:
                case DSAPIService_EnvelopeStatusCode_Deleted:
                case DSAPIService_EnvelopeStatusCode_Declined:
                case DSAPIService_EnvelopeStatusCode_TimedOut:
                    self.statusView.image = [UIImage imageNamed:@"StatusRed"];
                    self.statusView.hidden = NO;
                    break;
            }
        } else {
            self.statusView.hidden = YES;
        }
    } else {
        self.statusView.hidden = YES;
    }
}

@end
