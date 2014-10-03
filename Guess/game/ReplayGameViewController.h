//
//  ReplayGameViewController.h
//  Guess
//
//  Created by Rui Du on 11/24/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "GameViewController.h"

@interface ReplayGameViewController : GameViewController
- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index;
@end
