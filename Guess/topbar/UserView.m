//
//  UserView.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "UserView.h"
#import "Player.h"
#import "UICustomFont.h"
#import "MenuViewController.h"
#import "UICustomColor.h"
#import "UIViewCustomAnimation.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface UserView()

@property (nonatomic) UIColor *bgColor;
@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UIImageView *levelImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *goldLabel;
@property (strong, nonatomic) UIProgressView *expProgressView;
@property (strong, nonatomic) UIImageView *portraitImageView;
@property (strong, nonatomic) UIImageView *goldImgView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *vipImageView;

@property (strong, nonatomic) AVAudioPlayer *sePlayer;
@property (strong, nonatomic) AVAudioPlayer *seLevelPlayer;

@property (strong, nonatomic) Player *user;

@end

@implementation UserView

@synthesize bgColor = _bgColor;
@synthesize view = _view;
@synthesize levelLabel = _levelLabel;
@synthesize levelImageView = _levelImageView;
@synthesize nameLabel = _nameLabel;
@synthesize goldLabel = _goldLabel;
@synthesize expProgressView = _expProgressView;
@synthesize portraitImageView = _portraitImageView;
@synthesize user = _user;
@synthesize goldImgView = _goldImgView;
@synthesize bgImageView = _bgImageView;
@synthesize vipImageView = _vipImageView;
@synthesize sePlayer = _sePlayer;
@synthesize seLevelPlayer = _seLevelPlayer;

- (UserView *)initWithPlayer:(Player *)player
{
    self = [super init];
    if (!self)
        return self;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(8, 5, FRAME_WIDTH, FRAME_HEIGHT)];
    self.bgColor = [UIColor clearColor];
    self.view.backgroundColor = self.bgColor;
    self.user = player;
    [self drawWithPlayer:player];
    
    return self;
}

- (void)reloadWithPlayer:(Player *)player
{
    [self updateValuesWithPlayer:player];
    [self.portraitImageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER, player.ID]]];
    [self.view setNeedsDisplay];
    self.user = player;
}

- (NSString *)getGoldValueString:(int)goldValue
{
    if (goldValue < 10000) return [NSString stringWithFormat:@"%d", goldValue];
    if (goldValue > 99999) return @"99.9k";
    
    int goldValueLess = goldValue / 100;
    int digit = goldValueLess % 10;
    int restDigit = goldValueLess / 10;
    return [NSString stringWithFormat:@"%d.%dk", restDigit, digit];
}

- (void)updateValuesWithPlayer:(Player *)player
{
    self.levelLabel.text = [NSString stringWithFormat:@"%d", player.level];
    self.levelImageView.image = [MenuViewController getLevelImageForLevel:player.level];
    self.nameLabel.text = player.nickname;
    self.goldLabel.text = [self getGoldValueString:player.gold];
    [self.expProgressView setProgress:[player calLevelingRatio] animated:NO];
    //self.expProgressView.progress = [player calLevelingRatio];
    self.user = player;
    if (self.user.inventory.dayOfVIP != 0) {
        self.bgImageView.image = [UIImage imageNamed:@"topbar_vip_bg.png"];
        self.vipImageView.alpha = 1;
    }
}

- (void)drawWithPlayer:(Player *)player
{
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbar_bg.png"]];
    self.bgImageView.frame = CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT);
    
    self.levelImageView = [[UIImageView alloc] initWithImage:[MenuViewController getLevelImageForLevel:player.level+1]];
    self.levelImageView.frame = CGRectMake(60, 13, 20, 13);
    
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(84, 9, 24, 21)];
    self.levelLabel.text = [NSString stringWithFormat:@"%d", player.level];
    self.levelLabel.backgroundColor = self.bgColor;
    self.levelLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:21];
    self.levelLabel.adjustsFontSizeToFitWidth = YES;
    self.levelLabel.minimumFontSize = 12;
    self.levelLabel.textAlignment = UITextAlignmentLeft;
    self.levelLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_YELLOW1];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 57, 125, 21)];
    self.nameLabel.text = player.nickname;
    self.nameLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:17];
    self.nameLabel.backgroundColor = self.bgColor;
    self.nameLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_WHITE];
    
    self.goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 32, 51, 21)];
    self.goldLabel.text = [self getGoldValueString:player.gold];
    self.goldLabel.textAlignment = UITextAlignmentRight;
    self.goldLabel.backgroundColor = self.bgColor;
    self.goldLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:17];
    self.goldLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_WHITE];
    
    UIImage *goldImg = [UIImage imageNamed:@"gold.png"];
    self.goldImgView = [[UIImageView alloc] initWithImage:goldImg];
    self.goldImgView.frame = CGRectMake(57, 30, 26, 26);
    self.goldImgView.backgroundColor = self.bgColor;
    
    UIImage *genderImg = [UIImage imageNamed:@"male.png"];
    if (!player.isMale)
        genderImg = [UIImage imageNamed:@"female.png"];
    
    UIImageView *genderImgView = [[UIImageView alloc] initWithImage:genderImg];
    genderImgView.frame = CGRectMake(112, 8, 24, 24);
    genderImgView.backgroundColor = self.bgColor;
    
    self.expProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 80, 140, 9)];
    [self.expProgressView setProgressViewStyle:UIProgressViewStyleBar];
    self.expProgressView.progress = [player calLevelingRatio];
    self.expProgressView.backgroundColor = self.bgColor;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER, player.ID]];
    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER, player.ID]);
    
    self.portraitImageView = [[UIImageView alloc] initWithImage:image];
    self.portraitImageView.frame = CGRectMake(5, 5, 50, 50);
    
    self.vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_table_icon_vip.png"]];
    self.vipImageView.frame = CGRectMake(-5, -5, 22, 28.875);
    self.vipImageView.alpha = 0;    
    if (self.user.inventory.dayOfVIP != 0) {
        self.bgImageView.image = [UIImage imageNamed:@"topbar_vip_bg.png"];
        self.vipImageView.alpha = 1;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.portraitImageView.frame;
    [button addTarget:self action:@selector(portraitPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.levelImageView];
    [self.view addSubview:self.levelLabel];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.goldLabel];
    [self.view addSubview:self.goldImgView];
    [self.view addSubview:genderImgView];
    [self.view addSubview:self.expProgressView];
    [self.view addSubview:self.portraitImageView];
    [self.view addSubview:self.vipImageView];
    [self.view addSubview:button];
}

- (void)animateGoldImage
{
    self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_gold" ofType:@"wav"]
                                                      volumn:1];
    [self.sePlayer play];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationCurveLinear
                     animations:^(){
                         self.goldImgView.frame = CGRectMake(54, 27, 32, 32);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3
                                               delay:0
                                             options:UIViewAnimationCurveLinear
                                          animations:^(){
                                              self.goldImgView.frame = CGRectMake(57, 30, 26, 26);
                                          }
                                          completion:^(BOOL finished){
                                          }];
                     }];
}

- (void)tryAnimateLevelUp:(int)expGain
{
    if (self.user.level > 39) return;
    
    BOOL levelUp = FALSE;
    
    self.user.exp += expGain;
    float expRatio = [self.user calLevelingRatio];
    if (expRatio >= 1) levelUp = TRUE;
    
    if (!levelUp) {
        [self.expProgressView setProgress:expRatio animated:YES];
        //[self updateValuesWithPlayer:self.user];
        return;
    }
    
    self.user.level++;
    [self.expProgressView setProgress:1 animated:YES];
    self.seLevelPlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_correct_answer" ofType:@"wav"]
                                                           volumn:1];
    [self.seLevelPlayer play];
    [UIView animateWithDuration:0.8
                          delay:0.01
                        options:UIViewAnimationCurveLinear
                     animations:^() {
                         self.levelImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         self.levelLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     }
                     completion:^(BOOL finished) {
                         self.levelLabel.text = [NSString stringWithFormat:@"%d", self.user.level+1];
                         self.levelImageView.image = [MenuViewController getLevelImageForLevel:self.user.level+1];
                         [self.expProgressView setProgress:0 animated:NO];
                         [UIView animateWithDuration:1.2
                                               delay:0.01
                                             options:UIViewAnimationCurveLinear
                                          animations:^() {
                                              self.levelImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                              self.levelLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.5
                                                                    delay:0.01
                                                                  options:UIViewAnimationCurveLinear
                                                               animations:^() {
                                                                   self.levelImageView.transform = CGAffineTransformMakeScale(1, 1);
                                                                   self.levelLabel.transform = CGAffineTransformMakeScale(1, 1);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [self.expProgressView setProgress:[self.user calLevelingRatio] animated:YES];
                                                               }];
                                          }];
                     }];

}

- (IBAction)portraitPressed:(id)sender
{
    UIActionSheet *mymenu = [[UIActionSheet alloc]
                          initWithTitle:nil
                          delegate:self
                          cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                          otherButtonTitles:nil];
    
    [mymenu addButtonWithTitle:@"同步你的头像"];
    mymenu.cancelButtonIndex = [mymenu addButtonWithTitle: @"取消"];    
    [mymenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"同步你的头像"])
    {
        self.user.delegate = self;
        [self.user getPortrait];
    }
    
}

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    if (!success)
    {
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        return;
    }
    switch (type) {
        case REQUEST_TYPE_GET_PORTRAIT:
            [self.portraitImageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER, self.user.ID]]];
            [self.view setNeedsDisplay];
            break;
            
            
        default:
            break;
    }
}

@end
