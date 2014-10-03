//
//  ResultViewController.m
//  Guess
//
//  Created by Rui Du on 7/5/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "MenuViewController.h"
#import "ResultViewController.h"
#import "RecordGameViewController.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"
#import "UICustomColor.h"
#import "UserView.h"
#import "OppView.h"
#import "Player.h"
#import "GuessGame.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface ResultViewController ()

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

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextRoundBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) GuessGame *game;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;

@property (strong, nonatomic) NSString *resultMessage;
@property (strong, nonatomic) NSString *rewardMessage;
@property (strong, nonatomic) NSString *vipRewardMessage;
@property (strong, nonatomic) NSString *recordPath;
@property (strong, nonatomic) NSString *guess;

@property (strong, nonatomic) NSString *audioPath;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *rewardTimer;
@property (strong, nonatomic) NSDictionary *recordSettings;
@property (strong, nonatomic) NSString *recordFilePath;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) float lengthOfRecord;
@property (nonatomic) float lengthRemaining;
@property (nonatomic) BOOL recordStopped;

@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;
@property (nonatomic) int gainedExp;
@property (nonatomic) int gainedVIPExp;
@property (nonatomic) int gainedGold;
@property (nonatomic) int gainedVIPGold;
@property (strong, nonatomic) NSTimer *animateTimer;
@property (strong, nonatomic) NSTimer *animateArrayTimer;
@property (nonatomic) int timerCount;
@property (nonatomic) int finalExp;
@property (nonatomic) int finalGold;
@property (strong, nonatomic) AVAudioPlayer *sePlayer;

@property (weak, nonatomic) IBOutlet UILabel *turnValueLabel;
@property (nonatomic) int index;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;

@property BOOL isContinue;

@property (weak, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation ResultViewController
@synthesize resultMessageLabel = _resultMessageLabel;
@synthesize rewardMessageLabel = _rewardMessageLabel;
@synthesize startBtn = _startBtn;
@synthesize stopBtn = _stopBtn;
@synthesize deleteBtn = _deleteBtn;
@synthesize recordBtn = _recordBtn;
@synthesize nextRoundBtn = _nextRoundBtn;
@synthesize backBtn = _backBtn;
@synthesize progressBar = _progressBar;
@synthesize user = _user;
@synthesize game = _game;
@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize resultMessage = _resultMessage;
@synthesize rewardMessage = _rewardMessage;
@synthesize vipRewardMessage = _vipRewardMessage;
@synthesize recordPath = _recordPath;
@synthesize audioPath = _audioPath;
@synthesize guess = _guess;
@synthesize lengthOfRecord = _lengthOfRecord;
@synthesize lengthRemaining = _lengthRemaining;
@synthesize recordSettings = _recordSettings;
@synthesize recordFilePath = _recordFilePath;
@synthesize recorder = _recorder;
@synthesize audioPlayer = _audioPlayer;
@synthesize index = _index;
@synthesize recordStopped = _recordStopped;
@synthesize timer = _timer;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade =_shade;
@synthesize turnValueLabel = _turnValueLabel;
@synthesize rewardTimer = _rewardTimer;
@synthesize gainedExp = _gainedExp;
@synthesize gainedGold = _gainedGold;
@synthesize gainedVIPExp = _gainedVIPExp;
@synthesize gainedVIPGold = _gainedVIPGold;
@synthesize animateTimer = _animateTimer;
@synthesize animateArrayTimer = _animateArrayTimer;
@synthesize timerCount = _timerCount;
@synthesize finalExp = _finalExp;
@synthesize finalGold = _finalGold;
@synthesize sePlayer = _sePlayer;
@synthesize isContinue = _isContinue;
@synthesize userInfo = _userInfo;
@synthesize spinnerTimer = _spinnerTimer;

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
             withGuess:(NSString *)guess
            withReward:(int)reward
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    [super loadWithPlayer:user inGame:game
                 userInfo:userInfo
              usePopIndex:index];
    
    self.index = index;
    self.guess = guess;
    self.gainedExp = [GuessGame getExpForTurn:game.round];
    
    if ([[self convertToUTF8String:self.guess] isEqualToString:self.game.answer])
    //if ([[NSString stringWithFormat:@"%s", [self.guess UTF8String]] isEqualToString:self.game.answer])
    {
        self.resultMessage = [NSString stringWithFormat:@"猜对了! 默契十足!"];
    //Guess:%@, Answer:%@", [self convertToUTF8String:self.guess], self.game.answer];
        self.rewardMessage = [NSString stringWithFormat:@"奖励："];
        self.gainedGold = reward;
        if (self.user.inventory.dayOfVIP!=0) {
            self.vipRewardMessage = [NSString stringWithFormat:@"奖励："];
            self.gainedVIPGold = reward;
            self.gainedVIPExp = 10;
        } else {
            self.vipRewardMessage = [NSString stringWithFormat:@"赢取VIP享受额外奖励!"];
            self.gainedVIPGold = 0;
            self.gainedVIPExp = 0;
        }
            
        //self.user.gold += self.game.reward;
    }
    else 
    {
        //self.resultMessage = @"答错了:(";
        self.resultMessage = [NSString stringWithFormat:@"猜错了...再接再厉哦"];
        //Guess:%@, Answer:%@", [self convertToUTF8String:self.guess], self.game.answer];
        self.rewardMessage = [NSString stringWithFormat:@"奖励："];
        self.game.reward = 0;
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
}

- (NSString *)convertToUTF8String:(NSString *)string
{
    return [NSString stringWithFormat:@"%s", [string UTF8String]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.turnValueLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:16];
    
    self.resultMessageLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:30];
    self.resultMessageLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_YELLOW1];
    
    self.rewardMessageLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.rewardMessageLabel.textColor = [UIColor whiteColor];
    
    self.vipRewardMessageLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.vipRewardMessageLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_DARK_ORANGE1];
    
    
    self.turnValueLabel.text = [super getTurnString:self.game.round];
    self.resultMessageLabel.text = self.resultMessage;
    self.rewardMessageLabel.text = self.rewardMessage;
    self.vipRewardMessageLabel.text = self.vipRewardMessage;
    if (self.user.inventory.dayOfVIP != 0) {
        self.vipImageView.image = [UIImage imageNamed:@"popup_table_icon_vip.png"];
        self.vipImageView.frame = CGRectMake(28, 241, 30, 39);
        self.vipRewardMessageLabel.frame = CGRectMake(66, 245, 69, 35);
        self.vipRewardMessageLabel.textColor = [UIColor whiteColor];
    }
    
    //if (self.user.inventory.dayOfVIP == 0) self.vipRewardMessageLabel.frame = CGRectMake(62, 245, 240, 35);
    
    self.rewardGoldLabel.text = [NSString stringWithFormat:@"%d", self.gainedGold];
    self.rewardGoldLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.rewardGoldLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_DARK_ORANGE1];
    
    self.rewardExpLabel.text = [NSString stringWithFormat:@"%d", self.gainedExp];
    self.rewardExpLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.rewardExpLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_SPRINGGREEN];
    
    self.vipGoldLabel.text = [NSString stringWithFormat:@"%d", self.gainedVIPGold];
    self.vipGoldLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.vipGoldLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_DARK_ORANGE1];
    
    self.vipExpLabel.text = [NSString stringWithFormat:@"%d", self.gainedVIPExp];
    self.vipExpLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.vipExpLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_SPRINGGREEN];
    
    self.lengthOfRecord = 10;
    
    self.progressLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];

    [UIViewCustomAnimation heartbeatAnimationForView:self.nextRoundBtn repeat:0];
    
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
    [editableItemsArray addObject:self.deleteBtn];
    [editableItemsArray addObject:self.backBtn];
    [editableItemsArray addObject:self.recordBtn];
    [editableItemsArray addObject:self.nextRoundBtn];
    
    self.editableItems = [editableItemsArray copy];
     */
    
    self.recordLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    
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
}

- (void)rewardTimerAction
{
    self.user.gold += self.game.reward;
    [self.userView reloadWithPlayer:self.user];
}

- (BOOL)validateUserAndGame
{
    return TRUE; // ResultVC is segue from GuessVC, there is no server comm, assumed to success.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self validateUserAndGame]) {
        [super showErrorAlert];
        return;
    }
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    [self.editableItems addObject:self.startBtn];
    [self.editableItems addObject:self.stopBtn];
    [self.editableItems addObject:self.deleteBtn];
    [self.editableItems addObject:self.backBtn];
    [self.editableItems addObject:self.recordBtn];
    [self.editableItems addObject:self.nextRoundBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*
    self.user.exp += self.gainedExp;
    [self.userView reloadWithPlayer:self.user];
    [self animateReward];
     */
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setResultMessageLabel:nil];
    [self setRewardMessageLabel:nil];
    [self setStartBtn:nil];
    [self setProgressBar:nil];
    [self setDeleteBtn:nil];
    [self setRecordBtn:nil];
    [self setNextRoundBtn:nil];
    [self setStopBtn:nil];
    [self setBackBtn:nil];
    [self setTurnValueLabel:nil];
    [self setRecordLabel:nil];
    [self setProgressLabel:nil];
    [self setVipRewardMessageLabel:nil];
    [self setGoldRewardImageView:nil];
    [self setExpRewardImageView:nil];
    [self setGoldVIPImageView:nil];
    [self setExpVIPImageView:nil];
    [self setVipImageView:nil];
    [self setRewardGoldLabel:nil];
    [self setVipGoldLabel:nil];
    [self setRewardExpLabel:nil];
    [self setVipExpLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setSePlayer:nil];
    [self setRewardMessage:nil];
    [self setVipRewardMessage:nil];
    [self setResultMessage:nil];
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

- (IBAction)continueGamePressed:(UIButton *)sender
{
    self.isContinue = TRUE;
    self.game.delegate = self;
    if(self.recorder)
        [self.game uploadForPlayer:self.game.userID withOppID:self.game.oppID isComment: TRUE];
    else
        [self.game finishContinueForPlayer:self.user WithGuess:self.guess andCommentPath:self.audioPath];
    //if(self.recorder)
    //[self.game finishContinueForPlayer:self.user WithGuess:self.guess andCommentPath:self.audioPath];
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (IBAction)backToMainMenuPressed:(UIButton *)sender 
{
    self.isContinue = FALSE;
    self.game.delegate = self;
    if(self.recorder)
        [self.game uploadForPlayer:self.game.userID withOppID:self.game.oppID isComment: TRUE];
    else
    {
        [self.game finishGuessingForPlayer:self.user WithGuess:self.guess andCommentPath:self.audioPath];
    }
    //
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (IBAction)banPressed:(UIButton *)sender
{
    self.game.delegate = self;
    [super banGame:self.game];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self stopBtnPressed:nil];
    if ([segue.identifier isEqualToString:@"continueGameSeg"])
    {
        if (self.user.exp < self.finalExp) self.user.exp = self.finalExp;
        if (self.user.gold < self.finalGold) self.user.gold = self.finalGold;
        if ([self.user calLevelingRatio] >= 1 && self.user.level<=39) self.user.level++; //LEVEL
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:self.index+1];
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
        [UIViewCustomAnimation showAlert:@"请您记录后再试听"];
        return;
    }
    
    //[self updateMidLabel:self.lengthOfRecord/2 andRightLabel:self.lengthOfRecord];
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

- (IBAction)stopBtnPressed:(UIButton *)sender 
{
    [self.timer invalidate];
    self.lengthRemaining = 0.0;
    self.startBtn.selected = NO;
    [self.audioPlayer stop];
    if (self.audioPlayer)
    {
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

- (IBAction)deleteBtnPressed:(UIButton *)sender
{
    self.lengthOfRecord = 0.1;
    self.startBtn.selected = NO;
    self.audioPath = nil;
    //[self updateMidLabel:5 andRightLabel:10];
    self.progressLabel.text = @"0";
    [self.progressBar setProgress:0.0];
    [self.timer invalidate];
    if (self.recorder)
    {
        [self.recorder deleteRecording];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *url = [NSURL fileURLWithPath:[DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"]];
        //NSURL *url = [NSURL fileURLWithPath:self.recordFilePath];
        NSError *err = nil;
        [fm removeItemAtPath:[url path] error:&err];
        if(err)
            NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        
        self.audioPlayer = nil;
        self.recorder = nil;
    }
}

- (IBAction)recordTapped:(UIButton *)sender 
{
    self.recordStopped = NO;
    self.recordFilePath = [NSString stringWithFormat:@"%@/mycomment.caf", DOCUMENTS_FOLDER];
    
    self.game.commentPath = self.recordFilePath;
    if ([super startRecording])
    {
        self.lengthOfRecord = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 
                                                      target:self
                                                    selector:@selector(recordProgress)
                                                    userInfo:nil
                                                     repeats:YES];
    }

}

- (IBAction)recordReleased:(UIButton *)sender 
{
    if ([self stopRecording])
    {
        [self.timer invalidate];
    }
    
    self.recordStopped = YES;
}

- (void)recordProgress
{
    self.lengthOfRecord += 0.1;
    [self.progressBar setProgress:self.lengthOfRecord/10];
    self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.lengthOfRecord];
    if (self.lengthOfRecord > 10)
    {
        if ([self stopRecording])
            [self.timer invalidate];
        
        self.recordStopped = YES;
    }
}

- (BOOL)stopRecording
{
    BOOL success = [super stopRecording];
    
    if (success)
    {
        self.lengthOfRecord = self.audioPlayer.duration;
        
        
    }
    
    return success;
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

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
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
    
    switch (type) {
        case REQUEST_TYPE_S3_UPLOAD:
            [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
            self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                                 target:self
                                                               selector:@selector(spinnerTimeout)
                                                               userInfo:nil
                                                                repeats:NO];
            if(self.isContinue)
                [self.game finishContinueForPlayer:self.user WithGuess:self.guess andCommentPath:self.audioPath];
            else
                [self.game finishGuessingForPlayer:self.user WithGuess:self.guess andCommentPath:self.audioPath];
            break;
        case REQUEST_TYPE_FINISH_CONTINUE:
            self.game.round += 1;
            [self performSegueWithIdentifier:@"continueGameSeg" sender:self];
            break;
            
        case REQUEST_TYPE_FINISH_GUESSING:
            self.game.round += 1;
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
