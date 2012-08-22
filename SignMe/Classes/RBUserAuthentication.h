//
//  RBUserAuthentication.h
//  SignMe
//
//  Created by Michael Schwarz on 20.08.12.
//
//

#import <Foundation/Foundation.h>
#include "PSDefines.h"
#import "ASIHttpRequest.h"
#import "KeychainWrapper.h"
#import "GDataXMLNode.h"
#import "RBMusketeer+RBProperties.h"


@protocol RBUserAuthenticationDelegate <NSObject>

-(void)userAuthenticated;
-(void)setTimerTo:(NSTimeInterval)intervall;

@end

@interface RBUserAuthentication : NSObject<UIAlertViewDelegate,ASIHTTPRequestDelegate>


@property (unsafe_unretained) id <RBUserAuthenticationDelegate> delegate;


- (void)displayUserAuthentication;


@end
