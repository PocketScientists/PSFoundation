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
- (void)userDataRequestFinished:(ASIHTTPRequest *)request;
- (void)loginRequestFinished:(ASIHTTPRequest *)request;

@end


@implementation RBUserAuthentication

@synthesize delegate=delegate_;

- (RBUserAuthentication *)init {
    if (self = [super init]) {
        _authenticationInProgress = NO;
    }
    return self;
}


- (void)displayUserAuthentication{
    _authenticationInProgress = YES;
    RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
    NSTimeInterval  time_intervall = 999999;
    //1. If Username exist - also Keychain entry exists - check for Timestamp
    if(rbmusketeer.uid){
        NSDictionary *reqInfo =  [KeychainWrapper getKeychainDictionaryForUser:rbmusketeer.uid];
        if(reqInfo){
            NSDate *last_auth = [reqInfo valueForKey:@"last_auth_date"];
            rbmusketeer.lastLoginDate = last_auth;
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
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
                if (![NSUserDefaults standardUserDefaults].loggedInOnce) {
                    [self displayUserAuthentication];
                } 
                break;
            case kFalseUserAlert:
                [self displayUserAuthentication];
                break;
            case kNoConnectionAlert:
                if (![NSUserDefaults standardUserDefaults].loggedInOnce) {
                    [self displayUserAuthentication];
                } 
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
            if ([NSUserDefaults standardUserDefaults].loggedInOnce) {
                if ([delegate_ respondsToSelector:@selector(userCancelledAuthentication)]) {
                    msg = [delegate_ userCancelledAuthentication];
                    _authenticationInProgress = NO;
                }
            } else {
                msg=@"Please enter your Wiiings Data!";
            }
            break;
        case kFalseUserAlert:
            msg=@"Incorrect Wiiings Login Data entered!";
            break;
        case kNoConnectionAlert:
            if ([NSUserDefaults standardUserDefaults].loggedInOnce) {
                msg = @"You're currently using the app in offline mode.";
                [NSUserDefaults standardUserDefaults].offlineMode = YES;
                _authenticationInProgress = NO;
            } else {
                msg = @"A internet connection is needed for the initial login";
            }
            
            break;
        default:
            break;
    }
    
    if (msg.length > 0) {
        alert = [[UIAlertView alloc] initWithTitle:@"Authorize your M.I.B App"
                                           message:msg
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.tag = alertID;
        [alert show];
    }
}

-(void)getUserCredentialsForName:(NSString *)usr AndPwd:(NSString *)pwd{
    NSURL *url = [NSURL URLWithString:kReachabilitySessionXML];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req setUseCookiePersistence:NO];
    [req setUseKeychainPersistence:NO];
    [req setUseSessionPersistence:NO];
    [req setDidFinishSelector:@selector(loginRequestFinished:)];
    req.username = usr;
    req.password = pwd;
    req.delegate = self;
    [req startAsynchronous];
}

-(void)loginRequestFinished:(ASIHTTPRequest *)request{
    NSString * respStr = [[NSString alloc]  initWithData:request.responseData
                                                encoding:NSUTF8StringEncoding];
    NSString *email = [respStr substringAfterSubstring:@"<email>"];
    NSString *uid = [respStr substringAfterSubstring:@"<uid>"];
    NSString *token = [respStr substringAfterSubstring:@"<token>"];
    
    
    if([email hasSubstring:@"</email>"]){
        email = [email substringToIndex:[email rangeOfString:@"</email>"].location];
    }
    else{
        email=nil;
    }
    
    if([uid hasSubstring:@"</uid>"]){
        uid = [uid substringToIndex:[uid rangeOfString:@"</uid>"].location];
    }
    else{
        uid=nil;
    }
    
    if([token hasSubstring:@"</token>"]){
        token = [token substringToIndex:[token rangeOfString:@"</token>"].location];
    }
    else{
        token=nil;
    }
    
    if (token != nil && uid != nil && email != nil) {
        RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
        rbmusketeer.uid = uid;
        rbmusketeer.email = email;
        rbmusketeer.token=token;
        rbmusketeer.lastLoginDate = [NSDate date];
        [rbmusketeer saveEntity];
        
        [KeychainWrapper createKeychainValueWithUser:rbmusketeer.uid Token:rbmusketeer.token];
        
        if ([delegate_ respondsToSelector:@selector(setTimerTo:)]) {
            [delegate_ setTimerTo:kRBAuthorizationTimeInterval];
        }
        
        
        NSURL *url = [NSURL URLWithString:kReachabilityUserXML];
        ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
        [req setUseCookiePersistence:NO];
        [req setUseKeychainPersistence:NO];
        [req setUseSessionPersistence:NO];
        req.username = rbmusketeer.email;
        req.password = rbmusketeer.token;
        req.delegate = self;
        [req setDidFinishSelector:@selector(userDataRequestFinished:)];
        [req startAsynchronous];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self performSelector:@selector(showErrorMessage:) withObject:@"Incomplete session data received - try to re-login after restart." afterDelay:1.0f];
        });
    }
}

-(void)userDataRequestFinished:(ASIHTTPRequest *)request{
    RBMusketeer * rbmusketeer = [RBMusketeer loadEntity];
    NSArray *result;
    NSData *respData = [request responseData];
    
    //Parse XML File and get User data
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:respData
                                                           options:0 error:nil];
    if (doc != nil){
        
        for (NSString *prop in [RBMusketeer propertyNamesForMapping]){
            NSString *xpath = [NSString stringWithFormat:@"//user/%@",prop];
            result = [doc nodesForXPath:xpath error:nil];
            if(result.count > 0){   //If property exists in xml
                GDataXMLElement *elem = (GDataXMLElement *)[result firstObject];
                [rbmusketeer setValue:elem.stringValue forKey:prop];
            }
        }
        
        //Admin Data
        //Admin Email
        result = [doc nodesForXPath:@"//user/superior_items/admin_signme/email" error:nil];
        if(result.count > 0){   //If property exists in xml
            GDataXMLElement *elem = (GDataXMLElement *)[result firstObject];
            [rbmusketeer setValue:elem.stringValue forKey:@"adminemail"];
        }
        
        result = [doc nodesForXPath:@"//user/superior_items/admin_signme/firstname" error:nil];
        if(result.count > 0){   //If property exists in xml
            GDataXMLElement *elem = (GDataXMLElement *)[result firstObject];
            [rbmusketeer setValue:elem.stringValue forKey:@"adminfirstname"];
        }
        
        result = [doc nodesForXPath:@"//user/superior_items/admin_signme/lastname" error:nil];
        if(result.count > 0){   //If property exists in xml
            GDataXMLElement *elem = (GDataXMLElement *)[result firstObject];
            [rbmusketeer setValue:elem.stringValue forKey:@"adminlastname"];
        }
        
        [rbmusketeer saveEntity];
        
        //Superior groups parsing
        for(int superiorgroup=1;superiorgroup<=2;superiorgroup++){
            //Delete old Recipients
            NSArray *oldrecipients = [RBAvailableRecipients findByAttribute:@"superiorGroup" withValue:[NSNumber numberWithInt:superiorgroup]];
            for(RBAvailableRecipients *oneoldrecipient in oldrecipients){
                [oneoldrecipient deleteEntity];
            }
            [[NSManagedObjectContext defaultContext] save];
            NSString * xpath = [NSString stringWithFormat:@"//user/superior_items/superior_group_%d/person",superiorgroup];
            result = [doc nodesForXPath:xpath error:nil];
            for(GDataXMLElement *elem in result){
                RBAvailableRecipients * recip = [RBAvailableRecipients createEntity];
                recip.superiorGroup=[NSNumber numberWithInt:superiorgroup];
                for(NSString * elemname in XARRAY(@"firstname",@"lastname",@"email")){
                    NSString *elementcontent = ((GDataXMLElement*)[[elem elementsForName:elemname] firstObject]).stringValue;
                    [recip setValue:elementcontent forKey:elemname];
                }
            }
        }
        [[NSManagedObjectContext defaultContext] save];
        
    }else{
        NSLog(@"Parser Error");
    }
    
    if ([delegate_ respondsToSelector:@selector(userAuthenticated)]) {
        [NSUserDefaults standardUserDefaults].loggedInOnce = YES;
        [NSUserDefaults standardUserDefaults].offlineMode = NO;
        _authenticationInProgress = NO;
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
