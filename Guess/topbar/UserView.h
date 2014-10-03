//
//  UserView.h
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

#define FRAME_WIDTH 140
#define FRAME_HEIGHT 80
@interface UserView : NSObject<UIActionSheetDelegate, PlayerSpinnerDelegate>

@property (strong, nonatomic) UIView *view;

- (UserView *)initWithPlayer:(Player *)player;
- (void)reloadWithPlayer:(Player *)player;
- (void)animateGoldImage;
- (void)tryAnimateLevelUp:(int)expGain; //gain exp, animate leveling if needed.

@end
