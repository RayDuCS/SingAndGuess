//
//  ResultViewController.h
//  Guess
//
//  Created by Rui Du on 7/5/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "GuessGame.h"

@class Player;
@class GuessGame;

@interface ResultViewController : GameViewController<AVAudioPlayerDelegate, GuessGameSpinnerDelegate>


- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
             withGuess:(NSString *)guess
            withReward:(int)reward
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index;

@end
