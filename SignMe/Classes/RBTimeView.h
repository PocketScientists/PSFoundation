//
//  RBTimeView.h
//  SignMe
//
//  Created by Tretter Matthias on 20.07.11.
//  Copyright 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBTimeView : UIView

@property (nonatomic, retain) NSTimer *updateTimer;

- (void)startUpdating;
- (void)stopUpdating;

@end
