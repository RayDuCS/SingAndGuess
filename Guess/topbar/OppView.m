//
//  OppView.m
//  Guess
//
//  Created by Rui Du on 6/16/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "OppView.h"
#import "MenuViewController.h"
#import "UICustomFont.h"
#import "UICustomColor.h"
#import "UIViewCustomAnimation.h"

#define FRAME_WIDTH 140
#define FRAME_HEIGHT 80
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface OppView()

@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *portraitImageView;
@property (strong, nonatomic) UIImageView *levelImageView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *vipImageView;

/*
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *oppID;
@property (nonatomic) int level;
@property (nonatomic) BOOL isMale;
*/

@property (strong, nonatomic) GuessGame *game;

@end

@implementation OppView

@synthesize view = _view;
@synthesize levelLabel = _levelLabel;
@synthesize levelImageView = _levelImageView;
@synthesize portraitImageView = _portraitImageView;
@synthesize nameLabel = _nameLabel;
@synthesize bgImageView = _bgImageView;
@synthesize vipImageView = _vipImageView;
/*
@synthesize nickname = _nickname;
@synthesize level = _level;
@synthesize userID = _userID;
@synthesize oppID = _oppID;
@synthesize isMale = _isMale;
 */
@synthesize game = _game;

- (OppView *)initWithGame:(GuessGame *)game
{
    self = [super init];
    if (!self) return self;
    
    self.game = game;
    /*
    self.userID = userID;
    self.oppID = oppID;
    self.nickname = nickname;
    self.level = level;
    self.isMale = isMale;
     */
    self.view = [[UIView alloc] initWithFrame:CGRectMake(172, 5, FRAME_WIDTH, FRAME_HEIGHT)];
    self.view.backgroundColor = [UIColor clearColor];
    [self draw];
    
    return self;
}

- (void)reloadWithPlayer:(Player *)player
{
    [self updateValuesWithPlayer:player];
    [self.view setNeedsDisplay];
}

- (void)updateValuesWithPlayer:(Player *)player
{
    self.levelLabel.text = [NSString stringWithFormat:@"%d", player.level];
    self.nameLabel.text = player.nickname;
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png", DOCUMENTS_FOLDER, self.game.userID, self.game.oppID]];
    
    self.portraitImageView = [[UIImageView alloc] initWithImage:image];
    self.portraitImageView.frame = CGRectMake(5, 5, 50, 50);
    if (self.game.oppDayOfVIP != 0) {
        self.bgImageView.image = [UIImage imageNamed:@"topbar_vip_bg.png"];
        self.vipImageView.alpha = 1;
    }
}

- (void)draw
{
    UIColor *bgColor = [UIColor clearColor];
    
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topbar_bg.png"]];    
    self.bgImageView.frame = CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT);
    
    self.levelImageView = [[UIImageView alloc] initWithImage:[MenuViewController getLevelImageForLevel:self.game.oppLevel]];
    self.levelImageView.frame = CGRectMake(36, 13, 20, 13);
    
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 9, 24, 21)];
    self.levelLabel.text = [NSString stringWithFormat:@"%d", self.game.oppLevel];
    self.levelLabel.backgroundColor = bgColor;
    self.levelLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:21];
    self.levelLabel.adjustsFontSizeToFitWidth = YES;
    self.levelLabel.minimumFontSize = 12;
    self.levelLabel.textAlignment = UITextAlignmentLeft;
    self.levelLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_YELLOW1];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 57, 125, 21)];
    self.nameLabel.text = self.game.oppNickname;
    self.nameLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:17];
    self.nameLabel.backgroundColor = bgColor;
    self.nameLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_WHITE];
    self.nameLabel.textAlignment = UITextAlignmentRight;
    
    UIImage *genderImg = [UIImage imageNamed:@"male.png"];
    if (!self.game.oppSex)
        genderImg = [UIImage imageNamed:@"female.png"];
    
    UIImageView *genderImgView = [[UIImageView alloc] initWithImage:genderImg];
    genderImgView.frame = CGRectMake(4, 8, 24, 24);
    genderImgView.backgroundColor = bgColor;
    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png", DOCUMENTS_FOLDER, self.game.userID, self.game.oppID]];
    
    self.portraitImageView = [[UIImageView alloc] initWithImage:image];
    self.portraitImageView.frame = CGRectMake(85, 5, 50, 50);
    
    self.vipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_table_icon_vip.png"]];
    self.vipImageView.frame = CGRectMake(FRAME_WIDTH-22+5, -5, 22, 28.875); //-5, 0, 22, 28.875);
    self.vipImageView.alpha = 0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.portraitImageView.frame;
    [button addTarget:self action:@selector(portraitPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.game.oppDayOfVIP != 0) {
        self.bgImageView.image = [UIImage imageNamed:@"topbar_vip_bg.png"];
        self.vipImageView.alpha = 1;
    }
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.levelImageView];
    [self.view addSubview:self.levelLabel];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:genderImgView];
    [self.view addSubview:self.portraitImageView];
    [self.view addSubview:self.vipImageView];
    [self.view addSubview:button];
}

- (IBAction)portraitPressed:(id)sender
{
    //NSString *title = [NSString stringWithFormat:@"同步%@的头像?", self.game.oppSex?@"他":@"她"];
    UIActionSheet *mymenu = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                             otherButtonTitles:nil];
    
    [mymenu addButtonWithTitle:@"同步TA的头像"];
    mymenu.cancelButtonIndex = [mymenu addButtonWithTitle: @"取消"];
    [mymenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"同步TA的头像"])
    {
        self.game.delegate = self;
        [self.game getOppPortrait];
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
            [self.portraitImageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png", DOCUMENTS_FOLDER, self.game.userID, self.game.oppID]]];
            [self.view setNeedsDisplay];
            break;
            
            
        default:
            break;
    }
}


@end
