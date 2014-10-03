//
//  MenuViewController.h
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>
#import <QuartzCore/QuartzCore.h>
#import "MenuSliderView.h"
#import "MenuSliderSettingView.h"
#import "MenuSliderShopView.h"
#import "MenuNewGamePopupView.h"
#import "GuessGame.h"
#import "Player.h"
#import "Inventory.h"
#import "GADBannerView.h"
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"
#import "TutorialView.h"

#define kAppKey             @"1239660345"
#define kAppSecret          @"f3066593adcebd4a2e82bb4ace1b1bfc"
#define kAppRedirectURI     @"https://api.weibo.com/oauth2/default.html"

@class SinaWeibo;

@interface MenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MenuSliderViewDelegate, MenuSliderSettingsViewDelegate, MenuNewGameDelegate, GuessGameSpinnerDelegate, PlayerSpinnerDelegate, InventorySpinnerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate, UIGestureRecognizerDelegate, MenuSliderShopViewDelegate, SinaWeiboDelegate, SinaWeiboRequestDelegate, TutorialViewDelegate, UIAlertViewDelegate>
{
    GADBannerView *bannerView_;
    NSString *postImageStatusText;
    //SinaWeibo *sinaWeibo;
}

@property (readonly, nonatomic) SinaWeibo *sinaweibo;

typedef enum
{
    TABLE_CELL_TAG_IMAGE = 1001,
    TABLE_CELL_TAG_OPP_NAME = 1002,
    TABLE_CELL_TAG_OPP_LEVEL = 1003,
    TABLE_CELL_TAG_OPP_SEX = 1004,
    TABLE_CELL_TAG_ROUND = 1005,
    TABLE_CELL_TAG_PLAY_BTN = 1006,
    TABLE_CELL_TAG_DELETE_BTN = 1007,
    TABLE_CELL_TAG_BAN_BTN = 1008,
    TABLE_CELL_TAG_REFRESH_IMAGE_BTN = 1009,
    TABLE_CELL_TAG_LV_IMAGE = 1010,
    TABLE_CELL_TAG_SNOOZE_BTN = 1011,
    TABLE_CELL_TAG_VIP_IMAGE = 1012,
    TABLE_CELL_TAG_BG_IMAGE = 1013,
}TableCellTag;

typedef enum
{
    TABLE_STATE_NORMAL = 100,
    TABLE_STATE_REFRESH_PULLING = 101,
    TABLE_STATE_REFRESH_NORMAL = 102,
    TABLE_STATE_REFRESH_LOADING = 103
}TableState;

- (void)loadWithRegisteredUser:(Player *)registeredPlayer
                      userInfo:(NSDictionary *)userInfo
                 usingPopIndex:(int)index;
- (void)reloadData;
- (void)reloadDataForPlayer:(Player *)player;
- (void)reloadUserInfo;
- (void)purchaseItemWithGold:(PurchaseItemType)type
                      amount:(int)amount
                       gold:(int)gold;

+ (UIImage *)getLevelImageForLevel:(int)level;

@end
