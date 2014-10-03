//
//  MenuSliderShopView.h
//  Guess
//
//  Created by Rui Du on 6/29/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuSliderView.h"
#import "Player.h"
#import "GuessIAP.h"
@class Inventory;
@class UserView;

@protocol MenuSliderShopViewDelegate <NSObject, IAPSpinnerDelegate>
- (Player *)getUser;
- (UIActivityIndicatorView *)getSpinner;
- (UIView *)getShade;
- (UIView *)getView;
- (UserView *)getUserView;
- (void)animateVIP;
@required


@end

typedef enum
{
    TABLE_VIEW_TYPE_ITEM,
    TABLE_VIEW_TYPE_GOLD,
    TABLE_VIEW_TYPE_INVENTORY
}TableViewType;

typedef enum
{
    ITEM_TAG_BUTTON = 1001,
    ITEM_TAG_TOP_IMAGE_BG = 1002,
    ITEM_TAG_TEXT = 1003,
    ITEM_TAG_ITEM_IMAGE = 1004,
    ITEM_TAG_AMOUNT_LABEL = 1005,
    ITEM_TAG_PRICE_LABEL = 1006,
    ITEM_TAG_GOLD_IMAGE = 1007
}ItemTag;

typedef enum
{
    GOLD_TAG_BUTTON = 1001,
    GOLD_TAG_TOP_IMAGE_BG = 1002,
    GOLD_TAG_TEXT = 1003,
    GOLD_TAG_ITEM_IMAGE = 1004,
    GOLD_TAG_AMOUNT_LABEL = 1005,
    GOLD_TAG_PRICE_LABEL = 1006,
    GOLD_TAG_PRICE_LABEL_2 = 1007,
    GOLD_TAG_PRICE_LABEL_3 = 1008
}GoldTag;

typedef enum
{
    INVENTORY_TAG_TOP_IMAGE_BG = 1001,
    INVENTORY_TAG_ITEM_IMAGE = 1002,
    INVENTORY_TAG_AMOUNT_LABEL = 1003,
    INVENTORY_TAG_TEXT = 1004,
    INVENTORY_TAG_TOP_LABEL = 1005,
    INVENTORY_TAG_BUTTON = 1006,
    INVENTORY_TAG_GOLD_LABEL = 1007,
    INVENTORY_TAG_KEY_LABEL = 1008,
    INVENTORY_TAG_VIP_LABEL = 1009,
    INVENTORY_TAG_GOLD_IMAGE = 1010,
    INVENTORY_TAG_KEY_IMAGE = 1011,
    INVENTORY_TAG_VIP_IMAGE = 1012,
    INVENTORY_TAG_ITEM_BG = 1013,
    INVENTORY_TAG_REWARD_HELP_BTN = 1014,
}InventoryTag;

@interface MenuSliderShopView : NSObject<UITableViewDelegate, UITableViewDataSource, PlayerSpinnerDelegate>

@property (strong, nonatomic) UIView *view;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) Player *user;

- (MenuSliderShopView *)initWithSender:(UIButton *)sender
                          withDelegate:(id)delegate
                                   tag:(ShopTag)shopTag;

@end
