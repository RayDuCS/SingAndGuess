//
//  PreRecordGameViewController.m
//  Guess
//
//  Created by Rui Du on 9/9/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "PreRecordGameViewController.h"
#import "MenuViewController.h"
#import "Player.h"
#import "UserView.h"
#import "OppView.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"
#import "UICustomColor.h"

@interface PreRecordGameViewController ()

@property (weak, nonatomic) IBOutlet UITableView *gameTableView;
@property (weak, nonatomic) IBOutlet UIButton *banBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;
@property (weak, nonatomic) GuessGame *game;

@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;

@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
@property (weak, nonatomic) IBOutlet UILabel *turnValueLabel;
@property (nonatomic) int index;
@property (nonatomic) int selectedRow;
@property (strong, nonatomic) AVAudioPlayer *sePlayer;
@property (weak, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation PreRecordGameViewController
@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize gameTableView = _gameTableView;
@synthesize banBtn = _banBtn;
@synthesize backBtn = _backBtn;
@synthesize user = _user;
@synthesize game = _game;
@synthesize index = _index;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize turnLabel = _turnLabel;
@synthesize turnValueLabel = _turnValueLabel;
@synthesize selectedRow = _selectedRow;
@synthesize sePlayer = _sePlayer;
@synthesize userInfo = _userInfo;
@synthesize spinnerTimer = _spinnerTimer;

- (void)setGameTableView:(UITableView *)gameTableView
{
    _gameTableView = gameTableView;
    self.gameTableView.delegate = self;
    self.gameTableView.dataSource = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#define ADBANNER_MARGIN_DISTENCE_TOP 20
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.turnLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    self.turnValueLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:16];
    
    /*
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.view addSubview:self.shade];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    
    NSMutableArray *editableItemsArray = [[NSMutableArray alloc] init];
    
    [editableItemsArray addObject:self.banBtn];
    [editableItemsArray addObject:self.backBtn];
    [editableItemsArray addObject:self.gameTableView];
    
    self.editableItems = [editableItemsArray copy];
     */
}

- (BOOL)validateUserAndGame
{
    BOOL initCheck = [super validateUserAndGame];
    
    if (!initCheck) return FALSE;
    
    if (!self.user.inventory.albumInfo) return FALSE;
    if (self.user.inventory.albumInfo.length < 8) return FALSE;
    
    return TRUE;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self validateUserAndGame]) {
        [super showErrorAlert];
        return;
    }
    
    self.turnValueLabel.text = [super getTurnString:self.game.round];
    if(self.user.inventory.dayOfVIP == 0)
    {
        self.gameTableView.frame = CGRectMake(0,FRAME_HEIGHT+ADBANNER_MARGIN_DISTENCE_TOP+GAD_SIZE_320x50.height,320,338-GAD_SIZE_320x50.height);
        
        //self.gameTableView.transform =  CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
        //self.gameTableView.frame.size.height = 300;
        
        
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                FRAME_HEIGHT+ADBANNER_MARGIN_DISTENCE_TOP,
                                                GAD_SIZE_320x50.width,
                                                GAD_SIZE_320x50.height)];
        
        bannerView_.adUnitID = @"a1507f758be8091";
        
        bannerView_.rootViewController = self;
        [self.view addSubview:bannerView_];
        //bannerView_.alpha = 0.0;
        
        GADRequest *request = [GADRequest request];
        //request.testing = YES; // test mode
        [bannerView_ loadRequest:request];
    }
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    
    [self.editableItems addObject:self.banBtn];
    [self.editableItems addObject:self.backBtn];
    [self.editableItems addObject:self.gameTableView];
}

- (void)viewDidUnload
{
    [self setGameTableView:nil];
    [self setBanBtn:nil];
    [self setBackBtn:nil];
    [self setTurnLabel:nil];
    [self setTurnValueLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setSePlayer:nil];
}

- (BOOL)shouldAutorotate {
    
    /*
     UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
     
     if (orientation==UIInterfaceOrientationPortrait) {
     // do some sth
     
     }
     */
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    [super loadWithPlayer:user inGame:game
                 userInfo:userInfo
              usePopIndex:index];
    self.index = index;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"continueRecordGameSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:self.index+1];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (int)convertInBoundRow:(int)row
{
    if (row == 1) return GAME_THEME_ID_YIN_YUE;             //7
    //if (row == 2) return GAME_THEME_ID_YIN_YUE_VIP;         //9
    if (row == 2) return GAME_THEME_ID_DONG_MAN_YOU_XI;     //3
    if (row == 3) return GAME_THEME_ID_DIAN_YING_DIAN_SHI;  //8
    if (row == 4) return GAME_THEME_ID_QING_GAN_XING_WEI;   //1
    if (row == 5) return GAME_THEME_ID_GE_ZHONG_DAO_JU;     //5
    if (row == 6) return GAME_THEME_ID_DA_ZI_RAN;           //4
    if (row == 7) return GAME_THEME_ID_REN_WU_MU_FANG_XIU;  //6
    if (row == 8) return GAME_THEME_ID_QING_JING_ZAI_XIAN;  //2
    
    return row;
}

- (int)convertOutboundRow:(int)row
{
    /*
    if (row == 1) return 5;
    if (row == 2) return 9;
    if (row == 3) return 3;
    if (row == 4) return 7;
    if (row == 5) return 6;
    if (row == 6) return 8;
    if (row == 7) return 1;
    if (row == 8) return 4;
    if (row == 9) return 2;
     */
    if (row == GAME_THEME_ID_YIN_YUE)               return 1;  //7
    //if (row == GAME_THEME_ID_YIN_YUE_VIP)           return 2;  //9
    if (row == GAME_THEME_ID_DONG_MAN_YOU_XI)       return 2;  //3
    if (row == GAME_THEME_ID_DIAN_YING_DIAN_SHI)    return 3;  //8
    if (row == GAME_THEME_ID_QING_GAN_XING_WEI)     return 4;  //1
    if (row == GAME_THEME_ID_GE_ZHONG_DAO_JU)       return 5;  //5
    if (row == GAME_THEME_ID_DA_ZI_RAN)             return 6;  //4
    if (row == GAME_THEME_ID_REN_WU_MU_FANG_XIU)    return 7;  //6
    if (row == GAME_THEME_ID_QING_JING_ZAI_XIAN)    return 8;  //2
    return row;
}

- (UIImage *)getImageForRow:(int)row
                    cracked:(BOOL)cracked
{
    if (row == 0) {
        if (cracked) return [UIImage imageNamed:@"game_random_cracked.png"];
        return [UIImage imageNamed:@"game_random.png"];
    }
    if (row == 1) {
        if (cracked) return [UIImage imageNamed:@"game_emotion_cracked.png"];
        return [UIImage imageNamed:@"game_emotion.png"];
    }
    if (row == 2) {
        if (cracked) return [UIImage imageNamed:@"game_film_cracked.png"];
        return [UIImage imageNamed:@"game_film.png"];
    }
    if (row == 3) {
        if (cracked) return [UIImage imageNamed:@"game_game_cracked.png"];
        return [UIImage imageNamed:@"game_game.png"];
    }
    if (row == 4) {
        if (cracked) return [UIImage imageNamed:@"game_life_cracked.png"];
        return [UIImage imageNamed:@"game_life.png"];
    }
    if (row == 5) {
        if (cracked) return [UIImage imageNamed:@"game_magic_cracked.png"];
        return [UIImage imageNamed:@"game_magic.png"];
    }
    if (row == 6) {
        if (cracked) return [UIImage imageNamed:@"game_scene_cracked.png"];
        return [UIImage imageNamed:@"game_scene.png"];
    }
    if (row == 7) {
        if (cracked) return [UIImage imageNamed:@"game_song_cracked.png"];
        return [UIImage imageNamed:@"game_song.png"];
    }
    if (row == 8) {
        if (cracked) return [UIImage imageNamed:@"game_tv_cracked.png"];
        
        return [UIImage imageNamed:@"game_tv.png"];
    }
    if (row == 9) {
        if (cracked) return [UIImage imageNamed:@"game_song_cracked.png"];
        return [UIImage imageNamed:@"game_song.png"];        
    }
    
    return [UIImage imageNamed:@"unknown.png"];
}

- (NSString *)getDescForRow:(int)row
{
    if (row == 0) return @"随机";
    if (row == 1) return @"情感行为";
    if (row == 2) return @"情景再现";
    if (row == 3) return @"动漫游戏";
    if (row == 4) return @"大自然";
    if (row == 5) return @"各种道具";
    if (row == 6) return @"人物模仿秀";
    if (row == 7) return @"音乐";
    if (row == 8) return @"电影电视";
    if (row == 9) return @"音乐加长版";
    
    return @"?";
}

- (UIImage *)getLevelImageForLevel:(int)level
{
    int displayLevel = level;
    NSString *imageName;
    if (displayLevel<=20 && displayLevel>=1)
        imageName = [NSString stringWithFormat:@"locks_lv_%d", displayLevel];
    else imageName = @"locks_golden.png";
    
    return [UIImage imageNamed:imageName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"OptionCell";
    
    /*
    if (indexPath.row == 0)
    {
        CellIdentifier = @"TitleCell";
    }*/
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    int row = [self convertInBoundRow:indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:GAME_TABLE_CELL_TAG_IMAGE];
    [imageView setImage:[self getImageForRow:row cracked:NO]];
    
    UILabel *categoryLabel = (UILabel *)[cell.contentView viewWithTag:GAME_TABLE_CELL_TAG_CATEGORY_LABEL];
    categoryLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_STEEL_BLUE_2];
    categoryLabel.text = [self getDescForRow:row];
    categoryLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:33];
    
    UIImageView *lockImageView = (UIImageView *)[cell.contentView viewWithTag:GAME_TABLE_CELL_TAG_LOCK];
    lockImageView.image = [self getLevelImageForLevel:[self levelLockForRow:row]];
    lockImageView.frame = CGRectMake(255, 13, 30, 34);
    if (row == 0) {
        lockImageView.alpha = 0;
    } else if (row == 9) {
        lockImageView.alpha = 1;
        lockImageView.frame = CGRectMake(255, 10, 30, 39);
        lockImageView.image = [UIImage imageNamed:@"popup_table_icon_vip.png"];
    } else {
        if ([self.user.inventory.albumInfo characterAtIndex:row-1] == '1') {
            lockImageView.alpha = 0;
        } else {
            lockImageView.alpha = 1;
        }
    }
    
    UIButton *lockBtn = (UIButton *)[cell.contentView viewWithTag:GAME_TABLE_CELL_TAG_BUTTON];
    lockBtn.alpha = 0;
    //[lockBtn addTarget:self action:@selector(unlockPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unknown.png"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"解锁词库"])
    {
        //NSLog(@"Use key for %d", self.selectedRow);
        int unlockReqLevel = [self levelLockForRow:self.selectedRow];
        if (self.user.level < unlockReqLevel) {
            NSString *alertStr = [NSString stringWithFormat:@"达到Lv%d才能解锁", unlockReqLevel];
            [UIViewCustomAnimation showAlert:alertStr];
            return;
        }
        
        if (self.user.inventory.numOfKeys <=0) {
            [UIViewCustomAnimation showAlert:@"没有音钥匙了，去道具商店逛逛吧"];
            return;
        }
        
        [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                             target:self
                                                           selector:@selector(spinnerTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
        self.user.inventory.delegate = self;
        [self.user.inventory useKeyTargetAlbumID:self.selectedRow];
    }
    
}

- (int)levelLockForRow:(int)row
{
    if (row==GAME_THEME_ID_RANDOM)              return 1;
    if (row==GAME_THEME_ID_QING_GAN_XING_WEI)   return 5;
    if (row==GAME_THEME_ID_QING_JING_ZAI_XIAN)  return 10;
    if (row==GAME_THEME_ID_DONG_MAN_YOU_XI)     return 1;
    if (row==GAME_THEME_ID_DA_ZI_RAN)           return 5;
    if (row==GAME_THEME_ID_GE_ZHONG_DAO_JU)     return 5;
    if (row==GAME_THEME_ID_REN_WU_MU_FANG_XIU)  return 10;
    if (row==GAME_THEME_ID_YIN_YUE)             return 1;
    if (row==GAME_THEME_ID_DIAN_YING_DIAN_SHI)  return 1;
    if (row==GAME_THEME_ID_YIN_YUE_VIP)         return 1;
    
    return 1;
}

- (IBAction)unlockPressedAtRow:(int)row
{
    if (row == 0) return;
    
    if ([self.user.inventory.albumInfo characterAtIndex:row-1] == '1') return;
    
    //NSString *title = [NSString stringWithFormat:@"确定解锁【%@】词库？", [self getDescForRow:row]];
    self.selectedRow = row;
    UIActionSheet *mymenu = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                             otherButtonTitles:nil];
    
    [mymenu addButtonWithTitle:@"解锁词库"];
    mymenu.cancelButtonIndex = [mymenu addButtonWithTitle: @"取消"];
    [mymenu showInView:self.view];
}

- (void)animateUnlockAtRow:(int)row
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [self.gameTableView cellForRowAtIndexPath:path];
    UIImageView *lockImageView = (UIImageView *)[cell.contentView viewWithTag:GAME_TABLE_CELL_TAG_LOCK];
    
    [UIView animateWithDuration:0.5
                          delay:0.01
                        options:UIViewAnimationCurveLinear
                     animations:^() {
                         lockImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     }
                     completion:^(BOOL finished) {
                         lockImageView.alpha = 0;
                         //[self.gameTableView reloadData];
                     }];
}

- (GameOptionTheme)getCurrentThemeID:(int)row
{
    if (row == 0) return GAME_OPTION_THEME_RANDOM;
    if (row == 1) return GAME_OPTION_THEME_EMOTION; // @"情感行为";
    if (row == 2) return GAME_OPTION_THEME_SCENE; //@"情景再现";
    if (row == 3) return GAME_OPTION_THEME_CARTOON; //@"动漫游戏";
    if (row == 4) return GAME_OPTION_THEME_NATURE; // @"大自然";
    if (row == 5) return GAME_OPTION_THEME_GOODS;  //@"各类道具";
    if (row == 6) return GAME_OPTION_THEME_CHARACTER; //@"人物模仿秀";
    if (row == 7) return GAME_OPTION_THEME_SONG; // @"音乐";
    if (row == 8) return GAME_OPTION_THEME_MOVIE; //@"电影电视";
    if (row == 9) return GAME_OPTION_THEME_SONG;
    
    return GAME_OPTION_THEME_RANDOM;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.gameTableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    self.game.vipEnpowered = FALSE;
    int row = [self convertInBoundRow:indexPath.row];
    if (row != 0) {
        // special handle for VIP
        if (row == 9) {
            if (self.user.inventory.dayOfVIP == 0) {
                [UIViewCustomAnimation showAlert:@"先去道具商店购买VIP大礼包吧"];
                return;
            } else {
                self.game.vipEnpowered = TRUE;
            }
        } else if ([self.user.inventory.albumInfo characterAtIndex:row-1] == '0') {
            [self unlockPressedAtRow:row];
            //[UIViewCustomAnimation showAlert:@"该词库未解锁"];
            return;
        }
    }
    
    // Make a segue.
    self.game.delegate = self;
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    self.game.themeID = [self getCurrentThemeID:row];
    [self.game startRecordingForPlayer:self.user];
    //[self performSegueWithIdentifier:@"continueRecordGameSeg" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (IBAction)banPressed:(UIButton *)sender
{
    self.game.delegate = self;
    [super banGame:self.game];
}

- (IBAction)backPressed:(UIButton *)sender
{
    [super backToMenu:sender];
}

-(void)requestDidFinish:(BOOL)success
           withResponse:(NSDictionary *)serverResponse
               withType:(RequestType)type
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];

    if (!success)
    {
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        return;
    }
    
    if (![super checkServerResponse:[[serverResponse objectForKey:@"s"] intValue]])
        return;
    
    NSString *state;
    
    switch (type) {
        case REQUEST_TYPE_BAN_PLAYER:
            [UIViewCustomAnimation showAlert:@"屏蔽成功！\n在设置中可解除屏蔽"];
            self.user.delegate = self;
            [self.user exitGame:self.game];
            if (self.game.startOfGame) [super backToMenu:nil];
            
            break;
            
        case REQUEST_TYPE_DELETE_GAME:
            [super backToMenu:nil];
            break;
            
        case REQUEST_TYPE_START_RECORDING:
            if (!serverResponse) {
                [UIViewCustomAnimation showAlert:@"服务器故障，请稍后再试"];
                break;
            }
            
            [self performSegueWithIdentifier:@"continueRecordGameSeg" sender:nil];
            break;
            
        case REQUEST_TYPE_USE_KEY:
            state = [serverResponse objectForKey:@"s"];
            UseKeyStatus status = [state intValue];
            
            switch (status) {
                case USE_KEY_STATUS_ALREADY_UNLOCKED:
                    self.user.inventory.albumInfo = [serverResponse objectForKey:@"albumstr"];
                    [self animateUnlockAtRow:[self convertOutboundRow:self.selectedRow]];
                    //[self.gameTableView reloadData];
                    break;
                case USE_KEY_STATUS_NOT_ENOUGH_KEY:
                    
                    break;
                case USE_KEY_STATUS_SUCCESS:
                    self.user.inventory.albumInfo = [serverResponse objectForKey:@"albumstr"];
                    self.user.inventory.numOfKeys = [[serverResponse objectForKey:@"silverkey"] intValue];
                    [self animateUnlockAtRow:[self convertOutboundRow:self.selectedRow]];
                    self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_key" ofType:@"wav"]
                                                                      volumn:1];
                    [self.sePlayer play];
                    //[self.gameTableView reloadData];
                    break;
                    
            }
            break;
            
        default:
            break;
    }

}

@end
