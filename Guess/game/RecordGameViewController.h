//
//  RecordGameViewController.h
//  Guess
//
//  Created by Rui Du on 6/15/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>
#import "GameViewController.h"
#import "GuessGame.h"
//@class GameViewController;

@interface RecordGameViewController : GameViewController<AVAudioPlayerDelegate, GuessGameSpinnerDelegate>

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index;

@end
