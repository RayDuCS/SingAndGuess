//
//  ShowResultViewController.m
//  Guess
//
//  Created by Rui Du on 10/17/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "ShowResultViewController.h"
#import "UIViewCustomAnimation.h"
#import "UserView.h"
#import "OppView.h"
#import "Player.h"
#import "GuessGame.h"
#import "Inventory.h"
#import "UICustomColor.h"
#import "UICustomFont.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface ShowResultViewController ()

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) GuessGame *game;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;

@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *nextTurnBtn;
@property (weak, nonatomic) IBOutlet UIButton *banBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *replayBtn;

@property (weak, nonatomic) IBOutlet UILabel *resultMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *rewardMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipRewardMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goldRewardImageView;
@property (weak, nonatomic) IBOutlet UIImageView *expRewardImageView;
@property (weak, nonatomic) IBOutlet UIImageView *goldVIPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *expVIPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *rewardGoldLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipGoldLabel;
@property (weak, nonatomic) IBOutlet UILabel *rewardExpLabel;
@property (weak, nonatomic) IBOutlet UILabel *vipExpLabel;

@property (strong, nonatomic) NSString *audioPath;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *rewardTimer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) float lengthOfRecord;
@property (nonatomic) float lengthRemaining;
@property (nonatomic) BOOL recordStopped;

@property (nonatomic) int popIndex;
@property (nonatomic) BOOL goNext; // if nextTurnPressed, then YES.

@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;
@property (strong, nonatomic) NSTimer *animateTimer;
@property (strong, nonatomic) NSTimer *animateArrayTimer;
@property (nonatomic) int gainedExp;
@property (nonatomic) int gainedVIPExp;
@property (nonatomic) int gainedGold;
@property (nonatomic) int gainedVIPGold;
@property (nonatomic) int timerCount;
@property (strong, nonatomic) NSString *resultMessage;
@property (strong, nonatomic) NSString *rewardMessage;
@property (strong, nonatomic) NSString *vipRewardMessage;
@property (nonatomic) int finalExp;
@property (nonatomic) int finalGold;
@property (strong, nonatomic) AVAudioPlayer *sePlayer;
@property (nonatomic) BOOL animationPlayed;
@property (nonatomic) BOOL fileDownloaded;

@property (weak, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation ShowResultViewController

@synthesize user = _user;
@synthesize game = _game;
@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize turnLabel = _turnLabel;
@synthesize stopBtn = _stopBtn;
@synthesize startBtn = _startBtn;
@synthesize progressBar = _progressBar;
@synthesize nextTurnBtn = _nextTurnBtn;
@synthesize banBtn = _banBtn;
@synthesize backBtn = _backBtn;
@synthesize popIndex = _popIndex;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize audioPath = _audioPath;
@synthesize timer = _timer;
@synthesize audioPlayer = _audioPlayer;
@synthesize lengthOfRecord = _lengthOfRecord;
@synthesize lengthRemaining = _lengthRemaining;
@synthesize recordStopped = _recordStopped;
@synthesize goNext = _goNext;
@synthesize rewardTimer = _rewardTimer;
@synthesize animateTimer = _animateTimer;
@synthesize animateArrayTimer = _animateArrayTimer;
@synthesize timerCount = _timerCount;

@synthesize resultMessageLabel = _resultMessageLabel;
@synthesize rewardMessageLabel = _rewardMessageLabel;
@synthesize vipRewardMessageLabel = _vipRewardMessageLabel;
@synthesize goldRewardImageView = _goldRewardImageView;
@synthesize expRewardImageView = _expRewardImageView;
@synthesize goldVIPImageView = _goldVIPImageView;
@synthesize expVIPImageView = _expVIPImageView;
@synthesize vipImageView = _vipImageView;
@synthesize rewardGoldLabel = _rewardGoldLabel;
@synthesize vipGoldLabel = _vipGoldLabel;
@synthesize rewardExpLabel = _rewardExpLabel;
@synthesize vipExpLabel = _vipExpLabel;

@synthesize gainedVIPExp = _gainedVIPExp;
@synthesize gainedGold = _gainedGold;
@synthesize gainedExp = _gainedExp;
@synthesize gainedVIPGold = _gainedVIPGold;
@synthesize resultMessage = _resultMessage;
@synthesize rewardMessage = _rewardMessage;
@synthesize vipRewardMessage = _vipRewardMessage;
@synthesize finalExp = _finalExp;
@synthesize finalGold = _finalGold;
@synthesize sePlayer = _sePlayer;
@synthesize animationPlayed = _animationPlayed;
@synthesize userInfo = _userInfo;
@synthesize spinnerTimer = _spinnerTimer;
@synthesize fileDownloaded = _fileDownloaded;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    [super loadWithPlayer:user
                   inGame:game
                 userInfo:userInfo
              usePopIndex:index];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.turnLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:16];
    
    self.progressLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
    self.replayBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:21];
    
    [UIViewCustomAnimation heartbeatAnimationForView:self.nextTurnBtn repeat:0];
    
    /*
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.view addSubview:self.shade];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    
    NSMutableArray *editableItemsArray = [[NSMutableArray alloc] init];
    [editableItemsArray addObject:self.startBtn];
    [editableItemsArray addObject:self.stopBtn];
    [editableItemsArray addObject:self.backBtn];
    [editableItemsArray addObject:self.nextTurnBtn];
    
    self.editableItems = [editableItemsArray copy];
     */
    
    
    self.vipGoldLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.vipGoldLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_DARK_ORANGE1];
    self.rewardMessageLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.rewardMessageLabel.textColor = [UIColor whiteColor];
    self.resultMessageLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:30];
    self.resultMessageLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_YELLOW1];
    self.vipRewardMessageLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.vipRewardMessageLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_DARK_ORANGE1];
    self.rewardGoldLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.rewardGoldLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_DARK_ORANGE1];
    self.rewardExpLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.rewardExpLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_SPRINGGREEN];
    self.vipExpLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.vipExpLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_SPRINGGREEN];
    
    
    if (![self validateUserAndGame]) {
        [super showErrorAlert];
        return;
    }
    
    self.turnLabel.text = [super getTurnString:self.game.round];
    self.gainedExp = [GuessGame getExpForTurn:self.game.round-1];
    if (self.game.reward>0) {
        self.resultMessage = [NSString stringWithFormat:@"%@猜对了! 默契十足!", self.game.oppSex?@"他":@"她"];
        self.rewardMessage = [NSString stringWithFormat:@"奖励："];
        self.gainedGold = self.game.reward;
        if (self.user.inventory.dayOfVIP!=0) {
            self.vipRewardMessage = [NSString stringWithFormat:@"奖励："];
            self.gainedVIPGold = self.gainedGold;
            self.gainedVIPExp = 10;
        } else {
            self.vipRewardMessage = [NSString stringWithFormat:@"赢取VIP享受额外奖励!"];
            self.gainedVIPGold = 0;
            self.gainedVIPExp = 0;
        }
        
    } else {
        self.resultMessage = [NSString stringWithFormat:@"%@猜错了...再接再厉哦", self.game.oppSex?@"他":@"她"];
        self.rewardMessage = [NSString stringWithFormat:@"奖励："];
        self.gainedGold = 0;
        
        if (self.user.inventory.dayOfVIP!=0) {
            self.vipRewardMessage = [NSString stringWithFormat:@"奖励："];
            self.gainedVIPGold = 0;
            self.gainedVIPExp = 10;
        } else {
            self.vipRewardMessage = [NSString stringWithFormat:@"赢取VIP享受额外奖励!"];
            self.gainedVIPGold = 0;
            self.gainedVIPExp = 0;
        }
    }
    
    self.finalGold = self.user.gold + self.gainedGold + self.gainedVIPGold;
    self.finalExp = self.user.exp + self.gainedExp + self.gainedVIPExp;
    
    self.resultMessageLabel.text = self.resultMessage;
    self.rewardMessageLabel.text = self.rewardMessage;
    
    
    self.vipRewardMessageLabel.text = self.vipRewardMessage;
    self.rewardGoldLabel.text = [NSString stringWithFormat:@"%d", self.gainedGold];
    self.rewardExpLabel.text = [NSString stringWithFormat:@"%d", self.gainedExp];
    self.vipGoldLabel.text = [NSString stringWithFormat:@"%d", self.gainedVIPGold];
    self.vipExpLabel.text = [NSString stringWithFormat:@"%d", self.gainedVIPExp];
    
    if (self.user.inventory.dayOfVIP != 0) {
        self.vipImageView.image = [UIImage imageNamed:@"popup_table_icon_vip.png"];
        self.vipImageView.frame = CGRectMake(28, 241, 30, 39);
        self.vipRewardMessageLabel.frame = CGRectMake(66, 245, 69, 35);
        self.vipRewardMessageLabel.textColor = [UIColor whiteColor];
    }
    
    self.resultMessageLabel.alpha = 0;
    self.rewardExpLabel.alpha = 0;
    self.rewardGoldLabel.alpha = 0;
    self.rewardMessageLabel.alpha = 0;
    self.goldRewardImageView.alpha = 0;
    self.goldVIPImageView.alpha = 0;
    self.expRewardImageView.alpha = 0;
    self.expVIPImageView.alpha = 0;
    self.vipExpLabel.alpha = 0;
    self.vipGoldLabel.alpha = 0;
    self.vipImageView.alpha = 0;
    self.vipRewardMessageLabel.alpha = 0;
    
    
    self.game.delegate = self;
    [self.game downloadFileForUser:self.game.userID FromOpp:self.game.oppID isComment:YES];
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];

}

- (BOOL)validateUserAndGame
{
    BOOL initCheck = [super validateUserAndGame];
    
    if (!initCheck) return FALSE;
    
    if (!self.game.answer) return FALSE;
    if (!self.game.answerCN) return FALSE;
    if (!self.game.answerID) return FALSE;
    if (self.game.answerCN.count != 5)  return FALSE;
    if (self.game.answerID.count != 5)  return FALSE;
    
    return TRUE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    [self.editableItems addObject:self.startBtn];
    [self.editableItems addObject:self.stopBtn];
    [self.editableItems addObject:self.backBtn];
    [self.editableItems addObject:self.nextTurnBtn];
    
    if (self.fileDownloaded) return;
    
    self.fileDownloaded = TRUE;
    self.game.delegate = self;
    [self.game downloadFileForUser:self.game.userID FromOpp:self.game.oppID isComment:YES];
    
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)loadGuessLabel:(UILabel *)label
                textCN:(NSString *)textCN
                textID:(NSString *)textID
{
    label.text = textCN;
    label.textColor = [UIColor blackColor];
    if ([textID isEqualToString:self.game.guess])
        label.textColor = [UIColor whiteColor];
    if ([textID isEqualToString:self.game.answer])
        label.textColor = [UIColor redColor];
}

- (void)loadPlayer
{
    self.audioPath = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat:@"/%@/audio.caf", self.user.ID]];
    NSError *err;
    NSURL *url = [NSURL fileURLWithPath:self.audioPath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (!self.audioPlayer) {
        NSLog(@"Player: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        self.lengthOfRecord = 0.1;
    } else {
        self.lengthOfRecord = self.audioPlayer.duration;
        //self.audioPlayer.volume = GAME_AUDIO_VOLUMN;
        [self.progressBar setProgress:1];
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.lengthOfRecord];
        
        //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        //AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
        //                         sizeof (audioRouteOverride),&audioRouteOverride);
        [self.audioPlayer prepareToPlay];
        [self startBtnPressed:nil];
    }
}

- (void)rewardTimerAction
{
    //self.user.gold += self.game.reward;
    self.user.gold += 1;
    [self.userView reloadWithPlayer:self.user];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.animationPlayed) return;
    
    //if (self.audioPlayer) [self startBtnPressed:nil];
    
    self.animationPlayed = YES;
    NSArray *topArray = [NSArray arrayWithObjects:self.resultMessageLabel, nil];
    NSArray *midArray = [NSArray arrayWithObjects:self.rewardMessageLabel, self.rewardExpLabel, self.rewardGoldLabel, self.goldRewardImageView, self.expRewardImageView, nil];
    NSArray *btmArray;
    if (self.user.inventory.dayOfVIP != 0) {
        btmArray = [NSArray arrayWithObjects:self.vipRewardMessageLabel, self.vipImageView, self.vipExpLabel, self.vipGoldLabel, self.goldVIPImageView, self.expVIPImageView, nil];
    } else {
        btmArray = [NSArray arrayWithObjects:self.vipRewardMessageLabel, self.vipImageView, nil];
    }
    
    [super animateResultTopViews:topArray midViews:midArray btmViews:btmArray resultGold:self.gainedGold resultExp:self.gainedExp vipGold:self.gainedVIPGold vipExp:self.gainedVIPExp];
    
    if (self.gainedGold > 0) {
        self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_correct_answer" ofType:@"wav"]
                                                          volumn:1];
        [self.sePlayer play];
    } else {
        self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_wrong_answer" ofType:@"wav"]
                                                          volumn:1];
        [self.sePlayer play];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.user.gold = self.finalGold;
    self.user.exp = self.finalExp;
    if ([self.user calLevelingRatio]>=1) self.user.level++;
    
    [self.userView reloadWithPlayer:self.user];
    
    self.resultMessageLabel.alpha = 1;
    self.rewardExpLabel.alpha = 1;
    self.rewardGoldLabel.alpha = 1;
    self.rewardMessageLabel.alpha = 1;
    self.goldRewardImageView.alpha = 1;
    self.expRewardImageView.alpha = 1;
    self.vipRewardMessageLabel.alpha = 1;
    self.vipImageView.alpha = 1;
    
    if (self.user.inventory.dayOfVIP != 0) {
        self.expVIPImageView.alpha = 1;
        self.goldVIPImageView.alpha = 1;
        self.vipExpLabel.alpha = 1;
        self.vipGoldLabel.alpha = 1;
    }
}

- (void)viewDidUnload {
    [self setTurnLabel:nil];
    [self setStopBtn:nil];
    [self setStartBtn:nil];
    [self setProgressBar:nil];
    [self setNextTurnBtn:nil];
    [self setBanBtn:nil];
    [self setBackBtn:nil];
    [self setProgressLabel:nil];
    [self setVipRewardMessageLabel:nil];
    [self setResultMessageLabel:nil];
    [self setRewardMessageLabel:nil];
    [self setGoldRewardImageView:nil];
    [self setExpRewardImageView:nil];
    [self setGoldVIPImageView:nil];
    [self setExpVIPImageView:nil];
    [self setVipImageView:nil];
    [self setRewardGoldLabel:nil];
    [self setVipGoldLabel:nil];
    [self setRewardExpLabel:nil];
    [self setVipExpLabel:nil];
    [self setReplayBtn:nil];
    [super viewDidUnload];
    
    [self setResultMessage:nil];
    [self setVipRewardMessage:nil];
    [self setRewardMessage:nil];
    [self setSePlayer:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self stopBtnPressed:nil];
    if ([segue.identifier isEqualToString:@"showToGuessSeg"])
    {
        if (self.user.exp < self.finalExp) self.user.exp = self.finalExp;
        if (self.user.gold < self.finalGold) self.user.gold = self.finalGold;
        if ([self.user calLevelingRatio] >= 1 && self.user.level<=38) self.user.level++; //LEVEL
        
        [segue.destinationViewController loadWithPlayer:self.user inGame:self.game userInfo:self.userInfo usePopIndex:self.popIndex+1];
    }
    
    if ([segue.identifier isEqualToString:@"replayGameSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user inGame:self.game userInfo:self.userInfo usePopIndex:1];
    }
}

- (void)playRecord
{
    if (self.lengthRemaining <= 0.0)
    {
        self.startBtn.selected = NO;
        [self.timer invalidate];
        //[self.progressBar setProgress:0];
    }
    else
    {
        self.lengthRemaining -= 0.1;
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.lengthOfRecord-self.lengthRemaining];
        [self.progressBar setProgress:(self.lengthOfRecord - self.lengthRemaining)/self.lengthOfRecord];
    }
}

- (IBAction)stopBtnPressed:(UIButton *)sender
{
    [self.timer invalidate];
    self.lengthRemaining = 0.0;
    self.startBtn.selected = NO;
    if (self.audioPlayer)
    {
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.progressBar setProgress:1];
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.audioPlayer.duration];
    }
    else
    {
        [self.progressBar setProgress:0];
        self.progressLabel.text = @"0";
    }
}
- (IBAction)startBtnPressed:(UIButton *)sender
{
    if (self.startBtn.selected)
    {
        self.startBtn.selected = NO;
        [self.timer invalidate];
        [self.audioPlayer pause];
        return;
    }
    
    if (!self.audioPlayer)
    {
        [UIViewCustomAnimation showAlert:@"对方没有留下评论"];
        return;
    }
    
    self.startBtn.selected = YES;
    if (self.lengthRemaining <= 0.0)
    {
        self.lengthRemaining = self.lengthOfRecord;
    }
    
    [self.audioPlayer play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(playRecord)
                                                userInfo:nil
                                                 repeats:YES];
}
- (IBAction)nextRoundBtnPressed:(UIButton *)sender
{
    self.goNext = YES;
    self.game.delegate = self;
    [self.game finishShowResultForPlayer:self.user];
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (IBAction)banBtnPressed:(UIButton *)sender {
    self.game.delegate = self;
    [super banGame:self.game];
}

- (IBAction)backBtnPressed:(UIButton *)sender {
    self.goNext = NO;
    self.game.delegate = self;
    [self.game finishShowResultForPlayer:self.user];
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (IBAction)replayBtnPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"replayGameSeg" sender:sender];
}


- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    
    if (!success)
    {
        if (type == REQUEST_TYPE_DOWNLOAD_FILE) return;
        
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        return;
    }
    
    if (![super checkServerResponse:[[serverResponse objectForKey:@"s"] intValue]])
        return;
    
    switch (type) {
        case REQUEST_TYPE_DOWNLOAD_FILE:
            [self loadPlayer];
            break;
        case REQUEST_TYPE_FINISH_SHOW_RESULT:
            if (self.goNext && self.game.playerGameState == GAMESTATE_GUESS)
            {
                [self performSegueWithIdentifier:@"showToGuessSeg" sender:nil];
                return;
            }
            
            [self stopBtnPressed:nil];
            [super backToMenu:nil];
            break;
            
        case REQUEST_TYPE_BAN_PLAYER:
            [UIViewCustomAnimation showAlert:@"屏蔽成功！\n在设置中可解除屏蔽"];
            self.user.delegate = self;
            [self.user exitGame:self.game];
            if (self.game.startOfGame)
            {
                [self stopBtnPressed:nil];
                [super backToMenu:nil];
            }
            break;
            
        case REQUEST_TYPE_DELETE_GAME:
            [self stopBtnPressed:nil];
            [super backToMenu:nil];
            break;
            
            
        default:
            break;
    }
}
@end
