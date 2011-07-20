//
//  PSBaseViewController.h
//  PSAppTemplate
//
//  Created by Tretter Matthias on 25.06.11.
//  Copyright 2011 @myell0w. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSIncludes.h"
#import "RBTimeView.h"

@interface PSBaseViewController : UIViewController <PSReachabilityAware> 

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) RBTimeView *timeView;

@end
