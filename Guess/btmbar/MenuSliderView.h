//
//  MenuSliderView.h
//  Guess
//
//  Created by Rui Du on 6/18/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDMTPopupWindow.h"

@protocol MenuSliderViewDelegate <NSObject>

@required
- (void)logoutBtnPressed:(UIButton *)sender;
- (void)closeWindow;
- (void)tutorialBtnPressed:(UIButton *)sender;

@end

@interface MenuSliderView : NSObject<PopupWindowDelegate>

typedef enum
{
    SHOP_TAG_ITEM = 101,
    SHOP_TAG_GOLD = 102,
    SHOP_TAG_INVENTORY = 103,
}ShopTag;

@property (nonatomic) BOOL shown;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) id delegate;

- (MenuSliderView *)initWithFrame:(CGRect)frame withController:(UIViewController *) rootController;
- (void)slideOutSlider;
- (void)slideInSlider;
- (void)shopBtnPressed:(UIButton *)sender
                   tag:(ShopTag)shopTag;

@end
