//
//  LoginViewController.h
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "HttpConn.h"
#import "Player.h"
#import "TutorialView.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate,PlayerSpinnerDelegate, UIGestureRecognizerDelegate, TutorialViewDelegate>
@end
