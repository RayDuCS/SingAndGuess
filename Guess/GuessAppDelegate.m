//
//  GuessAppDelegate.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "SinaWeibo.h"

#import "GuessAppDelegate.h"
#import "MenuViewController.h"
#import "GuessIAP.h"

@implementation GuessAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize sinaweibo;

//@synthesize splashView = _splashView;
//@synthesize viewController = _viewController;
/*
-(void)removeSplash{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.window cache:YES];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [self.splashView removeFromSuperview];
    [UIView commitAnimations];
    [self.window addSubview:self.viewController.view];
}
*/

/*
-(void) applicationDidFinishLaunching:(UIApplication *)application
{
    [_window addSubview:_viewController.view];
    [_window makeKeyAndVisible];
    
    // Make this interesting.
    _splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
    _splashView.image = [UIImage imageNamed:@"welcome.jpg"];
    [_window addSubview:_splashView];
    [_window bringSubviewToFront:_splashView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_window cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    _splashView.alpha = 0.5;
    _splashView.frame = CGRectMake(-60, -85, 440, 635);
    [UIView commitAnimations];
}
 */
#define kAppKey             @"1239660345"
#define kAppSecret          @"f3066593adcebd4a2e82bb4ace1b1bfc"
#define kAppRedirectURI     @"https://api.weibo.com/oauth2/default.html"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //For push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:_viewController];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
    
    [GuessIAP sharedInstance];
    [[GuessIAP sharedInstance] initializeHttp];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	//NSString* oldToken = [dataModel deviceToken];
    
	NSString* token = [deviceToken description];
	token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:@"token"];
    [defaults synchronize];
	NSLog(@"My token is: %@", token);
    
    //NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];
    //NSLog(@"My token is: %@", [defaults1 objectForKey:@"token"]);
    
    
	//[dataModel setDeviceToken:newToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self.sinaweibo handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return [self.sinaweibo handleOpenURL:url];
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[url absoluteString] forKey:@"sinaUrl"];
    [defaults synchronize];
   //return [self.viewController.sinaweibo handleOpenURL:url];
    //return [self.sinaweibo handleOpenURL:url];
     */
}

@end
