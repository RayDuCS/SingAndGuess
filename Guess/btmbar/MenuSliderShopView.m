//
//  MenuSliderShopView.m
//  Guess
//
//  Created by Rui Du on 6/29/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "MenuSliderShopView.h"
#import "Player.h"
#import "Inventory.h"
#import "UICustomColor.h"
#import "UICustomFont.h"
#import "UIViewCustomAnimation.h"
#import "MenuViewController.h"
#import "UserView.h"
#import "GuessIAP.h"

@interface MenuSliderShopView()

@property (strong, nonatomic) UIButton *itemShopBtn;
@property (strong, nonatomic) UIButton *goldShopBtn;
@property (strong, nonatomic) UIButton *userItemBtn;
@property (strong, nonatomic) UIView *displayView;
@property (strong, nonatomic) UITableView *itemShopTableView;
@property (strong, nonatomic) UITableView *goldShopTableView;
@property (strong, nonatomic) UITableView *inventoryTableView;
@property (nonatomic) TableViewType currentTableViewType;
@property (nonatomic) int itemTableExpandedRow;
@property (nonatomic) int goldTableExpandedRow;
@property (nonatomic) int inventoryTableExpandedRow;
@property (nonatomic) BOOL inventoryTableExpandedReward;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation MenuSliderShopView

@synthesize itemShopBtn = _itemShopBtn;
@synthesize goldShopBtn = _goldShopBtn;
@synthesize userItemBtn = _userItemBtn;
@synthesize displayView = _displayView;
@synthesize view = _view;
@synthesize delegate = _delegate;
@synthesize user = _user;
@synthesize itemShopTableView = _itemShopTableView;
@synthesize itemTableExpandedRow = _itemTableExpandedRow;
@synthesize goldShopTableView = _goldShopTableView;
@synthesize goldTableExpandedRow = _goldTableExpandedRow;
@synthesize inventoryTableView = _inventoryTableView;
@synthesize inventoryTableExpandedRow = _inventoryTableExpandedRow;
@synthesize inventoryTableExpandedReward = _inventoryTableExpandedReward;
@synthesize currentTableViewType = _currentTableViewType;

@synthesize products = _products;
@synthesize editableItems = _editableItems;
@synthesize spinnerTimer = _spinnerTimer;

- (Player *)user
{
    //if (_user) return _user;
    
    _user = [self.delegate getUser];
    return _user;
}

- (MenuSliderShopView *)initWithSender:(UIButton *)sender withDelegate:(id)delegate tag:(ShopTag)shopTag
{
    self = [super init];
    
    [self setView:nil];
    self.view = [[UIView alloc] initWithFrame:CGRectMake(20, 80, 280, 378)];
    self.delegate = delegate;    
    UIImageView *titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_daoju.png"]];
    titleImgView.frame = CGRectMake(89.7, 5, 93.57, 35);
    
    [self.user retrieveInfo];
    
    self.itemShopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.itemShopBtn setTitle:@"道具商店" forState:UIControlStateNormal];
    [self.itemShopBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
    self.itemShopBtn.frame = CGRectMake(2, 50, 85, 37);
    [self.itemShopBtn setImage:[UIImage imageNamed:@"popup_shop_btn1_1"] forState:UIControlStateNormal];
    [self.itemShopBtn setImage:[UIImage imageNamed:@"popup_shop_btn1_2"] forState:UIControlStateSelected];
    self.itemShopBtn.backgroundColor = [UIColor clearColor];
    [self.itemShopBtn addTarget:self action:@selector(itemShopPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.goldShopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.goldShopBtn setTitle:@"金币商店" forState:UIControlStateNormal];
    [self.goldShopBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
    self.goldShopBtn.frame = CGRectMake(88, 50, 85, 37);
    [self.goldShopBtn setImage:[UIImage imageNamed:@"popup_shop_btn2_1"] forState:UIControlStateNormal];
    [self.goldShopBtn setImage:[UIImage imageNamed:@"popup_shop_btn2_2"] forState:UIControlStateSelected];
    self.goldShopBtn.backgroundColor = [UIColor clearColor];
    [self.goldShopBtn addTarget:self action:@selector(goldShopPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.userItemBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.userItemBtn setTitle:@"我的道具" forState:UIControlStateNormal];
    [self.userItemBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
    self.userItemBtn.frame = CGRectMake(174, 50, 85, 37);
    [self.userItemBtn setImage:[UIImage imageNamed:@"popup_shop_btn3_1"] forState:UIControlStateNormal];
    [self.userItemBtn setImage:[UIImage imageNamed:@"popup_shop_btn3_2"] forState:UIControlStateSelected];
    self.userItemBtn.backgroundColor = [UIColor clearColor];
    [self.userItemBtn addTarget:self action:@selector(userItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setDisplayView:nil];
    self.displayView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 242, 263)];//(10, 95, 242, 263)
    self.displayView.backgroundColor = [UIColor clearColor];
    
    self.itemTableExpandedRow = -1;
    self.inventoryTableExpandedRow = -1;
    self.goldTableExpandedRow = -1;
    self.inventoryTableExpandedReward = NO;
    
    [self.view addSubview:titleImgView];
    [self.view addSubview:self.itemShopBtn];
    [self.view addSubview:self.goldShopBtn];
    [self.view addSubview:self.userItemBtn];
    [self.view addSubview:self.displayView];
    
    
    NSMutableArray *editableItemsArray = [[NSMutableArray alloc] init];
    [editableItemsArray addObject:self.itemShopBtn];
    [editableItemsArray addObject:self.goldShopBtn];
    [editableItemsArray addObject:self.userItemBtn];
    
    self.editableItems = [editableItemsArray mutableCopy];
    
    switch (shopTag) {
        case SHOP_TAG_GOLD:
            [self goldShopPressed:sender];
            break;
        case SHOP_TAG_INVENTORY:
            [self userItemPressed:sender];
            break;
        case SHOP_TAG_ITEM:
            [self itemShopPressed:sender];
            break;
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.currentTableViewType) {
        case TABLE_VIEW_TYPE_ITEM:
            return 3; // TODO VIP was 6
        case TABLE_VIEW_TYPE_GOLD:
            return 3;
        case TABLE_VIEW_TYPE_INVENTORY:
            if (section == 0) return 3;
            return 1;
    }
}

- (void)spinnerTimeout
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:[self.delegate getSpinner] andEditableItems:self.editableItems andShadingView:[self.delegate getShade]];
    //[UIViewCustomAnimation showAlert:@"连接超时"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.currentTableViewType) {
        case TABLE_VIEW_TYPE_ITEM:
            return 1;
        case TABLE_VIEW_TYPE_GOLD:
            return 1;
        case TABLE_VIEW_TYPE_INVENTORY:
            return 2;
    }
}

- (NSDictionary *)configureItemTableCellForRow:(int)row
{
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    if (row == 0) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_1.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"popup_table_icon_hammer.png"] forKey:@"itemImage"];
        [mDict setValue:@"10" forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"%6d", 249] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_WHEAT2] forKey:@"textColor"];
        [mDict setValue:@"音锤：\n一把做工精美的小锤子，可以快速准确地击碎词条。请放心，它应该不会损坏你的屏幕。\n使用方法：\n- 出题时，使用音锤击碎所有题目，重新选择词库\n- 答题时，使用音锤击碎两个错误选项（不可重复使用）" forKey:@"text"];
    } else if (row == 1) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_1.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"popup_table_icon_hammer.png"] forKey:@"itemImage"];
        [mDict setValue:@"100" forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"%6d", 1999] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_PINK1] forKey:@"textColor"];
        [mDict setValue:@"音锤：\n一把做工精美的小锤子，可以快速准确地击碎词条。请放心，它应该不会损坏你的屏幕。\n使用方法：\n- 出题时，使用音锤击碎所有题目，重新选择词库\n- 答题时，使用音锤击碎两个错误选项（不可重复使用）" forKey:@"text"];
    } else if (row == 2) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_4.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"popup_table_icon_key.png"] forKey:@"itemImage"];
        [mDict setValue:@"1" forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"%6d", 499] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_DARKSEAGREEN1] forKey:@"textColor"];
        [mDict setValue:@"音钥匙：\n一把银质的钥匙，可以解开被锁住的词库。我敢打赌制作者忘了怎么写“银”字，所以找了个谐音。。。\n使用方法：\n- 选择词库种类时，点击被银锁住的词库解锁" forKey:@"text"];
    } else if (row == 3) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_2.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"popup_table_icon_gift_1.png"] forKey:@"itemImage"];
        [mDict setValue:@"7天" forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"%6d", 1299] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_GRAY81] forKey:@"textColor"];
        [mDict setValue:@"VIP大礼包：\n一个小巧可爱的包裹，却储存了神秘的力量。打开时100%保证可能不会有危险~推荐好友一起来玩可以免费获得哦！\n使用效果：\n- 激活以后，你的账户将拥有VIP的印记和背景（其他玩家可见噢），不再被广告条打扰，解除游戏数量限制，增加金币和经验奖励，获赠精美壁纸，最重要的是专享VIP词库！心动了吗？快来购买吧！" forKey:@"text"];
    } else if (row == 4) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_2.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"popup_table_icon_gift_1.png"] forKey:@"itemImage"];
        [mDict setValue:@"30天" forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"%6d", 2999] forKey:@"price"];
        //[mDict setValue:[NSString stringWithFormat:@"$    0.99"] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_LIGHT_GOLDENROD] forKey:@"textColor"];
        [mDict setValue:@"VIP大礼包：\n一个小巧可爱的包裹，却储存了神秘的力量。打开时100%保证可能不会有危险~推荐好友一起来玩可以免费获得哦！\n使用效果：\n- 激活以后，你的账户将拥有VIP的印记和背景（其他玩家可见噢），不再被广告条打扰，解除游戏数量限制，增加金币和经验奖励，获赠精美壁纸，最重要的是专享VIP词库！心动了吗？快来购买吧！" forKey:@"text"];
    } else if (row == 5) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_3.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"popup_table_icon_gift_2.png"] forKey:@"itemImage"];
        [mDict setValue:@"一辈子" forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"%6d", 12999] forKey:@"price"];
        //[mDict setValue:[NSString stringWithFormat:@"$    4.99"] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_LIGHT_GOLDENROD] forKey:@"textColor"];
        [mDict setValue:@"VIP大礼包：\n一个小巧可爱的包裹，却储存了神秘的力量。打开时100%保证可能不会有危险~推荐好友一起来玩可以免费获得哦！\n使用效果：\n- 激活以后，你的账户将拥有VIP的印记和背景（其他玩家可见噢），不再被广告条打扰，解除游戏数量限制，增加金币和经验奖励，获赠精美壁纸，最重要的是专享VIP词库！心动了吗？快来购买吧！" forKey:@"text"];
    }
    
    return [mDict copy];
}

- (UITableViewCell *)itemTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"itemShopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    NSDictionary *cfgDict = [self configureItemTableCellForRow:indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *bgView = (UIImageView *)[cell viewWithTag:ITEM_TAG_TOP_IMAGE_BG];
    if (!bgView) {
        bgView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"bgImage"]];
        //bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[cfgDict objectForKey:@"bgImage"]]];
        bgView.frame = CGRectMake(0, 0, 242.75, 48.5);
        bgView.tag = ITEM_TAG_TOP_IMAGE_BG;
        [cell addSubview:bgView];
    }
    
    bgView.image = [cfgDict objectForKey:@"bgImage"];
    
    UIImageView *itemImageView = (UIImageView *)[cell viewWithTag:ITEM_TAG_ITEM_IMAGE];
    if (!itemImageView) {
        itemImageView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"itemImage"]];
        itemImageView.frame = CGRectMake(10, 2, 45, 45);
        itemImageView.tag = ITEM_TAG_ITEM_IMAGE;
        itemImageView.backgroundColor = [UIColor clearColor];
        [cell addSubview:itemImageView];
    }
    
    itemImageView.image = [cfgDict objectForKey:@"itemImage"];
    
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:ITEM_TAG_AMOUNT_LABEL];
    if (!amountLabel) {
        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 60, 20)];
        amountLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        amountLabel.textColor = [UIColor blackColor];
        amountLabel.tag = ITEM_TAG_AMOUNT_LABEL;
        amountLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:amountLabel];
    }
    
    amountLabel.text = [cfgDict objectForKey:@"amount"];
    
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:ITEM_TAG_PRICE_LABEL];
    if (!priceLabel) {
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 14, 80, 20)];
        priceLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        priceLabel.textAlignment = UITextAlignmentRight;
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.tag = ITEM_TAG_PRICE_LABEL;
        priceLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:priceLabel];
    }
    
    priceLabel.text = [cfgDict objectForKey:@"price"];
        
    
    UIButton *buyItemBtn = (UIButton *)[cell viewWithTag:ITEM_TAG_BUTTON];
    if (!buyItemBtn) {
        buyItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyItemBtn.frame = CGRectMake(83.5, 132.5, 75, 27.5);
        [buyItemBtn setBackgroundImage:[UIImage imageNamed:@"icon_bg_blue_1"] forState:UIControlStateNormal];
        [buyItemBtn setTitle:@"购买" forState:UIControlStateNormal];
        buyItemBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:20];
        buyItemBtn.tag = ITEM_TAG_BUTTON;
        buyItemBtn.alpha = 0;
        [buyItemBtn addTarget:self action:@selector(purchaseItem:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buyItemBtn];
    }
    
    UITextView *textView = (UITextView *)[cell viewWithTag:ITEM_TAG_TEXT];
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 48.5, 232, 84)];
        textView.text = [cfgDict objectForKey:@"text"];
        textView.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
        textView.textColor = [UIColor whiteColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
        textView.alpha = 0;
        textView.tag = ITEM_TAG_TEXT;
        
        [cell addSubview:textView];
    }
    
    UIImageView *goldImageView = (UIImageView *)[cell viewWithTag:ITEM_TAG_GOLD_IMAGE];
    if (!goldImageView) {
        goldImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gold.png"]];
        goldImageView.frame = CGRectMake(140, 9, 30, 30);
        goldImageView.tag = ITEM_TAG_GOLD_IMAGE;
        goldImageView.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:goldImageView];
    }
    
    textView.text = [cfgDict objectForKey:@"text"];
    textView.textColor = [cfgDict objectForKey:@"textColor"];
    
    if (indexPath.row == self.itemTableExpandedRow) {
        buyItemBtn.alpha = 1;
        textView.alpha = 1;
    } else {
        buyItemBtn.alpha = 0;
        textView.alpha = 0;
    }
    
    /*
    if (indexPath.row == 4 || indexPath.row == 5) goldImageView.alpha = 0;
    else goldImageView.alpha = 1;
    */
     
    return cell;
}

- (IBAction)purchaseItem:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *path = [self.itemShopTableView indexPathForCell:cell];
    
    int amount = 0;
    PurchaseItemType type = PURCHASE_ITEM_TYPE_NONE;
    int gold = 0;
    
    if (path.row == 0) {
        amount = 10;
        gold = 249;
        type = PURCHASE_ITEM_TYPE_HAMMER;
    }
    else if (path.row == 1) {
        amount = 100;
        gold = 1999;
        type = PURCHASE_ITEM_TYPE_HAMMER;
    }
    else if (path.row == 2) {
        amount = 1;
        gold = 499;
        type = PURCHASE_ITEM_TYPE_KEY;
    }
    else if (path.row == 3) {
        if (self.user.inventory.dayOfVIP == -1) {
            [UIViewCustomAnimation showAlert:@"你已经是永久VIP了!"];
            return;
        }
        
        amount = 7;
        gold = 1299;
        type = PURCHASE_ITEM_TYPE_VIP;
    }
    else if (path.row == 4) {
        if (self.user.inventory.dayOfVIP == -1) {
            [UIViewCustomAnimation showAlert:@"你已经是永久VIP了!"];
            return;
        }
        
        amount = 30;
        gold = 2999;
        type = PURCHASE_ITEM_TYPE_VIP;
    }
    else {
        if (self.user.inventory.dayOfVIP == -1) {
            [UIViewCustomAnimation showAlert:@"你已经是永久VIP了!"];
            return;
        }
        
        amount = -1;
        gold = 12999;
        type = PURCHASE_ITEM_TYPE_VIP;
        /*
        if (!self.products) {
            [self getIAPProductsAndBuy:YES itemIndex:path.row-1];
            return;
        }
        
        
        amount = 7;
        gold = 2499;
        type = PURCHASE_ITEM_TYPE_VIP;
        GuessIAP *iap = [GuessIAP sharedInstance];
        iap.delegate = self;
        iap.userID = self.user.ID;
        [iap buyProduct:[self.products objectAtIndex:path.row-1]];
        return;
         */
    }
    
    if (self.user.gold < gold) {
        [UIViewCustomAnimation showAlert:@"金币不够，去金币商店逛逛吧"];
        return;
    }
    
    [self.delegate purchaseItemWithGold:type amount:amount gold:gold];
}

- (NSDictionary *)configureGoldTableCellForRow:(int)row
{
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    if (row == 0) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_5.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"gold.png"] forKey:@"itemImage"];
        [mDict setValue:[NSString stringWithFormat:@"%5d", 2500] forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"0"] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_WHEAT2] forKey:@"textColor"];
        [mDict setValue:@"一小撮金币，勉强够用。" forKey:@"text"];
    }
    else if (row == 1) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_5.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"gold.png"] forKey:@"itemImage"];
        [mDict setValue:[NSString stringWithFormat:@"%5d", 6250] forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"1"] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_PINK1] forKey:@"textColor"];
        [mDict setValue:@"一大堆金币，经济实惠。" forKey:@"text"];
    }
    else if (row == 2) {
        [mDict setValue:[UIImage imageNamed:@"popup_table_bg_5.png"] forKey:@"bgImage"];
        [mDict setValue:[UIImage imageNamed:@"gold.png"] forKey:@"itemImage"];
        [mDict setValue:[NSString stringWithFormat:@"%5d", 15500] forKey:@"amount"];
        [mDict setValue:[NSString stringWithFormat:@"3"] forKey:@"price"];
        [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
        //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_DARKSEAGREEN1] forKey:@"textColor"];
        [mDict setValue:@"好多好多金币啊！性价比超高！" forKey:@"text"];
    }
    
    return [mDict copy];
}

- (UITableViewCell *)goldTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"goldShopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *cfgDict = [self configureGoldTableCellForRow:indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *bgView = (UIImageView *)[cell viewWithTag:GOLD_TAG_TOP_IMAGE_BG];
    if (!bgView) {
        bgView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"bgImage"]];
        //bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[cfgDict objectForKey:@"bgImage"]]];
        bgView.frame = CGRectMake(0, 0, 242.75, 48.5);
        bgView.tag = GOLD_TAG_TOP_IMAGE_BG;
        [cell addSubview:bgView];
    }
    
    bgView.image = [cfgDict objectForKey:@"bgImage"];
    
    UIImageView *itemImageView = (UIImageView *)[cell viewWithTag:GOLD_TAG_ITEM_IMAGE];
    if (!itemImageView) {
        itemImageView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"itemImage"]];
        itemImageView.frame = CGRectMake(10, 9, 30, 30);
        itemImageView.tag = GOLD_TAG_ITEM_IMAGE;
        itemImageView.backgroundColor = [UIColor clearColor];
        [cell addSubview:itemImageView];
    }
    
    itemImageView.image = [cfgDict objectForKey:@"itemImage"];
    
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:GOLD_TAG_AMOUNT_LABEL];
    if (!amountLabel) {
        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 80, 20)];
        amountLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        amountLabel.textColor = [UIColor blackColor];
        amountLabel.tag = GOLD_TAG_AMOUNT_LABEL;
        amountLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:amountLabel];
    }
    
    amountLabel.text = [cfgDict objectForKey:@"amount"];
    
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:GOLD_TAG_PRICE_LABEL];
    if (!priceLabel) {
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 14, 25, 20)];
        priceLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        priceLabel.textAlignment = UITextAlignmentRight;
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.tag = GOLD_TAG_PRICE_LABEL;
        priceLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:priceLabel];
    }
    
    priceLabel.text = [cfgDict objectForKey:@"price"];
    
    UILabel *priceLabel_2 = (UILabel *)[cell viewWithTag:GOLD_TAG_PRICE_LABEL_2];
    if (!priceLabel_2) {
        priceLabel_2 = [[UILabel alloc] initWithFrame:CGRectMake(170, 14, 10, 20)];
        priceLabel_2.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        priceLabel_2.textAlignment = UITextAlignmentLeft;
        priceLabel_2.textColor = [UIColor blackColor];
        priceLabel_2.tag = GOLD_TAG_PRICE_LABEL_2;
        priceLabel_2.backgroundColor = [UIColor clearColor];
        priceLabel_2.text = @"$";
        [cell addSubview:priceLabel_2];
    }
    
    UILabel *priceLabel_3 = (UILabel *)[cell viewWithTag:GOLD_TAG_PRICE_LABEL_3];
    if (!priceLabel_3) {
        priceLabel_3 = [[UILabel alloc] initWithFrame:CGRectMake(205, 14, 55, 20)];
        priceLabel_3.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        priceLabel_3.textAlignment = UITextAlignmentLeft;
        priceLabel_3.textColor = [UIColor blackColor];
        priceLabel_3.tag = GOLD_TAG_PRICE_LABEL_3;
        priceLabel_3.backgroundColor = [UIColor clearColor];
        priceLabel_3.text = @".99";
        [cell addSubview:priceLabel_3];
    }
    
    UIButton *buyItemBtn = (UIButton *)[cell viewWithTag:GOLD_TAG_BUTTON];
    if (!buyItemBtn) {
        buyItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyItemBtn.frame = CGRectMake(83.5, 80, 75, 27.5);
        [buyItemBtn setBackgroundImage:[UIImage imageNamed:@"icon_bg_blue_1"] forState:UIControlStateNormal];
        [buyItemBtn setTitle:@"购买" forState:UIControlStateNormal];
        buyItemBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:20];
        buyItemBtn.tag = GOLD_TAG_BUTTON;
        buyItemBtn.alpha = 0;
        [buyItemBtn addTarget:self action:@selector(purchaseGold:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buyItemBtn];
    }
    
    UITextView *textView = (UITextView *)[cell viewWithTag:GOLD_TAG_TEXT];
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 48.5, 232, 30)];
        textView.text = [cfgDict objectForKey:@"text"];
        textView.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
        textView.textColor = [UIColor whiteColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
        textView.alpha = 0;
        textView.tag = GOLD_TAG_TEXT;
        
        [cell addSubview:textView];
    }
    
    textView.text = [cfgDict objectForKey:@"text"];
    textView.textColor = [cfgDict objectForKey:@"textColor"];
    
    if (indexPath.row == self.goldTableExpandedRow) {
        buyItemBtn.alpha = 1;
        textView.alpha = 1;
    } else {
        buyItemBtn.alpha = 0;
        textView.alpha = 0;
    }
    
    return cell;
}

- (void)getIAPProductsAndBuy:(BOOL)buy
                   itemIndex:(int)index
{
    if (self.products) return;
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:[self.delegate getSpinner] andEditableItems:self.editableItems andShadingView:[self.delegate getShade]];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    
    [[GuessIAP sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.products = products;
            
            [UIViewCustomAnimation stopSpinAnimationUsingSpinner:[self.delegate getSpinner] andEditableItems:self.editableItems andShadingView:[self.delegate getShade]];
            [self.spinnerTimer invalidate];
            for (SKProduct *item in self.products) {
                NSLog(@"%@/%@", item.localizedTitle, item.localizedDescription);
            }
            
            if (buy) {
                GuessIAP *iap = [GuessIAP sharedInstance];
                iap.delegate = self;
                iap.userID = self.user.ID;
                [iap buyProduct:[self.products objectAtIndex:index]];
            }
        }
    }];
}

- (IBAction)purchaseGold:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *path = [self.goldShopTableView indexPathForCell:cell];
    
    if (!self.products) {
        [self getIAPProductsAndBuy:YES itemIndex:path.row];
        return;
    }
    
    GuessIAP *iap = [GuessIAP sharedInstance];
    iap.delegate = self;
    iap.userID = self.user.ID;
    [iap buyProduct:[self.products objectAtIndex:path.row]];
}

- (NSDictionary *)configureInventoryTableCellForIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    if (section == 0) {
        if (row == 0) {
            [mDict setValue:[UIImage imageNamed:@"popup_table_bg_1.png"] forKey:@"bgImage"];
            [mDict setValue:[UIImage imageNamed:@"popup_table_icon_hammer.png"] forKey:@"itemImage"];
            [mDict setValue:[NSString stringWithFormat:@"剩余%4d", self.user.inventory.numOfHammers] forKey:@"amount"];
            [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
            //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_WHEAT2] forKey:@"textColor"];
            [mDict setValue:@"音锤：\n一把做工精美的小锤子，可以快速准确地击碎词条。请放心，它应该不会损坏你的屏幕。\n使用方法：\n- 出题时，使用音锤击碎所有题目，重新选择词库\n- 答题时，使用音锤击碎两个错误选项（不可重复使用）" forKey:@"text"];
        } else if (row == 1) {
            [mDict setValue:[UIImage imageNamed:@"popup_table_bg_4.png"] forKey:@"bgImage"];
            [mDict setValue:[UIImage imageNamed:@"popup_table_icon_key.png"] forKey:@"itemImage"];
            [mDict setValue:[NSString stringWithFormat:@"剩余%4d", self.user.inventory.numOfKeys] forKey:@"amount"];
            [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
            //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_PINK1] forKey:@"textColor"];
            [mDict setValue:@"音钥匙：\n一把银质的钥匙，可以解开被锁住的词库。我敢打赌制作者忘了怎么写“银”字，所以找了个谐音。。。\n使用方法：\n- 选择词库种类时，点击被银锁住的词库解锁" forKey:@"text"];
        } else if (row == 2) {
            [mDict setValue:[UIImage imageNamed:@"popup_table_bg_2.png"] forKey:@"bgImage"];
            [mDict setValue:[UIImage imageNamed:@"popup_table_icon_vip.png"] forKey:@"itemImage"];
            if (self.user.inventory.dayOfVIP == -1) {
                [mDict setValue:[NSString stringWithFormat:@"已激活"] forKey:@"amount"];
            } else {
                [mDict setValue:[NSString stringWithFormat:@"未激活"] forKey:@"amount"];
            }
            
            [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
            //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_DARKSEAGREEN1] forKey:@"textColor"];
            [mDict setValue:@"VIP大礼包：\n一个小巧可爱的包裹，却储存了神秘的力量。打开时100%保证可能不会有危险~推荐好友一起来玩可以免费获得哦！\n使用效果：\n- 激活以后，你的账户将拥有VIP的印记和背景（其他玩家可见噢），不再被广告条打扰，解除游戏数量限制，增加金币和经验奖励！" forKey:@"text"];
        }
    } else if (section == 1) {
        if (row == 0) {
            [mDict setValue:[UIImage imageNamed:@"popup_table_bg_7.png"] forKey:@"bgImage"];
            [mDict setValue:[UIImage imageNamed:@"unknown"] forKey:@"itemImage"];
            [mDict setValue:[UIColor blackColor] forKey:@"textColor"];
            //[mDict setValue:[UICustomColor colorWithType:UI_CUSTOM_COLOR_WHEAT2] forKey:@"textColor"];
            [mDict setValue:[NSString stringWithFormat:@"累积（Lv6+）人数:%6d\n累计人数:%6d", self.user.totalRef, self.user.follower] forKey:@"text"];
            [mDict setValue:[NSString stringWithFormat:@"推荐人奖励查询"] forKey:@"topLabel"];
            [mDict setValue:[NSString stringWithFormat:@"%d", self.user.uncollectRef * 500] forKey:@"goldLabel"];
            [mDict setValue:[NSString stringWithFormat:@"0"] forKey:@"keyLabel"];
            int dayOfVIP = 0;
            if (self.user.totalRef >= 30 && self.user.inventory.dayOfVIP >= 0) dayOfVIP = 1;
            [mDict setValue:[NSString stringWithFormat:@"%d", dayOfVIP] forKey:@"vipLabel"];
        }
    }
    
    return [mDict copy];
}

- (UITableViewCell *)inventoryTableView:(UITableView *)tableView cellForInventoryAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"inventoryShopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *cfgDict = [self configureInventoryTableCellForIndexPath:indexPath];
    
    UIImageView *bgView = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_TOP_IMAGE_BG];
    if (!bgView) {
        bgView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"bgImage"]];
        bgView.frame = CGRectMake(0, 0, 242.75, 48.5);
        bgView.tag = INVENTORY_TAG_TOP_IMAGE_BG;
        [cell addSubview:bgView];
    }
    
    bgView.image = [cfgDict objectForKey:@"bgImage"];
    
    UIImageView *itemImageView = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_ITEM_IMAGE];
    if (!itemImageView) {
        itemImageView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"itemImage"]];
        itemImageView.frame = CGRectMake(10, 2, 45, 45);
        itemImageView.tag = INVENTORY_TAG_ITEM_IMAGE;
        itemImageView.backgroundColor = [UIColor clearColor];
        [cell addSubview:itemImageView];
    }
    
    itemImageView.image = [cfgDict objectForKey:@"itemImage"];
    if (indexPath.row==2) itemImageView.frame = CGRectMake(10, 0, 36.57, 48);
    else itemImageView.frame = CGRectMake(10, 2, 45, 45);
    
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:INVENTORY_TAG_AMOUNT_LABEL];
    if (!amountLabel) {
        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 14, 80, 20)];
        amountLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        amountLabel.textColor = [UIColor blackColor];
        amountLabel.tag = INVENTORY_TAG_AMOUNT_LABEL;
        amountLabel.backgroundColor = [UIColor clearColor];
        amountLabel.textAlignment = UITextAlignmentLeft;
        [cell addSubview:amountLabel];
    }
    
    amountLabel.text = [cfgDict objectForKey:@"amount"];
    
    UITextView *textView = (UITextView *)[cell viewWithTag:INVENTORY_TAG_TEXT];
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 48.5, 232, 108)];
        textView.text = [cfgDict objectForKey:@"text"];
        textView.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
        textView.textColor = [UIColor whiteColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
        textView.alpha = 0;
        textView.tag = INVENTORY_TAG_TEXT;
        
        [cell addSubview:textView];
    }
    
    textView.text = [cfgDict objectForKey:@"text"];
    textView.textColor = [cfgDict objectForKey:@"textColor"];
    
    if (indexPath.row == self.inventoryTableExpandedRow)
    {
        textView.alpha = 1;
    }else
    {
        textView.alpha = 0;
    }
    
    
    return cell;
}

- (IBAction)referHelpBtnPressed:(UIButton *)sender
{
    NSString *message = @"填写推荐人\n-你会额外获得一把音钥匙；\n-你达到6级时，你的推荐人将获得500金币；\n-累计30个达到6级时，你的推荐人将获得VIP礼包！\n在主界面点击右上的【奖】按钮查询领取推荐人礼品！";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @""
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (UITableViewCell *)inventoryTableView:(UITableView *)tableView cellForRewardAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"rewardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *cfgDict = [self configureInventoryTableCellForIndexPath:indexPath];
    
    UIImageView *bgView = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_TOP_IMAGE_BG];
    if (!bgView) {
        bgView = [[UIImageView alloc] initWithImage:[cfgDict objectForKey:@"bgImage"]];
        bgView.frame = CGRectMake(0, 0, 242.75, 48.5);
        bgView.tag = INVENTORY_TAG_TOP_IMAGE_BG;
        [cell addSubview:bgView];
    }
    
    bgView.image = [cfgDict objectForKey:@"bgImage"];
    
    UIButton *referHelpBtn = (UIButton *)[cell viewWithTag:INVENTORY_TAG_REWARD_HELP_BTN];
    if (!referHelpBtn) {
        referHelpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        referHelpBtn.frame = CGRectMake(200, 7, 35, 35);
        [referHelpBtn setBackgroundImage:[UIImage imageNamed:@"icon_refreshing.png"] forState:UIControlStateNormal];
        referHelpBtn.tag = INVENTORY_TAG_REWARD_HELP_BTN;
        [referHelpBtn addTarget:self action:@selector(referHelpBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:referHelpBtn];
    }
    
    float posY = 100;
    
    UIImageView *itemBgImage = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_ITEM_BG];
    if (!itemBgImage) {
        itemBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, posY, 242.75, 62)];
        itemBgImage.tag = INVENTORY_TAG_ITEM_BG;
        itemBgImage.image = [UIImage imageNamed:@"popup_table_bg_6.png"];
        itemBgImage.backgroundColor = [UIColor clearColor];
        [cell addSubview:itemBgImage];
    }
            
    UILabel *topLabel = (UILabel *)[cell viewWithTag:INVENTORY_TAG_TOP_LABEL];
    if (!topLabel) {
        topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 220, 20)];
        topLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:20];
        topLabel.textColor = [UIColor whiteColor];
        topLabel.tag = INVENTORY_TAG_TOP_LABEL;
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.textAlignment = UITextAlignmentCenter;
        [cell addSubview:topLabel];
    }
    
    topLabel.text = [cfgDict objectForKey:@"topLabel"];
    
    UILabel *goldLabel = (UILabel *)[cell viewWithTag:INVENTORY_TAG_GOLD_LABEL];
    if (!goldLabel) {
        goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, posY+5, 57, 20)];
        goldLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        goldLabel.textColor = [UIColor blackColor];
        goldLabel.tag = INVENTORY_TAG_GOLD_LABEL;
        goldLabel.backgroundColor = [UIColor clearColor];
        goldLabel.textAlignment = UITextAlignmentLeft;
        [cell addSubview:goldLabel];
    }
    
    goldLabel.text = [cfgDict objectForKey:@"goldLabel"];
    
    UILabel *keyLabel = (UILabel *)[cell viewWithTag:INVENTORY_TAG_KEY_LABEL];
    if (!keyLabel) {
        keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(123, posY+5, 40, 20)];
        keyLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        keyLabel.textColor = [UIColor blackColor];
        keyLabel.tag = INVENTORY_TAG_KEY_LABEL;
        keyLabel.backgroundColor = [UIColor clearColor];
        keyLabel.textAlignment = UITextAlignmentLeft;
        [cell addSubview:keyLabel];
    }
    
    keyLabel.text = [cfgDict objectForKey:@"keyLabel"];
    
    
    UILabel *vipLabel = (UILabel *)[cell viewWithTag:INVENTORY_TAG_VIP_LABEL];
    if (!vipLabel) {
        vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(198, posY+5, 40, 20)];
        vipLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
        vipLabel.textColor = [UIColor blackColor];
        vipLabel.tag = INVENTORY_TAG_VIP_LABEL;
        vipLabel.backgroundColor = [UIColor clearColor];
        vipLabel.textAlignment = UITextAlignmentLeft;
        [cell addSubview:vipLabel];
    }
     
    
    vipLabel.text = [cfgDict objectForKey:@"vipLabel"];
    
    
    UIImageView *goldImage = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_GOLD_IMAGE];
    if (!goldImage) {
        goldImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, posY+5, 20, 20)];
        goldImage.tag = INVENTORY_TAG_GOLD_IMAGE;
        goldImage.image = [UIImage imageNamed:@"gold.png"];
        goldImage.backgroundColor = [UIColor clearColor];
        [cell addSubview:goldImage];
    }
    
    UIImageView *keyImage = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_KEY_IMAGE];
    if (!keyImage) {
        keyImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, posY+5, 20, 20)];
        keyImage.tag = INVENTORY_TAG_KEY_IMAGE;
        keyImage.image = [UIImage imageNamed:@"popup_table_icon_key.png"];
        keyImage.backgroundColor = [UIColor clearColor];
        [cell addSubview:keyImage];
    }
    
    UIImageView *vipImage = (UIImageView *)[cell viewWithTag:INVENTORY_TAG_VIP_IMAGE];
    if (!vipImage) {
        vipImage = [[UIImageView alloc] initWithFrame:CGRectMake(175, posY+5, 15, 20)];
        vipImage.tag = INVENTORY_TAG_VIP_IMAGE;
        vipImage.image = [UIImage imageNamed:@"popup_table_icon_vip.png"];
        vipImage.backgroundColor = [UIColor clearColor];
        [cell addSubview:vipImage];
    }
    
    UIButton *buyItemBtn = (UIButton *)[cell viewWithTag:INVENTORY_TAG_BUTTON];
    if (!buyItemBtn) {
        buyItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyItemBtn.frame = CGRectMake(71, posY+25, 100, 27.5);
        [buyItemBtn setBackgroundImage:[UIImage imageNamed:@"icon_bg_blue_1"] forState:UIControlStateNormal];
        [buyItemBtn setTitle:@"领取奖励" forState:UIControlStateNormal];
        buyItemBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:20];
        buyItemBtn.tag = INVENTORY_TAG_BUTTON;
        [buyItemBtn addTarget:self action:@selector(collectBonus:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buyItemBtn];
    }
    
    if (self.user.uncollectRef == 0) buyItemBtn.enabled = NO;
    else buyItemBtn.enabled = YES;
    
    UITextView *textView = (UITextView *)[cell viewWithTag:INVENTORY_TAG_TEXT];
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 48.5, 232, 50)];
        textView.text = [cfgDict objectForKey:@"text"];
        textView.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
        textView.textColor = [UIColor whiteColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
        textView.tag = INVENTORY_TAG_TEXT;
        
        [cell addSubview:textView];
    }
    
    textView.text = [cfgDict objectForKey:@"text"];
    textView.textColor = [cfgDict objectForKey:@"textColor"];
    
    if (self.inventoryTableExpandedReward)
    {
        itemBgImage.alpha = 1;
        textView.alpha = 1;
        buyItemBtn.alpha = 1;
        vipImage.alpha = 1;
        goldImage.alpha = 1;
        keyImage.alpha = 1;
        goldLabel.alpha = 1;
        keyLabel.alpha = 1;
        vipLabel.alpha = 1;
    } else {
        itemBgImage.alpha = 0;
        textView.alpha = 0;
        buyItemBtn.alpha = 0;
        vipImage.alpha = 0;
        goldImage.alpha = 0;
        keyImage.alpha = 0;
        goldLabel.alpha = 0;
        keyLabel.alpha = 0;
        vipLabel.alpha = 0;
    }
    
    
    return cell;
}

- (void)putSpinnerAndShadeToFront
{
    UIView *shade = [self.delegate getShade];
    [shade removeFromSuperview];
    [[self.delegate getView] addSubview:shade];
    UIActivityIndicatorView *spinner = [self.delegate getSpinner];
    [spinner removeFromSuperview];
    [[self.delegate getView] addSubview:spinner];
}

- (IBAction)collectBonus:(UIButton *)sender
{
    Player *user = self.user;
    user.delegate = self;
    [self putSpinnerAndShadeToFront];
    
    int dayOfVIP = 0;
    if (user.totalRef >=30 && user.inventory.dayOfVIP != -1) dayOfVIP = -1;
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:[self.delegate getSpinner] andEditableItems:self.editableItems andShadingView:[self.delegate getShade]];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    
    
    [self.user collectBonusForType:BONUS_TYPE_COLLECT_REF_BONUS gold:self.user.uncollectRef*500 hammer:0 key:0 dayOfVIP:dayOfVIP];
}

- (UITableViewCell *)inventoryTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [self inventoryTableView:tableView cellForInventoryAtIndexPath:indexPath];
    else if (indexPath.section == 1)
        return [self inventoryTableView:tableView cellForRewardAtIndexPath:indexPath];
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.currentTableViewType) {
        case TABLE_VIEW_TYPE_ITEM:
            return [self itemTableView:tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
        case TABLE_VIEW_TYPE_GOLD:
            return [self goldTableView:tableView cellForRowAtIndexPath:indexPath];
        case TABLE_VIEW_TYPE_INVENTORY:
            return [self inventoryTableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)itemTableView:(UITableView *)tableView
 heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    /*
    NSString *expanded = [self.itemExpandedDict objectForKey:[NSString stringWithFormat:@"%d", row]];
    if ([expanded isEqualToString:@"YES"])
        return 120;
     */
    
    if (row == self.itemTableExpandedRow) return 160;
    
    return 47;
}

- (CGFloat)goldTableView:(UITableView *)tableView
 heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int row = indexPath.row;    
    if (row == self.goldTableExpandedRow) return 110;
    
    return 47;
}

- (CGFloat)inventoryTableView:(UITableView *)tableView
 heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    if (section == 1) {
        if (self.inventoryTableExpandedReward) return 150;
        else return 47;
    }
    
    if (row == self.inventoryTableExpandedRow) return 160;
    
    return 47;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.currentTableViewType) {
        case TABLE_VIEW_TYPE_ITEM:
            return [self itemTableView:tableView heightForRowAtIndexPath:indexPath];
        case TABLE_VIEW_TYPE_GOLD:
            return [self goldTableView:tableView heightForRowAtIndexPath:indexPath];
        case TABLE_VIEW_TYPE_INVENTORY:
            return [self inventoryTableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)itemTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemTableExpandedRow == indexPath.row)
    {
        self.itemTableExpandedRow = -1;
    }
    else
    {
        self.itemTableExpandedRow = indexPath.row;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    for (int section = 0; section < [tableView numberOfSections]; section++) {
        for (int row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            [mutableArray addObject:cellPath];
            //UITableViewCell* cell = [tableView cellForRowAtIndexPath:cellPath];
            
        }
    }
    
    //[tableView beginUpdates];
    //[tableView reloadSections:<#(NSIndexSet *)#> withRowAnimation:UITableViewRowAnimationAutomatic]
    //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView reloadRowsAtIndexPaths:[mutableArray copy] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    //[tableView endUpdates];
    
}
- (void)goldTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.goldTableExpandedRow == indexPath.row)
    {
        self.goldTableExpandedRow = -1;
    }
    else
    {
        self.goldTableExpandedRow = indexPath.row;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    for (int section = 0; section < [tableView numberOfSections]; section++) {
        for (int row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            [mutableArray addObject:cellPath];
            //UITableViewCell* cell = [tableView cellForRowAtIndexPath:cellPath];
            
        }
    }
    
    [tableView reloadRowsAtIndexPaths:[mutableArray copy] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)inventoryTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (self.inventoryTableExpandedRow == indexPath.row) {
            self.inventoryTableExpandedRow = -1;
        } else {
            self.inventoryTableExpandedRow = indexPath.row;
        }
    } else if (indexPath.section == 1) {
        if (self.inventoryTableExpandedReward) self.inventoryTableExpandedReward = NO;
        else self.inventoryTableExpandedReward = YES;
    }
        
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    for (int section = 0; section < [tableView numberOfSections]; section++) {
        for (int row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            [mutableArray addObject:cellPath];
            //UITableViewCell* cell = [tableView cellForRowAtIndexPath:cellPath];
            
        }
    }
    
    [tableView reloadRowsAtIndexPaths:[mutableArray copy] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.currentTableViewType) {
        case TABLE_VIEW_TYPE_ITEM:
            [self itemTableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
        case TABLE_VIEW_TYPE_GOLD:
            [self goldTableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
        case TABLE_VIEW_TYPE_INVENTORY:
            [self inventoryTableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
    }

}

- (void)itemShopPressed:(UIButton *)sender
{
    self.itemShopBtn.selected = YES;
    self.goldShopBtn.selected = NO;
    self.userItemBtn.selected = NO;
    self.currentTableViewType = TABLE_VIEW_TYPE_ITEM;
    self.itemTableExpandedRow = -1;
    self.inventoryTableExpandedRow = -1;
    self.goldTableExpandedRow = -1;
    self.inventoryTableExpandedReward = NO;
    
    
    for (UIView *sview in self.displayView.subviews) {
        [sview removeFromSuperview];
    }
    
    [self setGoldShopTableView:nil];
    [self setItemShopTableView:nil];
    [self setInventoryTableView:nil];
    
    self.itemShopTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 242, 263) style:UITableViewStyleGrouped];
    self.itemShopTableView.dataSource = self;
    self.itemShopTableView.delegate = self;
    self.itemShopTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unknown.png"]];
    self.itemShopTableView.backgroundColor = [UIColor clearColor];
    [self.itemShopTableView setShowsVerticalScrollIndicator:NO];
    [self.itemShopTableView setEditing:NO];
    self.itemTableExpandedRow = -1;
    
    [self.displayView addSubview:self.itemShopTableView];
    
    [self.displayView setNeedsDisplay];
}

- (void)goldShopPressed:(UIButton *)sender
{
    self.itemShopBtn.selected = NO;
    self.goldShopBtn.selected = YES;
    self.userItemBtn.selected = NO;
    self.currentTableViewType = TABLE_VIEW_TYPE_GOLD;
    self.itemTableExpandedRow = -1;
    self.inventoryTableExpandedRow = -1;
    self.goldTableExpandedRow = -1;
    self.inventoryTableExpandedReward = NO;
    
    for (UIView *sview in self.displayView.subviews) {
        [sview removeFromSuperview];
    }
    
    [self setGoldShopTableView:nil];
    [self setItemShopTableView:nil];
    [self setInventoryTableView:nil];
    self.goldShopTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 242, 263) style:UITableViewStyleGrouped];
    self.goldShopTableView.dataSource = self;
    self.goldShopTableView.delegate = self;
    self.goldShopTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unknown.png"]];
    self.goldShopTableView.backgroundColor = [UIColor clearColor];
    [self.goldShopTableView setShowsVerticalScrollIndicator:NO];
    
    [self.displayView addSubview:self.goldShopTableView];
    
    [self.displayView setNeedsDisplay];
    
    /*
    [[GuessIAP sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.products = products;
            for (SKProduct *item in self.products) {
                NSLog(@"%@/%@", item.localizedTitle, item.localizedDescription);
            }
        }
    }];
     */
}

- (void)userItemPressed:(UIButton *)sender
{
    self.itemShopBtn.selected = NO;
    self.goldShopBtn.selected = NO;
    self.userItemBtn.selected = YES;
    self.currentTableViewType = TABLE_VIEW_TYPE_INVENTORY;
    self.itemTableExpandedRow = -1;
    self.inventoryTableExpandedRow = -1;
    self.goldTableExpandedRow = -1;
    self.inventoryTableExpandedReward = NO;
    
    for (UIView *sview in self.displayView.subviews) {
        [sview removeFromSuperview];
    }
    
    [self setGoldShopTableView:nil];
    [self setItemShopTableView:nil];
    [self setInventoryTableView:nil];
    self.inventoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 242, 263) style:UITableViewStyleGrouped];
    self.inventoryTableView.dataSource = self;
    self.inventoryTableView.delegate = self;
    self.inventoryTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unknown.png"]];
    self.inventoryTableView.backgroundColor = [UIColor clearColor];
    [self.inventoryTableView setShowsVerticalScrollIndicator:NO];
    
    [self.displayView addSubview:self.inventoryTableView];
    
    [self.displayView setNeedsDisplay];
}

- (void)animateGoldWithAmout:(int)amount
{
    if (amount == 0) return;
    
    for (int i=0; i<10; i++)
    {
        UIImageView *goldImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gold.png"]];
        goldImgView.frame = CGRectMake(160, 240, 40, 40);
        [[self.delegate getView] addSubview:goldImgView];
        [UIView animateWithDuration:1
                              delay:0.2*i
                            options:UIViewAnimationCurveLinear
                         animations:^(){
                             goldImgView.frame = CGRectMake(65, 35, 26, 26);
                         }
                         completion:^(BOOL finished){
                             
                             self.user.gold += amount/10;
                             [[self.delegate getUserView] animateGoldImage];
                             [[self.delegate getUserView] reloadWithPlayer:self.user];
                         }];
    }
}

- (void)animateVIPWithDays:(int)days
{
    if (days == 0) return;
    
    days = self.user.inventory.dayOfVIP;
    UIImage *image = [UIImage imageNamed:@"popup_table_icon_gift_1.png"];
    if (days == -1) image = [UIImage imageNamed:@"popup_table_icon_gift_2.png"];
    UIImageView *vipImageView = [[UIImageView alloc] initWithImage:image];
    vipImageView.frame = CGRectMake(160, 240, 40, 40);
    [[self.delegate getView] addSubview:vipImageView];
    [UIView animateWithDuration:1
                          delay:0.1
                        options:UIViewAnimationCurveLinear
                     animations:^(){
                         vipImageView.frame = CGRectMake(220, 140, 30, 30);
                     }
                     completion:^(BOOL finished){
                         [vipImageView removeFromSuperview];
                     }];
}

- (BOOL)checkServerResponse:(int)code
{
    if (code == E_BAD_DATA) {
        [UIViewCustomAnimation showAlert:@"服务器故障，请重新操作"];
        return FALSE;
    }
    else if (code == E_WRONG_SESSION) {
        [UIViewCustomAnimation showAlert:@"服务器故障，请重新登陆"];
        return FALSE;
    }
    
    return TRUE;
}

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:[self.delegate getSpinner] andEditableItems:self.editableItems andShadingView:[self.delegate getShade]];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    
    if (!success) {
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        return;
    }
    
    if (![self checkServerResponse:[[serverResponse objectForKey:@"s"] intValue]])
        return;
    
    NSString *state = nil;
    int collectedGold, collectedVIP;
    int previousVIP = self.user.inventory.dayOfVIP;
    switch (type) {
        case REQUEST_TYPE_COLLECT_BONUS:
            state = [serverResponse objectForKey:@"s"];
            CollectBonusStatus collectStatus = [state intValue];
            switch (collectStatus) {
                case COLLECT_BONUS_STATUS_SUCCESS:
                    collectedGold = [[serverResponse objectForKey:@"gold"] intValue] - self.user.gold;
                    collectedVIP = [[serverResponse objectForKey:@"vip"] intValue] - self.user.inventory.dayOfVIP;
                    self.user.inventory.numOfHammers = [[serverResponse objectForKey:@"hammer"] intValue];
                    self.user.inventory.numOfKeys = [[serverResponse objectForKey:@"silverkey"] intValue];
                    self.user.inventory.dayOfVIP = [[serverResponse objectForKey:@"vip"] intValue];
                    self.user.totalRef = [[serverResponse objectForKey:@"totalRef"] intValue];
                    self.user.uncollectRef = [[serverResponse objectForKey:@"uncollectRef"] intValue];
                    [[self.delegate getUserView] reloadWithPlayer:self.user];
                    
                    if (self.currentTableViewType == TABLE_VIEW_TYPE_INVENTORY) {
                        [self.inventoryTableView reloadData];
                    }
                    
                    if (previousVIP != -1 && self.user.inventory.dayOfVIP == -1) {
                        [self.delegate animateVIP];
                    }
                    
                    [self animateGoldWithAmout:collectedGold];
                    [self animateVIPWithDays:collectedVIP];
                    break;
                case COLLECT_BONUS_STATUS_IGP_FAIL:
                    break;
                case COLLECT_BONUS_STATUS_NO_TYPE:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}

@end
