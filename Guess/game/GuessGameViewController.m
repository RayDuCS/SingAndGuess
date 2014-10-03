//
//  GuessGameViewController.m
//  Guess
//
//  Created by Rui Du on 6/15/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "MenuViewController.h"
#import "GuessGameViewController.h"
#import "ResultViewController.h"
#import "UserView.h"
#import "OppView.h"
#import "GuessGame.h"
#import "Player.h"
#import "Inventory.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"
#import "UICustomColor.h"


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define ADBANNER_MARGIN_DISTENCE_TOP_GUESS 315

@interface GuessGameViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *guess1Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess2Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess3Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess4Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess5Btn;

@property (weak, nonatomic) IBOutlet UIButton *itemBtn;
@property (weak, nonatomic) IBOutlet UIButton *banBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *turnValueLabel;


@property (strong, nonatomic) NSString *guess;

@property (strong, nonatomic) NSArray *guessBtnArray;

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;
@property (weak, nonatomic) GuessGame *game;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) float lengthOfRecord;
@property (nonatomic) float lengthRemaining;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;

@property (nonatomic) int index;
@property (strong, nonatomic) AVAudioPlayer *sePlayer;

@property (weak, nonatomic) NSDictionary *userInfo;
@property (nonatomic) BOOL showResultPressed;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation GuessGameViewController
@synthesize startBtn = _startBtn;
@synthesize stopBtn = _stopBtn;
@synthesize progressBar = _progressBar;
@synthesize guess1Btn = _guess1Btn;
@synthesize guess2Btn = _guess2Btn;
@synthesize guess3Btn = _guess3Btn;
@synthesize guess4Btn = _guess4Btn;
@synthesize guess5Btn = _guess5Btn;
@synthesize itemBtn = _itemBtn;
@synthesize banBtn = _banBtn;
@synthesize doneBtn = _doneBtn;
@synthesize backBtn = _backBtn;
@synthesize turnValueLabel = _turnValueLabel;
@synthesize guess = _guess;
@synthesize guessBtnArray = _guessBtnArray;
@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize user = _user;
@synthesize game = _game;
@synthesize timer = _timer;
@synthesize lengthOfRecord = _lengthOfRecord;
@synthesize lengthRemaining = _lengthRemaining;
@synthesize audioPlayer = _audioPlayer;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize index = _index;
@synthesize sePlayer = _sePlayer;
@synthesize userInfo = _userInfo;
@synthesize showResultPressed = _showResultPressed;
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
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    [super loadWithPlayer:user
                   inGame:game
                 userInfo:userInfo
              usePopIndex:index];
    self.index = index;
}

- (void)loadPlayer
{
    if (self.audioPlayer) return; // has loaded player
    
    NSError *err = nil;
    
    //int indexOfLastSlash = (int)([self.game.audioPath rangeOfString:@"/" options:NSBackwardsSearch].location);
    //NSString *path = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat: @"/%@", [self.game.audioPath substringFromIndex:indexOfLastSlash+1]]];
    NSString *path = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat:@"/%@/audio.caf", [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (!self.audioPlayer)
    {
        NSLog(@"Player: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        [UIViewCustomAnimation showAlert:@"音频文件不存在，请退回上一页面"];
        return;
    }
    
    //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
    //                         sizeof (audioRouteOverride),&audioRouteOverride);
    //self.audioPlayer.volume = GAME_AUDIO_VOLUMN;
    [self.audioPlayer prepareToPlay];
    self.lengthOfRecord = self.audioPlayer.duration;
    self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.lengthOfRecord];
    [self.progressBar setProgress:1];
    [self startBtnPressed:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *btnColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_STEEL_BLUE_2];
    
    [self.guess1Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess1Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess2Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess2Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess3Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess3Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess4Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess4Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess5Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess5Btn setTitleColor: btnColor forState:UIControlStateSelected];
    
    self.guess1Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess2Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess3Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess4Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess5Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    
    self.progressLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
    
    CGRect newFrame;
    //設定CGRect左上角的原點座標
    newFrame.origin = CGPointMake(0, 0);
    //設定CGRect的大小
    newFrame.size = CGSizeMake(10, 10);
    [self.guess5Btn.titleLabel setFrame:newFrame ];
    
    
    self.turnValueLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:16];
    
}

- (void)applyCrackForValue:(int)value
{
    switch (value) {
        case 1:
            [super configureOptionBtn:self.guess1Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
            break;
        case 2:
            [super configureOptionBtn:self.guess2Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
            break;
        case 3:
            [super configureOptionBtn:self.guess3Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
            break;
        case 4:
            [super configureOptionBtn:self.guess4Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
            break;
        case 5:
            [super configureOptionBtn:self.guess5Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
            break;
            
        default:
            break;
    }
}

- (BOOL)validateUserAndGame
{
    BOOL initCheck = [super validateUserAndGame];
    
    if (!initCheck) return FALSE;
    
    if (!self.game.answerCN) return FALSE;
    if (!self.game.answerID) return FALSE;
    if (self.game.answerCN.count != 5) return FALSE;
    if (self.game.answerID.count != 5) return FALSE;
    
    if (!self.game.answer) return FALSE;
    if (self.game.crackedOption1 < 0 ||
        self.game.crackedOption2 < 0 ||
        self.game.hammerUsed < 0)
        return FALSE;
    
    return TRUE;
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
    [self.editableItems addObject:self.guess1Btn];
    [self.editableItems addObject:self.guess2Btn];
    [self.editableItems addObject:self.guess3Btn];
    [self.editableItems addObject:self.guess4Btn];
    [self.editableItems addObject:self.guess5Btn];
    [self.editableItems addObject:self.itemBtn];
    [self.editableItems addObject:self.banBtn];
    [self.editableItems addObject:self.doneBtn];
    [self.editableItems addObject:self.backBtn];
    
    self.turnValueLabel.text = [super getTurnString:self.game.round];
    [self.guess1Btn setTitle:[self.game.answerCN objectAtIndex:0] forState:UIControlStateNormal];
    //[self.guess1Btn setTitle:@"Hello world" forState:UIControlStateNormal];
    //[self.guess2Btn setTitle:@"一二三四五六七八九十一二三四五六七八九十" forState:UIControlStateNormal];
    [self.guess2Btn setTitle:[self.game.answerCN objectAtIndex:1] forState:UIControlStateNormal];
    [self.guess3Btn setTitle:[self.game.answerCN objectAtIndex:2] forState:UIControlStateNormal];
    [self.guess4Btn setTitle:[self.game.answerCN objectAtIndex:3] forState:UIControlStateNormal];
    [self.guess5Btn setTitle:[self.game.answerCN objectAtIndex:4] forState:UIControlStateNormal];
    //[self.guess5Btn setTitle:@"we are never never get back together" forState:UIControlStateNormal];
    
    [super configureOptionBtn:self.guess1Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess2Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess3Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess4Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess5Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    if (self.game.hammerUsed == 1) // used hammer before
    {
        [self applyCrackForValue:self.game.crackedOption1];
        [self applyCrackForValue:self.game.crackedOption2];
    }
    
    [self.view setNeedsDisplay];
    
    if(self.user.inventory.dayOfVIP == 0)
    {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                FRAME_HEIGHT+ADBANNER_MARGIN_DISTENCE_TOP_GUESS,
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
    
    self.game.delegate = self;
    [self.game downloadFileForUser:self.game.userID FromOpp:self.game.oppID isComment:FALSE];
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.guessBtnArray = [NSArray arrayWithObjects:self.guess1Btn,self.guess2Btn,self.guess3Btn,self.guess4Btn,self.guess5Btn, nil];
}

- (void)viewDidUnload
{
    [self setStartBtn:nil];
    [self setProgressBar:nil];
    [self setGuess1Btn:nil];
    [self setGuess2Btn:nil];
    [self setGuess3Btn:nil];
    [self setGuess4Btn:nil];
    [self setGuess5Btn:nil];
    [self setStopBtn:nil];
    [self setItemBtn:nil];
    [self setBanBtn:nil];
    [self setBackBtn:nil];
    [self setDoneBtn:nil];
    [self setTurnValueLabel:nil];
    [self setProgressLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setGuess:nil];
    [self setGuessBtnArray:nil];
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

- (IBAction)backPressed:(UIButton *)sender
{
    [self stopBtnPressed:nil];
    [super backToMenu:sender];
}

- (IBAction)startBtnPressed:(UIButton *)sender 
{
    /*
    NSError *error;
    NSString *biuPath = [[NSBundle mainBundle] pathForResource:@"pew-pew-lei" ofType:@"caf"];
    self.sePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:biuPath] error:&error];
    [self.sePlayer prepareToPlay];
    [self.sePlayer play];
     */
    if (self.startBtn.selected)
    {
        self.startBtn.selected = NO;
        [self.timer invalidate];
        [self.audioPlayer pause];
        return;
    }
    
    if (!self.audioPlayer)
        return;
    
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

- (void)resetGuessBtns
{
    for (UIButton *btn in self.guessBtnArray)
    {
        [btn setSelected:NO];
        btn.alpha = 1;
    }
    
    self.guess = nil;
}

- (IBAction)guessPressed:(UIButton *)sender
{
    int i = 0;
    int j = 0;
    for (UIButton *btn in self.guessBtnArray)
    {
        [btn setSelected:NO];
        btn.alpha = 0.5;
        if(sender == btn)
        {
            //NSLog(@"here");
            j = i;
        }
        i++;
    }
    
    sender.alpha = 1;
    [sender setSelected:YES];
    if (self.showResultPressed) return;
    
    self.guess = [self.game.answerID objectAtIndex:j];
}

- (IBAction)itemBtnPressed:(UIButton *)sender
{
    if (self.user.inventory.numOfHammers <= 0)
    {
        [UIViewCustomAnimation showAlert:@"您没有足够的锤子"];
        return;
    }
    
    if (self.game.hammerUsed)
    {
        [UIViewCustomAnimation showAlert:@"您已经使用过锤子"];
        return;
    }
    
    self.user.inventory.delegate = self;
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    [self.user.inventory usesHammerWithAmount:1 oppID:self.game.oppID option:HAMMER_USAGE_OPTION_CRACK];
}

- (void)removeAudioFile
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:self.game.audioPath];
    NSError *err = nil;
    [fm removeItemAtPath:[url path] error:&err];
    if(err)
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    self.audioPlayer = nil;
}

- (UIButton *)answerBtn
{
    if ([[self.game.answerID objectAtIndex:0] isEqualToString:self.game.answer]) {
        return self.guess1Btn;
    }
    if ([[self.game.answerID objectAtIndex:1] isEqualToString:self.game.answer]) {
        return self.guess2Btn;
    }
    if ([[self.game.answerID objectAtIndex:2] isEqualToString:self.game.answer]) {
        return self.guess3Btn;
    }
    if ([[self.game.answerID objectAtIndex:3] isEqualToString:self.game.answer]) {
        return self.guess4Btn;
    }
    if ([[self.game.answerID objectAtIndex:4] isEqualToString:self.game.answer]) {
        return self.guess5Btn;
    }
    
    return nil;
}

- (void)animateAnswerBtn:(UIButton *)sender
{
    if ([self.guess isEqualToString:self.game.answer]) {
        [self performSegueWithIdentifier:@"resultOfGameSeg" sender:sender];
        return;
    }
    
    UIButton *button = [self answerBtn];
    if (!button) {
        [self performSegueWithIdentifier:@"resultOfGameSeg" sender:sender];
        return;
    }
    
    self.showResultPressed = YES;
    button.alpha = 1;
    CGRect originFrame = button.frame;
    float delta_x = 2;
    float delta_y = delta_x * originFrame.size.height / originFrame.size.width;
    [UIView animateWithDuration:0.5
                          delay:0.01
                        options:UIViewAnimationCurveLinear
                     animations:^() {
                         button.frame = CGRectMake(originFrame.origin.x-delta_x, originFrame.origin.y-delta_y, originFrame.size.width+2*delta_x, originFrame.size.height+2*delta_y);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:0.01
                                             options:UIViewAnimationCurveLinear
                                          animations:^() {
                                              button.frame = originFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              [self performSegueWithIdentifier:@"resultOfGameSeg" sender:sender];
                                          }];
                     }];
}

- (IBAction)confirmPressed:(UIButton *)sender 
{
    if (!self.guess)
    {
        [UIViewCustomAnimation showAlert:@"请选择答案"];
        return;
    }
    
        
    //if ([self.guess isEqualToString:self.game.answer]) [Player player:self.user.email GetReward:self.game.reward];
    
    [self animateAnswerBtn:sender];
    
    /*
    [self.userView reloadWithPlayer:self.user];
    //[self removeAudioFile];
    [self performSegueWithIdentifier:@"resultOfGameSeg" sender:sender];
     */
}

- (IBAction)banPressed:(UIButton *)sender
{
    self.game.delegate = self;
    [super banGame:self.game];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self stopBtnPressed:nil];
    if ([segue.identifier isEqualToString:@"resultOfGameSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                              withGuess:self.guess
                                             withReward:self.game.reward
                                               userInfo:self.userInfo
                                            usePopIndex:self.index+1];
    }
}

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner
                                        andEditableItems:self.editableItems
                                          andShadingView:self.shade];
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
        case REQUEST_TYPE_DOWNLOAD_FILE:
            [self loadPlayer];
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
            
        case REQUEST_TYPE_USE_HAMMER:
            self.game.hammerUsed = 1;
            [self resetGuessBtns];
            [self applyCrackForValue:self.game.crackedOption1];
            [self applyCrackForValue:self.game.crackedOption2];
            self.user.inventory.numOfHammers = [[serverResponse objectForKey:@"hammer"] integerValue];
            [self.view setNeedsDisplay];
            /*
            NSError *error;
            NSString *biuPath = [[NSBundle mainBundle] pathForResource:@"hammer" ofType:@"mp3"];
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:biuPath] error:&error];
            [player play];
             */
            self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_hammer" ofType:@"wav"]
                                                              volumn:0.4];
            [self.sePlayer play];
            //[UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"hammer" ofType:@"mp3"]];
            break;
            
            
        default:
            break;
    }
}

@end
