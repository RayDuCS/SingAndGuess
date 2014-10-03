//
//  RecordGameViewController.m
//  Guess
//
//  Created by Rui Du on 6/15/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "GameViewController.h"
#import "MenuViewController.h"
#import "RecordGameViewController.h"
#import "Player.h"
#import "UserView.h"
#import "OppView.h"
#import "GuessGame.h"
#import "Inventory.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"
#import "UICustomColor.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define BTN_FADED 0.5

@interface RecordGameViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *itemBtn;
@property (weak, nonatomic) IBOutlet UIButton *banBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@property (weak, nonatomic) IBOutlet UIButton *answer1Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer2Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer3Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer4Btn;
@property (weak, nonatomic) IBOutlet UIButton *answer5Btn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *gold1;
@property (weak, nonatomic) IBOutlet UIImageView *gold22;
@property (weak, nonatomic) IBOutlet UIImageView *gold21;
@property (weak, nonatomic) IBOutlet UIImageView *gold31;
@property (weak, nonatomic) IBOutlet UIImageView *gold32;
@property (weak, nonatomic) IBOutlet UIImageView *gold33;
@property (weak, nonatomic) IBOutlet UIImageView *gold41;
@property (weak, nonatomic) IBOutlet UIImageView *gold42;
@property (weak, nonatomic) IBOutlet UIImageView *gold43;
@property (weak, nonatomic) IBOutlet UIImageView *gold44;
@property (weak, nonatomic) IBOutlet UIImageView *gold52;
@property (weak, nonatomic) IBOutlet UIImageView *gold51;
@property (weak, nonatomic) IBOutlet UIImageView *gold55;
@property (weak, nonatomic) IBOutlet UIImageView *gold54;
@property (weak, nonatomic) IBOutlet UIImageView *gold53;

@property (weak, nonatomic) IBOutlet UILabel *recordLabel;

@property (strong, nonatomic) NSArray *answerBtnsArray;
@property (strong, nonatomic) NSString *answer;
@property (strong, nonatomic) NSString *audioPath;
@property (nonatomic) int reward;
@property (nonatomic) int max_record_length;

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;
@property (weak, nonatomic) GuessGame *game;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *hammerTimer;
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

@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
@property (weak, nonatomic) IBOutlet UILabel *turnValueLabel;
@property (nonatomic) int index;
@property (strong, nonatomic) AVAudioPlayer *sePlayer;
@property (weak, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation RecordGameViewController

@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize user = _user;
@synthesize game = _game;
@synthesize progressBar = _progressBar;
@synthesize startBtn = _startBtn;
@synthesize stopBtn = _stopBtn;
@synthesize deleteBtn = _deleteBtn;
@synthesize itemBtn = _itemBtn;
@synthesize banBtn = _banBtn;
@synthesize doneBtn = _doneBtn;
@synthesize backBtn = _backBtn;
@synthesize recordBtn = _recordBtn;
@synthesize answer1Btn = _answer1Btn;
@synthesize answer2Btn = _answer2Btn;
@synthesize answer3Btn = _answer3Btn;
@synthesize answer4Btn = _answer4Btn;
@synthesize answer5Btn = _answer5Btn;
@synthesize answerBtnsArray = _answerBtnsArray;
@synthesize answer = _answer;
@synthesize audioPath = _audioPath;
@synthesize reward = _reward;
@synthesize timer = _timer;
@synthesize lengthOfRecord = _lengthOfRecord;
@synthesize lengthRemaining = _lengthRemaining;
@synthesize recordSettings = _recordSettings;
@synthesize recordFilePath = _recordFilePath;
@synthesize recorder = _recorder;
@synthesize audioPlayer = _audioPlayer;
@synthesize index = _index;
@synthesize recordStopped = _recordStopped;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize turnLabel = _turnLabel;
@synthesize turnValueLabel = _turnValueLabel;
@synthesize hammerTimer = _hammerTimer;
@synthesize sePlayer = _sePlayer;
@synthesize max_record_length = _max_record_length;
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
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    [super loadWithPlayer:user
                   inGame:game
                 userInfo:userInfo
              usePopIndex:index];
    self.index = index;
}

- (BOOL)validateUserAndGame
{
    BOOL initCheck = [super validateUserAndGame];
    
    if (!initCheck) return FALSE;
    
    if (!self.game.answerCN) return FALSE;
    if (!self.game.answerID) return FALSE;
    if (self.game.answerCN.count != 5)  return FALSE;
    if (self.game.answerID.count != 5)  return FALSE;
    
    return TRUE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lengthOfRecord = 10;
    UIColor *btnColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_STEEL_BLUE_2];
    
    [self.answer1Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.answer1Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.answer2Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.answer2Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.answer3Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.answer3Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.answer4Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.answer4Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.answer5Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.answer5Btn setTitleColor: btnColor forState:UIControlStateSelected];
    
    self.answer1Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.answer2Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.answer3Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.answer4Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.answer5Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.turnLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    self.turnValueLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:16];
    self.turnValueLabel.text = [super getTurnString:self.game.round];
    
    self.progressLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:15];
    
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
    [editableItemsArray addObject:self.answer1Btn];
    [editableItemsArray addObject:self.answer2Btn];
    [editableItemsArray addObject:self.answer3Btn];
    [editableItemsArray addObject:self.answer4Btn];
    [editableItemsArray addObject:self.answer5Btn];
    [editableItemsArray addObject:self.itemBtn];
    [editableItemsArray addObject:self.banBtn];
    [editableItemsArray addObject:self.doneBtn];
    [editableItemsArray addObject:self.backBtn];
    [editableItemsArray addObject:self.recordBtn];
    
    self.editableItems = [editableItemsArray copy];
     */
    
    self.recordLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    self.max_record_length = 10;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self validateUserAndGame]) {
        [super showErrorAlert];
        return;
    }
    
    if (self.game.vipEnpowered) self.max_record_length = 20;
    [self.answer1Btn setTitle:[self.game.answerCN objectAtIndex:0] forState:UIControlStateNormal];
    [self.answer2Btn setTitle:[self.game.answerCN objectAtIndex:1] forState:UIControlStateNormal];
    [self.answer3Btn setTitle:[self.game.answerCN objectAtIndex:2] forState:UIControlStateNormal];
    [self.answer4Btn setTitle:[self.game.answerCN objectAtIndex:3] forState:UIControlStateNormal];
    [self.answer5Btn setTitle:[self.game.answerCN objectAtIndex:4] forState:UIControlStateNormal];
    //[self.answer1Btn setTitle:@"和TA度蜜月" forState:UIControlStateNormal];
    //[self.answer2Btn setTitle:@"和TA度蜜月" forState:UIControlStateNormal];
    //[self.answer3Btn setTitle:@"一二三四五" forState:UIControlStateNormal];
    //[self.answer4Btn setTitle:@"和TA度蜜月" forState:UIControlStateNormal];
    //[self.answer5Btn setTitle:@"120%变身" forState:UIControlStateNormal];
    
    [super configureOptionBtn:self.answer1Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
    [super configureOptionBtn:self.answer2Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
    [super configureOptionBtn:self.answer3Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
    [super configureOptionBtn:self.answer4Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
    [super configureOptionBtn:self.answer5Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
    
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    [self.editableItems addObject:self.startBtn];
    [self.editableItems addObject:self.stopBtn];
    [self.editableItems addObject:self.deleteBtn];
    [self.editableItems addObject:self.answer1Btn];
    [self.editableItems addObject:self.answer2Btn];
    [self.editableItems addObject:self.answer3Btn];
    [self.editableItems addObject:self.answer4Btn];
    [self.editableItems addObject:self.answer5Btn];
    [self.editableItems addObject:self.itemBtn];
    [self.editableItems addObject:self.banBtn];
    [self.editableItems addObject:self.doneBtn];
    [self.editableItems addObject:self.backBtn];
    [self.editableItems addObject:self.recordBtn];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.answerBtnsArray = [NSArray arrayWithObjects:self.answer1Btn, self.answer2Btn, self.answer3Btn, self.answer4Btn, self.answer5Btn, nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.timer invalidate];
    [self.hammerTimer invalidate];
}

- (void)viewDidUnload
{
    [self setProgressBar:nil];
    [self setStartBtn:nil];
    [self setAnswer1Btn:nil];
    [self setAnswer2Btn:nil];
    [self setAnswer3Btn:nil];
    [self setAnswer4Btn:nil];
    [self setAnswer5Btn:nil];
    [self setStopBtn:nil];
    [self setDeleteBtn:nil];
    [self setItemBtn:nil];
    [self setBanBtn:nil];
    [self setDoneBtn:nil];
    [self setBackBtn:nil];
    [self setRecordBtn:nil];
    [self setTurnLabel:nil];
    [self setTurnValueLabel:nil];
    [self setGold1:nil];
    [self setGold22:nil];
    [self setGold21:nil];
    [self setGold31:nil];
    [self setGold32:nil];
    [self setGold33:nil];
    [self setGold41:nil];
    [self setGold42:nil];
    [self setGold43:nil];
    [self setGold44:nil];
    [self setGold52:nil];
    [self setGold51:nil];
    [self setGold55:nil];
    [self setGold54:nil];
    [self setGold53:nil];
    [self setRecordLabel:nil];
    [self setProgressLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setAnswer:nil];
    [self setAnswerBtnsArray:nil];
    [self setTimer:nil];
    [self setHammerTimer:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self stopBtnPressed:nil];
    if ([segue.identifier isEqualToString:@"backToPreRecordSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:self.index+1];
    }
}

- (IBAction)backPressed:(UIButton *)sender
{
    [self deleteBtnPressed:sender];
    [self stopBtnPressed:nil];
    [super backToMenu:sender];
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
        [UIViewCustomAnimation showAlert:@"请先录音"];
        return;
    }
    
    //self.progressLabel.text = @"0.0";
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

// Should be used to remove temp files on device !!
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
        //NSURL *url = [NSURL fileURLWithPath:self.recordFilePath];
        NSURL *url = [NSURL fileURLWithPath:[DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"]];
        NSError *err = nil;
        [fm removeItemAtPath:[url path] error:&err];
        if(err)
            NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        
        self.audioPlayer = nil;
        self.recorder = nil;
    }
}

- (IBAction)recordReleased:(UIButton *)sender 
{
    NSLog(@"done at %@ %@", [NSDate date], DOCUMENTS_FOLDER);
    if ([self stopRecording])
    {
        [self.timer invalidate];
    }
    
    self.recordStopped = YES;
}

- (IBAction)recordTapped:(UIButton *)sender 
{
    self.recordStopped = NO;
    NSString *fileNameConnection = @"_";
    NSString *fileNamePostfix = @".caf";
    NSString *fileName = [self.game.userID stringByAppendingString:fileNameConnection];
    fileName = [fileName stringByAppendingString:self.game.oppID];
    fileName = [fileName stringByAppendingString:fileNamePostfix];
    
    self.recordFilePath = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, fileName];
    
    self.game.audioPath = self.recordFilePath;
    self.game.audioFileName = fileName;
    //NSLog(@"fileName = %@", fileName);
    //NSLog(@"filepath = %@", self.recordFilePath);

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

- (void)recordProgress
{
    self.lengthOfRecord += 0.1;
    [self.progressBar setProgress:self.lengthOfRecord/self.max_record_length];
    self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.lengthOfRecord];
    if (self.lengthOfRecord > self.max_record_length)
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
        //[self.progressBar setProgress:1];
    }
    else
    {
        self.lengthRemaining -= 0.1;
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f", self.lengthOfRecord-self.lengthRemaining];
        [self.progressBar setProgress:(self.lengthOfRecord - self.lengthRemaining)/self.lengthOfRecord];
    }
}

- (void)answerBtnPressed:(UIButton *)sender
{
    for (UIButton *btn in self.answerBtnsArray)
    {
        //NSLog(@"hello, %@", btn.currentTitle);
        btn.selected = NO;
        btn.alpha = BTN_FADED;
        self.gold1.alpha = BTN_FADED;
        self.gold21.alpha = BTN_FADED;
        self.gold22.alpha = BTN_FADED;
        self.gold31.alpha = BTN_FADED;
        self.gold32.alpha = BTN_FADED;
        self.gold33.alpha = BTN_FADED;
        self.gold41.alpha = BTN_FADED;
        self.gold42.alpha = BTN_FADED;
        self.gold43.alpha = BTN_FADED;
        self.gold44.alpha = BTN_FADED;
        self.gold51.alpha = BTN_FADED;
        self.gold52.alpha = BTN_FADED;
        self.gold53.alpha = BTN_FADED;
        self.gold54.alpha = BTN_FADED;
        self.gold55.alpha = BTN_FADED;
    }
    
    sender.alpha = 1;
    sender.selected = YES;
    if ([sender.currentTitle isEqualToString:self.answer1Btn.currentTitle])
    {
        self.gold1.alpha = 1;
    }
    if ([sender.currentTitle isEqualToString:self.answer2Btn.currentTitle])
    {
        self.gold21.alpha = 1;
        self.gold22.alpha = 1;
    }
    if ([sender.currentTitle isEqualToString:self.answer3Btn.currentTitle])
    {
        self.gold31.alpha = 1;
        self.gold32.alpha = 1;
        self.gold33.alpha = 1;
    }
    if ([sender.currentTitle isEqualToString:self.answer4Btn.currentTitle])
    {
        self.gold41.alpha = 1;
        self.gold42.alpha = 1;
        self.gold43.alpha = 1;
        self.gold44.alpha = 1;
    }
    if ([sender.currentTitle isEqualToString:self.answer5Btn.currentTitle])
    {
        self.gold51.alpha = 1;
        self.gold52.alpha = 1;
        self.gold53.alpha = 1;
        self.gold54.alpha = 1;
        self.gold55.alpha = 1;
    }
    //self.answer = sender.titleLabel.text;
}

- (IBAction)answer1BtnPressed:(UIButton *)sender 
{
    [self answerBtnPressed:sender];
    self.reward = 1;
    self.answer = [self.game.answerID objectAtIndex:0];
}

- (IBAction)answer2BtnPressed:(UIButton *)sender 
{
    [self answerBtnPressed:sender];
    self.reward = 2;
    self.answer = [self.game.answerID objectAtIndex:1];
}

- (IBAction)answer3BtnPressed:(UIButton *)sender 
{
    [self answerBtnPressed:sender];
    self.reward = 3;
    self.answer = [self.game.answerID objectAtIndex:2];
}

- (IBAction)answer4BtnPressed:(UIButton *)sender 
{
    [self answerBtnPressed:sender];
    self.reward = 4;
    self.answer = [self.game.answerID objectAtIndex:3];
}

- (IBAction)answer5BtnPressed:(UIButton *)sender 
{
    [self answerBtnPressed:sender];
    self.reward = 5;
    self.answer = [self.game.answerID objectAtIndex:4];
}

- (IBAction)confirmPressed:(UIButton *)sender 
{
    if (!self.answer)
    {
        [UIViewCustomAnimation showAlert:@"请选择一个题目"];
        return;
    }
    
    if (!self.audioPath)
    {
        [UIViewCustomAnimation showAlert:@"请先录音"];
        return;
    }
    
    /*
    if (self.game.startOfGame)
    {
        self.game.startOfGame = NO;
        Player *oppPlayer = [Player playerWithID:self.game.oppID];
        [oppPlayer joinGame:self.game WithPlayer:self.user];
        
        [self.game finishRecordingForPlayer:self.user WithPath:self.audioPath forAnswer:self.answer withReward:self.reward];
        
        [self backToMenu:sender];
        
        return
    }*/
    self.game.delegate = self;
    
    [self.game uploadForPlayer:self.user.ID withOppID:self.game.oppID isComment:FALSE];
    /*
    [self.game finishRecordingForPlayer:self.user
                               WithPath:self.audioPath
                              forAnswer:self.answer
                             withReward:self.reward];
     */
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    //[self backToMenu:sender];
}

- (IBAction)banPressed:(UIButton *)sender
{
    self.game.delegate = self;
    [super banGame:self.game];
}
- (IBAction)itemPressed:(UIButton *)sender
{
    if (self.user.inventory.numOfHammers <= 0)
    {
        [UIViewCustomAnimation showAlert:@"您没有足够的锤子"];
        return;
    }
    
    self.user.inventory.delegate = self;
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    [self.user.inventory usesHammerWithAmount:1 oppID:self.game.oppID option:HAMMER_USAGE_OPTION_REFRESH];
}

- (void)animateHammer
{   
    [self performSegueWithIdentifier:@"backToPreRecordSeg" sender:nil];
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
            [self.game finishRecordingForPlayer:self.user
                                       WithPath:self.audioPath
                                      forAnswer:self.answer
                                     withReward:self.reward];
            break;
        case REQUEST_TYPE_FINISH_RECORDING:
            [self stopBtnPressed:nil];
            [self backToMenu:nil];
            break;
            
        case REQUEST_TYPE_BAN_PLAYER:
            [UIViewCustomAnimation showAlert:@"屏蔽成功！\n在设置中可解除屏蔽"];
            self.user.delegate = self;
            [self.user exitGame:self.game];
            if (self.game.startOfGame)
            {
                [self stopBtnPressed:nil];
                [self backToMenu:nil];
            }
            break;
            
        case REQUEST_TYPE_DELETE_GAME:
            NSLog(@"%@", serverResponse);
            [self stopBtnPressed:nil];
            [self backToMenu:nil];
            break;
            
        case REQUEST_TYPE_USE_HAMMER:
            if ([serverResponse objectForKey:@"hammer"]==[NSString stringWithFormat:@"%d", HAMMER_USE_STATUS_NO_MORE_HAMMER])
            {
                [UIViewCustomAnimation showAlert:@"您的锤子数目不够"];
                return;
            }
            
            self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_hammer" ofType:@"wav"]
                                                              volumn:0.4];
            [self.sePlayer play];
            [super configureOptionBtn:self.answer1Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
            [super configureOptionBtn:self.answer2Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
            [super configureOptionBtn:self.answer3Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
            [super configureOptionBtn:self.answer4Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
            [super configureOptionBtn:self.answer5Btn cracked:YES menuVCType:MENU_VIEW_CONTROLLER_TYPE_RECORD];
            self.user.inventory.numOfHammers = [[serverResponse objectForKey:@"hammer"] integerValue];
            self.game.playerGameState = GAMESTATE_PRE_RECORD;
            
            self.hammerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                target:self
                                                              selector:@selector(animateHammer)
                                                              userInfo:nil
                                                               repeats:NO];
            break;
            
            
        default:
            break;
    }
}

@end
