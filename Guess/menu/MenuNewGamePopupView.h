//
//  MenuNewGamePopupView.h
//  Guess
//
//  Created by Rui Du on 6/29/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@protocol MenuNewGameDelegate <NSObject>

@required
- (void)reloadDataForPlayer:(Player *)player;
@end

@interface MenuNewGamePopupView : NSObject<UITextFieldDelegate,PlayerSpinnerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id delegate;

- (MenuNewGamePopupView *)initWithSuperView:(UIView *)sview
                                    andUser:(Player *)user;

@end
