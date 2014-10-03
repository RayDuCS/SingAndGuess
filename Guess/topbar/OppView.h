//
//  OppView.h
//  Guess
//
//  Created by Rui Du on 6/16/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuessGame.h"


@interface OppView : NSObject<UIActionSheetDelegate, GuessGameSpinnerDelegate>

@property (strong, nonatomic) UIView *view;

- (OppView *) initWithGame: (GuessGame *)game;

@end