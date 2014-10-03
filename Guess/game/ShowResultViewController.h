//
//  ShowResultViewController.h
//  Guess
//
//  Created by Rui Du on 10/17/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "GameViewController.h"
#import "GuessGame.h"

@class Player;

@interface ShowResultViewController : GameViewController<GuessGameSpinnerDelegate>

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index;

@end
