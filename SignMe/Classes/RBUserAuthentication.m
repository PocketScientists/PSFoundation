//
//  RBUserAuthentication.m
//  SignMe
//
//  Created by Michael Schwarz on 20.08.12.
//
//

#import "RBUserAuthentication.h"

#define kLoginAlert 1
#define kCancelAlert 2
#define kFalseUserAlert 3
#define kNoConnectionAlert 4
#define kResponseCodeFalseUser 401
#define kResponseCodeNoConnection 0

@interface RBUserAuthentication ()

- (void)displayErrorAlert:(NSUInteger)alertID;
- (void)getUserCredentialsForName:(NSString *)username AndPwd:(NSString *)pwd;
- (void)requestFailed:(ASIHTTPRequest *)request;
-(void)requestFinished:(ASIHTTPRequest *)request;

@end


@implementation RBUserAuthentication

@synthesize delegate=delegate_;


- (void)displayUserAuthentication{
    RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
    NSTimeInterval  time_intervall = 999999;
    
    //1. If Username exist - also Keychain entry exists - check for Timestamp
    if(rbmusketeer.uid){
            NSDictionary *reqInfo =  [KeychainWrapper getKeychainDictionaryForUser:rbmusketeer.uid];
            if(reqInfo){
                NSDate *last_auth = [reqInfo valueForKey:@"last_auth_date"];
                rbmusketeer.token = [reqInfo valueForKey:@"Token"];
                [rbmusketeer saveEntity];
                time_intervall = -[last_auth timeIntervalSinceNow];
                NSLog(@"Time Intervall since last login: %f Seconds",time_intervall);
            }
    }
    

    //2. if Timestamp is too old or username does not exist - pop up Login Window
    if(time_intervall > kRBAuthorizationTimeInterval )
    {
    UIAlertView *userLogin = [[UIAlertView alloc] initWithTitle:@"Authorize your M.I.B App"
                                                        message:@"Enter your Wiiings Login Data"
                                                       delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [userLogin setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    userLogin.tag = kLoginAlert;
    [userLogin show];
    }else //3. if timestamp is Ok, set timer to remaining time
    {
        if ([delegate_ respondsToSelector:@selector(setTimerTo:)]) {
            [delegate_ setTimerTo:kRBAuthorizationTimeInterval-time_intervall];
        }
        
        if ([delegate_ respondsToSelector:@selector(userAuthenticated)]) {
            [delegate_ userAuthenticated];
        }
        
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertView Delegate
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        NSString *usr = [alertView textFieldAtIndex:0].text;
        NSString *pwd = [alertView textFieldAtIndex:1].text;
        [self getUserCredentialsForName:usr AndPwd:pwd];
 
    }else{
        switch (alertView.tag) {
            case kLoginAlert:
                [self displayErrorAlert:kCancelAlert];
                break;
            case kCancelAlert:
                [self displayUserAuthentication];
                break;
            case kFalseUserAlert:
                [self displayUserAuthentication];
                break;
            default:
                break;
        }
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)displayErrorAlert:(NSUInteger)alertID{
    NSString *msg;
    UIAlertView *alert;
    switch(alertID){
        case kCancelAlert:
            msg=@"No Wiiings Login Data entered!";
            break;
        case kFalseUserAlert:
            msg=@"Incorrect Wiiings Login Data entered!";
            break;
        case kNoConnectionAlert:
            msg=@"No Connection to Webserver!";
            break;
        default:
            break;
    }
    alert = [[UIAlertView alloc] initWithTitle:@"Authorize your M.I.B App"
                                       message:msg
                                      delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.tag = alertID;
    [alert show];
}

-(void)getUserCredentialsForName:(NSString *)usr AndPwd:(NSString *)pwd{
    NSURL *url = [NSURL URLWithString:kReachabilityUserXML];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req setUseCookiePersistence:NO];
    [req setUseKeychainPersistence:NO];
    [req setUseSessionPersistence:NO];
    req.username = usr;
    req.password = pwd;
    req.delegate = self;
    NSLog(@"request with %@ %@",usr,pwd);
    [req startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
    NSLog(@"request finished with code %d",[request responseStatusCode]);
    
    NSData *respData = [request responseData];
    NSLog(@"Response Data Length: %d",[respData length]);
    
    //Parse XML File and get User data
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:respData
                                                           options:0 error:nil];
    if (doc != nil){
        
        for (NSString *prop in [RBMusketeer propertyNamesForMapping]){
            NSString *xpath = [NSString stringWithFormat:@"//user/%@",prop];
            NSArray *result = [doc nodesForXPath:xpath error:nil];
            if(result.count > 0){   //If property exists in xml
                 GDataXMLElement *elem = (GDataXMLElement *)[result firstObject];
                 [rbmusketeer setValue:elem.stringValue forKey:prop];
            }
        }
        
        [rbmusketeer saveEntity];
        
    }else{
        NSLog(@"Parser Error");
    }
   
    NSString * respString = [[NSString alloc]  initWithData:respData
                                            encoding:NSUTF8StringEncoding];
    
    [KeychainWrapper createKeychainValueWithUser:rbmusketeer.uid Token:rbmusketeer.token andXMLString:respString];
    
    if ([delegate_ respondsToSelector:@selector(setTimerTo:)]) {
        [delegate_ setTimerTo:kRBAuthorizationTimeInterval];
    }
    
    if ([delegate_ respondsToSelector:@selector(userAuthenticated)]) {
        [delegate_ userAuthenticated];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSUInteger respCode = [request responseStatusCode];
    if(respCode == kResponseCodeFalseUser){
        [self displayErrorAlert:kFalseUserAlert];
    }else{
        [self displayErrorAlert:kNoConnectionAlert];
    }
}


@end
