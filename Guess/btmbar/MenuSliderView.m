//
//  MenuSliderView.m
//  Guess
//
//  Created by Rui Du on 6/18/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "MenuSliderView.h"
#import "MenuSliderSettingView.h"
#import "MenuSliderShopView.h"
#import "RDMTPopupWindow.h"

@interface MenuSliderView()

@property (strong, nonatomic) RDMTPopupWindow *popupWindow;
@property (strong, nonatomic) MenuSliderSettingView *settingView;
@property (strong, nonatomic) MenuSliderShopView *shopView;
@property (strong, nonatomic) UIViewController * rootController;

@end

@implementation MenuSliderView

@synthesize settingView = _settingView;
@synthesize shopView = _shopView;
@synthesize popupWindow = _popupWindow;
@synthesize shown = _shown;
@synthesize view = _view;
@synthesize delegate = _delegate;
@synthesize rootController = _rootController;

- (MenuSliderView *)initWithFrame:(CGRect)frame withController:(UIViewController *) rootController
{
    self = [super init];
    self.shown = NO;
    
    [self setView:nil];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.rootController = rootController;
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btmbar_bg.png"]];
    bgImageView.backgroundColor = [UIColor clearColor];
    bgImageView.frame = CGRectMake(0, 0, 320, 46.25);
    
    UIButton *hidden = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidden setImage:[UIImage imageNamed:@"btmbar_btn.png"] forState:UIControlStateNormal];
    hidden.frame = CGRectMake(134.625, 0, 50.75, 14.75);
    [hidden addTarget:self action:@selector(hiddenBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    settings.frame = CGRectMake(0, 15, 78.25, 28.5);
    [settings setTitle:@"设置" forState:UIControlStateNormal];
    [settings setImage:[UIImage imageNamed:@"btmbar_settings.png"] forState:UIControlStateNormal];
    settings.titleLabel.font = [UIFont systemFontOfSize:30];
    [settings addTarget:self action:@selector(settingsBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tools = [UIButton buttonWithType:UIButtonTypeCustom];
    tools.frame = CGRectMake(80.58, 15, 78.25, 28.5);
    [tools setTitle:@"道具" forState:UIControlStateNormal];
    [tools setImage:[UIImage imageNamed:@"btmbar_shop.png"] forState:UIControlStateNormal];
    tools.titleLabel.font = [UIFont systemFontOfSize:30];
    [tools addTarget:self action:@selector(shopBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *help = [UIButton buttonWithType:UIButtonTypeCustom];
    help.frame = CGRectMake(161.16, 15, 78.25, 28.5);
    [help setTitle:@"帮助" forState:UIControlStateNormal];
    [help setImage:[UIImage imageNamed:@"btmbar_help.png"] forState:UIControlStateNormal];
    help.titleLabel.font = [UIFont systemFontOfSize:30];
    [help addTarget:self action:@selector(tutorialBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
    logout.frame = CGRectMake(241.75, 15, 78.25, 28.5);
    [logout setTitle:@"登出" forState:UIControlStateNormal];
    [logout setImage:[UIImage imageNamed:@"btmbar_logout.png"] forState:UIControlStateNormal];
    logout.titleLabel.font = [UIFont systemFontOfSize:30];
    [logout addTarget:self action:@selector(logoutBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:bgImageView];
    [self.view addSubview:hidden];
    [self.view addSubview:settings];
    [self.view addSubview:tools];
    [self.view addSubview:help];
    [self.view addSubview:logout];
    
    return self;
}

- (void)slideHiddenMenuWithValue:(float)value
{
    [UIView animateWithDuration:0.5
                          delay:0.1 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.view.frame = CGRectOffset(self.view.frame, 0, value);
                     } 
                     completion:^(BOOL finished){}];
    
    
}

- (void)slideInHiddenMenu
{
    if (self.shown)
        return;
    
    self.shown = YES;
    [self slideHiddenMenuWithValue:-28.5];
}

- (void)slideOutHiddenMenu
{
    if (!self.shown)
        return;
    
    self.shown = NO;
    [self slideHiddenMenuWithValue:28.5];
}

- (void)slideOutSlider
{
    [self slideOutHiddenMenu];
}

- (void)slideInSlider
{
    [self slideInHiddenMenu];
}

- (void)hiddenBtnPressed:(UIButton *)sender 
{
    if (self.shown)
    {
        // slide out - show
        [self slideOutHiddenMenu];
    }
    else
    {
        // slide in - hide
        [self slideInHiddenMenu];
    }
}

- (void)logoutBtnPressed:(UIButton *)sender
{
    [self slideOutHiddenMenu];
    [self.delegate logoutBtnPressed:sender];
}

- (void)settingsBtnPressed:(UIButton *)sender
{
    [self slideOutHiddenMenu];
    
    [self setSettingView:nil];
    [self setPopupWindow:nil];

    self.settingView = [[MenuSliderSettingView alloc] initWithSender:sender
                                                  withRootController:self.rootController
                                                        withDelegate:self.delegate];
    self.popupWindow = [[RDMTPopupWindow alloc] initInSuperView:self.view.superview withContentView:self.settingView.view withFrame:self.settingView.view.frame];
    self.popupWindow.delegate = self;
    
}

- (void)shopBtnPressed:(UIButton *)sender
                   tag:(ShopTag)shopTag
{
    NSLog(@"in press");
    
    [self slideOutHiddenMenu];
    
    [self setShopView:nil];
    [self setPopupWindow:nil];

    NSLog(@"before alloc");
    self.shopView = [[MenuSliderShopView alloc] initWithSender:sender withDelegate:self.delegate tag:shopTag];
    self.popupWindow = [[RDMTPopupWindow alloc] initInSuperView:self.view.superview withContentView:self.shopView.view withFrame:self.shopView.view.frame];
    self.popupWindow.delegate = self;
}

- (void)shopBtnPressed:(UIButton *)sender
{
    [self shopBtnPressed:sender tag:SHOP_TAG_ITEM];
}

- (void)closeWindow
{
    [self.delegate closeWindow];
}

- (void)tutorialBtnPressed:(UIButton *)sender
{
    [self.delegate tutorialBtnPressed:sender];
}


@end
