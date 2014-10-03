//
//  GuessAppDelegate.h
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuessViewController.h"

@class MenuViewController;
@class SinaWeibo;

@interface GuessAppDelegate : UIResponder <UIApplicationDelegate>
{
    SinaWeibo *sinaweibo;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MenuViewController *viewController;
@property (readonly, nonatomic) SinaWeibo *sinaweibo;

//@property (strong, nonatomic) UIImageView *splashView;
//@property (strong, nonatomic) GuessViewController * viewController;
/*
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
*/

@end
