//
//  PreRecordGameViewController.h
//  Guess
//
//  Created by Rui Du on 9/9/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "GuessGame.h"
#import "GADBannerView.h"

typedef enum
{
    GAME_TABLE_CELL_TAG_IMAGE = 2001,
    GAME_TABLE_CELL_TAG_CATEGORY_LABEL = 2002,
    GAME_TABLE_CELL_TAG_LOCK = 2003,
    GAME_TABLE_CELL_TAG_BUTTON = 2004,
}GameTableCellTag;

typedef enum
{
    GAME_THEME_ID_RANDOM                = 0,
    GAME_THEME_ID_QING_GAN_XING_WEI     = 1,
    GAME_THEME_ID_QING_JING_ZAI_XIAN    = 2,
    GAME_THEME_ID_DONG_MAN_YOU_XI       = 3,
    GAME_THEME_ID_DA_ZI_RAN             = 4,
    GAME_THEME_ID_GE_ZHONG_DAO_JU       = 5,
    GAME_THEME_ID_REN_WU_MU_FANG_XIU    = 6,
    GAME_THEME_ID_YIN_YUE               = 7,
    GAME_THEME_ID_DIAN_YING_DIAN_SHI    = 8,
    GAME_THEME_ID_YIN_YUE_VIP           = 9,
}GameThemeID;

@interface PreRecordGameViewController : GameViewController<GuessGameSpinnerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    GADBannerView *bannerView_;
}

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index;

@end
