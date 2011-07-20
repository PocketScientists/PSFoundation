//
//  PSAppTemplateAppDelegate.h
//  PSAppTemplate
//
//  Created by Peter Steinberger on 12.12.10.
//  Template by Peter Steinberger
//

#import "PSDefines.h"
#import "PSIncludes.h"
#import "PSWindow.h"


@interface AppDelegate : NSObject <UIApplicationDelegate, PSReachabilityAware> {
  PSWindow               *window_;
  UINavigationController *navigationController_;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

