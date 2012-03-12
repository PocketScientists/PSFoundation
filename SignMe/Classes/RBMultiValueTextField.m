//
//  RBMultiValueTextField.m
//  SignMe
//
//  Created by Juergen Falb on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RBMultiValueTextField.h"
#import "RBTextField.h"
#import "PSIncludes.h"
#import "UIControl+RBForm.h"
#import "RBFormView.h"

#define kRBRowHeight                35.f
#define kRBRowPadding               11.f


@interface RBMultiValueTextField() 
- (IBAction)addValue:(UIButton *)sender;
- (IBAction)removeValue:(UIButton *)sender;
- (IBAction)setNumberOfValues:(int)noValues;
@end


@implementation RBMultiValueTextField

@synthesize textFields = textFields_;
@synthesize rows = rows_;
@synthesize values = values_;
@synthesize items = items_;
@synthesize calcVarFields = calcVarFields_;
@synthesize text = text_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textFields = [NSMutableArray array];
    }
    
    return self;
}


- (void)setValues:(NSArray *)values {
    if (values_ == values) return;
    values_ = values;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (id tf in self.textFields) {
        [tf removeObserver:self forKeyPath:@"text"];
    }
    [self.textFields removeAllObjects];
    
    CGFloat y = 0.0f;
    for (int i = 0; i < [values count]; i++) {
        NSString *value = [values objectAtIndex:i];
        
        CGFloat width = self.formShowRepeatButton ? self.bounds.size.width - 40.0f : self.bounds.size.width;
        RBTextField *textField = [[RBTextField alloc] initWithFrame:CGRectMake(0.0f, y, width, kRBRowHeight)];
        
        textField.formValidationMsg = self.formValidationMsg;
        textField.formValidationRegEx = self.formValidationRegEx;
        textField.subtype = self.formSubtype;
        textField.formTextFormat = self.formTextFormat;
        textField.formShowZero = self.formShowZero;
        textField.formCalculate = self.formCalculate;
        textField.items = self.items;
        
        textField.borderStyle = UITextBorderStyleBezel;
        textField.backgroundColor = [UIColor whiteColor];
        textField.font = [UIFont fontWithName:kRBFontName size:18];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (value && [value length] > 0 && textField.formTextFormat) {
            NSRange r = [textField.formTextFormat rangeOfString:@"%@"];
            if (r.location != NSNotFound) {
                NSString *prefix = [textField.formTextFormat substringToIndex:r.location];
                NSString *suffix = [textField.formTextFormat substringFromIndex:r.location + r.length];
                prefix = [prefix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
                suffix = [suffix stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
                if (([prefix length] == 0 || [value hasPrefix:prefix]) && ([suffix length] == 0 || [value hasSuffix:suffix])) {
                    textField.text = value;
                }
                else {
                    textField.text = [NSString stringWithFormat:textField.formTextFormat, value];
                }
            }
            else {
                textField.text = [NSString stringWithFormat:textField.formTextFormat, value];
            }
        }
        else {
            textField.text = value;
        }

        if (textField.formCalculate && [textField.formCalculate length] > 0) {
            textField.enabled = NO;
        }
        
        [self.textFields addObject:textField];
        [self addSubview:textField];
        [textField addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:@"calculatemulti"];
        
        if (self.formShowRepeatButton) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(self.bounds.size.width - 40.0f, y, 40.0f, kRBRowHeight);
            btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            btn.tag = i;
            if (i == 0) {
                [btn setImage:[UIImage imageNamed:@"AddButton.png"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(addValue:) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                [btn setImage:[UIImage imageNamed:@"RemoveButton.png"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(removeValue:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self addSubview:btn];
        }
        
        y += kRBRowHeight + kRBRowPadding;
    }
    
    self.rows = values.count;
}


- (NSArray *)values {
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.rows];
    for (RBTextField *textField in self.textFields) {
        [values addObject:textField.text];
    }
    return values;
}


- (IBAction)addValue:(UIButton *)sender {
    for (RBMultiValueTextField *control in self.formRepeatGroup) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:control.values];
        [a addObject:@""];
        control.values = a;
    }
    
    UIView *v = self.superview;
    while (v && ![v isKindOfClass:[RBFormView class]]) {
        v = v.superview;
    }
    if (v) {
        [(RBFormView *)v forceLayout];
    }
}


- (IBAction)removeValue:(UIButton *)sender {
    for (RBMultiValueTextField *control in self.formRepeatGroup) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:control.values];
        [a removeObjectAtIndex:sender.tag];
        control.values = a;
    }
    
    UIView *v = self.superview;
    while (v && ![v isKindOfClass:[RBFormView class]]) {
        v = v.superview;
    }
    if (v) {
        [(RBFormView *)v forceLayout];
    }
}


- (IBAction)setNumberOfValues:(int)noValues {
    for (RBMultiValueTextField *control in self.formRepeatGroup) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:control.values];
        while (noValues < [a count]) {
            [a removeLastObject];
        }
        while (noValues > [a count]) {
            [a addObject:@""];
        }
        control.values = a;
    }
    
    UIView *v = self.superview;
    while (v && ![v isKindOfClass:[RBFormView class]]) {
        v = v.superview;
    }
    if (v) {
        [(RBFormView *)v forceLayout];
    }
}


- (void)calculate {
    for (int i = 0; i < self.textFields.count; i++) {
        RBTextField *textField = [self.textFields objectAtIndex:i];
        
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:self.calcVarFields];
        for (NSString *name in [d allKeys]) {
            id value = [d objectForKey:name];
            if ([value isKindOfClass:[RBMultiValueTextField class]]) {
                RBTextField *tf = [((RBMultiValueTextField *)value).textFields objectAtIndex:i];
                [d setValue:tf forKey:name];
            }
        }
        textField.calcVarFields = d;
        [textField calculate];
    }
}

- (void)dealloc {
    for (id tf in self.textFields) {
        [tf removeObserver:self forKeyPath:@"text"];
    }
}


#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"text"] && context == @"calculate") {
        [self calculate];
    }
    else if ([keyPath isEqual:@"text"] && context == @"calculatemulti") {
        self.text = ((UITextField *)object).text;
    }
    else if ([keyPath isEqual:@"selected"] && context == @"calculate") {
        [self calculate];
    }
    else if ([keyPath isEqual:@"text"] && context == @"repeatgroup") {
        int noFields = [((UITextField *)object).text intValue];
        if (noFields > 0) {
            [self setNumberOfValues:noFields];
        }
    }
}

@end
