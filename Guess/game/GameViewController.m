//
//  GameViewController.m
//  Guess
//
//  Created by Rui Du on 7/10/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "UIViewCustomAnimation.h"
#import "GameViewController.h"
#import "MenuViewController.h"
#import "UserView.h"
#import "OppView.h"
#import "Player.h"
#import "GuessGame.h"
#import "UICustomFont.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface GameViewController ()

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) GuessGame *game;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;

@property (strong, nonatomic) NSDictionary *recordSettings;
@property (strong, nonatomic) NSString *recordFilePath;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *audioPath;
@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;
@property (strong, nonatomic) NSTimer *animateTimer;
@property (strong, nonatomic) NSTimer *animateArrayTimer;
@property (weak, nonatomic) NSDictionary *userInfo;
@property (nonatomic) int timerCount;
@property (nonatomic) int finalExp;
@property (nonatomic) int finalGold;

@property (nonatomic) BOOL recordStopped;
@property (nonatomic) int popIndex;

@property (strong, nonatomic) AVAudioPlayer *sePlayer;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation GameViewController

@synthesize user = _user;
@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize game = _game;
@synthesize popIndex = _popIndex;
@synthesize recorder = _recorder;
@synthesize audioPlayer = _audioPlayer;
@synthesize recordFilePath = _recordFilePath;
@synthesize recordSettings = _recordSettings;
@synthesize recordStopped = _recordStopped;
@synthesize audioPath = _audioPath;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize animateTimer = _animateTimer;
@synthesize animateArrayTimer = _animateArrayTimer;
@synthesize timerCount = _timerCount;
@synthesize sePlayer = _sePlayer;
@synthesize finalExp = _finalExp;
@synthesize finalGold = _finalGold;
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

- (void)unpackUserInfo
{
    self.spinner = [self.userInfo objectForKey:@"spinner"];
    
    self.editableItems = [self.userInfo objectForKey:@"editableItems"];
    
    self.userView = [self.userInfo objectForKey:@"userView"];
    
    self.oppView = [self.userInfo objectForKey:@"oppView"];
}

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    self.user = user;
    self.game = game;
    self.userInfo = userInfo;
    self.popIndex = index;
    
    [self unpackUserInfo];
}

-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
    
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //[audioSession setActive:YES error:nil];
     
    
    
    /*
    self.recordSettings = [[NSMutableDictionary alloc] init];
    
    [self.recordSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [self.recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
    [self.recordSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];    
    [self.recordSettings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [self.recordSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [self.recordSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
     */
    
    // kAudioFormatAppleIMA4
    // 44100, 32000, 24000, 16000, 12000
    
    /*
    self.recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                           [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                           [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                           [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                           [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                           [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                           nil];
    */
    
    self.recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                           [NSNumber numberWithFloat:12000], AVSampleRateKey,
                           [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                           [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                           [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                           [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                           nil];
    
    
    NSError *err;
     
    [[NSFileManager defaultManager] removeItemAtPath:[DOCUMENTS_FOLDER stringByAppendingFormat:@"/record.caf"] error:&err];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setUser:nil];
    [self setGame:nil];
    [self setUserView:nil];
    [self setOppView:nil];
    [self setRecorder:nil];
    [self setRecordFilePath:nil];
    [self setRecordSettings:nil];
    [self setAudioPath:nil];
    [self setAudioPlayer:nil];
    [self setSpinner:nil];
    [self setShade:nil];
    [self setEditableItems:nil];
    [self setAnimateTimer:nil];
    [self setAnimateArrayTimer:nil];
    [self setSpinnerTimer:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userView = [self.userView initWithPlayer:self.user];
    self.oppView = [self.oppView initWithGame:self.game];
    
    [self.view addSubview:self.userView.view];
    [self.view addSubview:self.oppView.view];
    
    [self setShade:nil];
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.view addSubview:self.shade];
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    
    self.spinner = [self.spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    //[[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self setShade:nil];
    
    [self.userView.view removeFromSuperview];
    [self.oppView.view removeFromSuperview];
    [self.editableItems removeAllObjects];
    [self.animateTimer invalidate];
    [self.animateArrayTimer invalidate];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    [self setAnimateTimer:nil];
    [self setAnimateArrayTimer:nil];
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
    // Add code to clean up any of your own resources that are no longer necessary.
    if ([self.view window] == nil)
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        self.view = nil;
    }
}

- (void)spinnerTimeout
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    //[UIViewCustomAnimation showAlert:@"连接超时"];
}

- (BOOL)validateUserAndGame
{
    if (!self.user)             return FALSE;
    if (!self.user.inventory)   return FALSE;
    if (!self.game)             return FALSE;
    if (!self.game.userID)      return FALSE;
    if (!self.game.oppID)       return FALSE;
    
    return TRUE;
}

- (BOOL)checkServerResponse:(int)code
{
    if (code == E_BAD_DATA) {
        [UIViewCustomAnimation showAlert:@"服务器故障，请重新操作"];
        return FALSE;
    }
    else if (code == E_WRONG_SESSION) {
        [self showWrongSession];
        return FALSE;
    }
    
    return TRUE;
}

- (void)showErrorAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                                        message:[NSString stringWithFormat:@"服务器又抽了！请重新登陆"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"只能这样了", nil];
    [alertView show];
}

- (void)showWrongSession
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                                        message:[NSString stringWithFormat:@"登陆过期了！请重新登陆"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"只能这样了", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"只能这样了"])
    {
        [self backToLogin];
    }
}

- (void)backToMenu:(UIButton *)sender
{
    UIViewController *vc = self.presentingViewController;
    
    for (int i=0; i<self.popIndex; i++)
    {
        vc = vc.presentingViewController;
    }
    
    MenuViewController *menu = (MenuViewController *)vc;
    [vc dismissModalViewControllerAnimated:YES];
    [menu reloadData];
}

- (void)backToLogin
{
    UIViewController *vc = self.presentingViewController;
    
    for (int i=0; i<self.popIndex+1; i++)
    {
        vc = vc.presentingViewController;
    }

    [vc dismissModalViewControllerAnimated:YES];
}

- (NSString *)getTurnUnitString:(int)turn
{
    // Has to be 0-9
    /*
    if (turn == 1) return @"壹";
    if (turn == 2) return @"贰";
    if (turn == 3) return @"叁";
    if (turn == 4) return @"肆";
    if (turn == 5) return @"伍";
    if (turn == 6) return @"陆";
    if (turn == 7) return @"柒";
    if (turn == 8) return @"捌";
    if (turn == 9) return @"玖";
    if (turn == 0) return @"零";
     */
    if (turn == 1) return @"一";
    if (turn == 2) return @"二";
    if (turn == 3) return @"三";
    if (turn == 4) return @"四";
    if (turn == 5) return @"五";
    if (turn == 6) return @"六";
    if (turn == 7) return @"七";
    if (turn == 8) return @"八";
    if (turn == 9) return @"九";
    if (turn == 0) return @"零";
    
    return @"？";
}

- (void)animateReward
{
    int i = 0;
    float offset = 12;
    for (i=0; i<self.game.reward; i++)
    {
        UIImageView *goldImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gold.png"]];
        goldImgView.frame = CGRectMake(195+offset*i, 195, 40, 40);
        [self.view addSubview:goldImgView];
        [UIView animateWithDuration:1
                              delay:0.2*i
                            options:UIViewAnimationCurveLinear
                         animations:^(){
                             goldImgView.frame = CGRectMake(65, 35, 26, 26);
                         }
                         completion:^(BOOL finished){
                             if (self.user.gold >= self.finalGold) return;
                             
                             self.user.gold += 1;
                             [self.userView animateGoldImage];
                             [self.userView reloadWithPlayer:self.user];
                         }];
    }
}

- (void)animateRewardTimer:(NSTimer *)timer
{
    int i = 0;
    //float offset = 12;
    NSDictionary *userInfo = [timer userInfo];
    int x = [[userInfo objectForKey:@"xStr"] intValue];
    int y = [[userInfo objectForKey:@"yStr"] intValue];
    /*
    self.user.exp += [[userInfo objectForKey:@"exp"] intValue];
    [self.userView reloadWithPlayer:self.user];
     */
    if (self.user.exp < self.finalExp) {
        [self.userView tryAnimateLevelUp:[[userInfo objectForKey:@"exp"] intValue]];
    }
    
    for (i=0; i<[[userInfo objectForKey:@"gold"] intValue]; i++)
    {
        UIImageView *goldImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gold.png"]];
        goldImgView.frame = CGRectMake(x, y, 26, 26);
        [self.view addSubview:goldImgView];
        [UIView animateWithDuration:1
                              delay:0.2*i
                            options:UIViewAnimationCurveLinear
                         animations:^(){
                             goldImgView.frame = CGRectMake(65, 35, 26, 26);
                         }
                         completion:^(BOOL finished){
                             
                             if (self.user.gold >= self.finalGold) return;
                             
                             self.user.gold += 1;
                             [self.userView animateGoldImage];
                             [self.userView reloadWithPlayer:self.user];
                         }];
    }
}

- (void)animateArray:(NSArray *)array
             goldStr:(NSString *)goldStr
              expStr:(NSString *)expStr
                xStr:(NSString *)xStr
                yStr:(NSString *)yStr
{
    for (UIView *view in array)
    {
        [UIView animateWithDuration:1
                              delay:0.01
                            options:UIViewAnimationCurveLinear
                         animations:^() {
                             view.alpha = 1;
                             [UIViewCustomAnimation heartbeatAnimationForView:view
                                                                        ratio:1.08
                                                                     duration:0.5
                                                                       repeat:1];
                         }completion:^(BOOL finished) {
                         }];
    }
    
    if ([goldStr intValue]!=0 || [expStr intValue]!=0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:goldStr, @"gold", expStr, @"exp", xStr, @"xStr", yStr, @"yStr", nil];
        self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                             target:self
                                                           selector:@selector(animateRewardTimer:)
                                                           userInfo:userInfo
                                                            repeats:NO];
        
    }
}

- (void)animateArrayTimer:(NSTimer *)timer
{
    NSDictionary *userInfo = [timer userInfo];
    NSArray *array;
    NSString *goldStr, *expStr, *xStr, *yStr;
    
    self.timerCount++;
    if (self.timerCount == 1) {
        array = [userInfo objectForKey:@"topArray"];
        goldStr = @"0";
        expStr = @"0";
        xStr = @"0";
        yStr = @"0";
    }
    else if (self.timerCount == 2) {
        array = [userInfo objectForKey:@"midArray"];
        goldStr = [userInfo objectForKey:@"resultGold"];
        expStr = [userInfo objectForKey:@"resultExp"];
        xStr = [userInfo objectForKey:@"midX"];
        yStr = [userInfo objectForKey:@"midY"];
    }
    else if (self.timerCount == 3) {
        array = [userInfo objectForKey:@"btmArray"];
        goldStr = [userInfo objectForKey:@"vipGold"];
        expStr = [userInfo objectForKey:@"vipExp"];
        xStr = [userInfo objectForKey:@"btmX"];
        yStr = [userInfo objectForKey:@"btmY"];
    }
    else {
        [self.animateArrayTimer invalidate];
        return;
    }
    
    [self animateArray:array goldStr:goldStr expStr:expStr xStr:xStr yStr:yStr];
}

- (void)animateResultTopViews:(NSArray *)topArray
                     midViews:(NSArray *)midArray
                     btmViews:(NSArray *)btmArray
                   resultGold:(int)resultGold
                    resultExp:(int)resultExp
                      vipGold:(int)vipGold
                       vipExp:(int)vipExp
{
    self.timerCount = 1;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:topArray, @"topArray", midArray, @"midArray", btmArray, @"btmArray", [NSString stringWithFormat:@"%d", resultGold], @"resultGold", [NSString stringWithFormat:@"%d", resultExp], @"resultExp", [NSString stringWithFormat:@"%d", vipGold], @"vipGold", [NSString stringWithFormat:@"%d", vipExp], @"vipExp", @"123", @"midX", @"207", @"midY", @"123", @"btmX", @"250", @"btmY" ,nil];
    
    [self animateArray:topArray goldStr:@"0" expStr:@"0" xStr:@"0" yStr:@"0"];
    self.animateArrayTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                              target:self
                                                            selector:@selector(animateArrayTimer:)
                                                            userInfo:userInfo repeats:YES];
}

- (NSString *)getTurnRestStringWithTensDigit:(int)tensDigit
                               hundredsDigit:(int)hundredsDigit
                              thousandsDigit:(int)thousandsDigit

{
    NSString *hundreds, *tens, *thousands;
    
    if (thousandsDigit>0)
    {
        thousands = [self getTurnUnitString:thousandsDigit];
        hundreds = [self getTurnUnitString:hundredsDigit];
        tens = [self getTurnUnitString:tensDigit];
        return [NSString stringWithFormat:@"%@%@%@", thousands, hundreds, tens];
    }
    
    if (hundredsDigit > 0)
    {
        hundreds = [self getTurnUnitString:hundredsDigit];
        tens = [self getTurnUnitString:tensDigit];
        return [NSString stringWithFormat:@"%@%@", hundreds, tens];
    }
    
    if (tensDigit > 0)
    {
        tens = [self getTurnUnitString:tensDigit];
        return tens;
    }
    
    return @"";
}

- (NSString *)getTurnString:(int)turn
{
    NSString *unitsString, *restString;
    int unitsDigit, tensDigit, hundredsDigit, thousandsDigit;
    
    int turnCopied = turn;
    unitsDigit = turnCopied % 10;
    unitsString = [self getTurnUnitString:unitsDigit];
    
    turnCopied = turnCopied / 10;
    tensDigit = turnCopied % 10;
    turnCopied = turnCopied / 10;
    hundredsDigit = turnCopied % 10;
    turnCopied = turnCopied / 10;
    thousandsDigit = turnCopied % 10;
    
    restString = [self getTurnRestStringWithTensDigit:tensDigit hundredsDigit:hundredsDigit thousandsDigit:thousandsDigit];
    if (thousandsDigit >0) return [restString stringByAppendingString:unitsString];
    return [[restString stringByAppendingString:unitsString] stringByAppendingString:@"轮"];
}

- (BOOL)startRecording
{
    if (self.recorder)
    {
        [UIViewCustomAnimation showAlert:@"请先删除已有录音"];
        return NO;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    err = nil;
    //NSURL *url = [NSURL fileURLWithPath:self.recordFilePath];
    NSURL *url = [NSURL fileURLWithPath:[DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"]];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recordSettings error:&err];
    if(!self.recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        [UIViewCustomAnimation showAlert:[NSString stringWithFormat:@"录音失败:%@", [err localizedDescription]]];
        return NO;
    }
    
    //prepare to record
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    self.recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        [UIViewCustomAnimation showAlert:@"无法检测到音频硬件"];
        return NO;
    }
    
    // start recording
    [self.recorder record];
    //[recorder recordForDuration:(NSTimeInterval) 10];
    return YES;
}

- (BOOL)stopRecording
{
    if (self.recordStopped)
        return NO;
    
    [self.recorder stop];
    
    NSError *err = nil;
    NSURL *url = [NSURL fileURLWithPath:[DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"]];
    //NSURL *url = [NSURL fileURLWithPath:self.recordFilePath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (!self.audioPlayer)
    {
        NSLog(@"Player: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        [UIViewCustomAnimation showAlert:[err localizedDescription]];
        return NO;
    }
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    //self.audioPlayer.volume = GAME_AUDIO_VOLUMN;
    [self.audioPlayer prepareToPlay];
    self.audioPath = [self.recordFilePath copy];
    
    return YES;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    
}

- (void)banGame:(GuessGame *)game
{
    self.game = game;
    UIActionSheet *mymenu = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                             otherButtonTitles:nil];
    
    [mymenu addButtonWithTitle:@"屏蔽该玩家"];
    mymenu.cancelButtonIndex = [mymenu addButtonWithTitle: @"取消"];
    [mymenu showInView:self.view];
}

- (GameOptionTheme)getThemeFromID:(NSString *)answerID
{
    return [[answerID substringToIndex:2] integerValue];
    
}

- (UIImage *)getImageForThemeID:(GameOptionTheme)themeID
                    orientation:(BOOL)isVertical
                        cracked:(BOOL)isCracked
{
    
    switch (themeID) {
        case GAME_OPTION_THEME_CHARACTER:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_scene_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_scene_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_scene_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_scene_r"];
            break;
        case GAME_OPTION_THEME_EMOTION:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_emotion_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_emotion_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_emotion_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_emotion_r"];
            break;
        case GAME_OPTION_THEME_GOODS:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_magic_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_magic_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_magic_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_magic_r"];
            break;
        case GAME_OPTION_THEME_NATURE:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_life_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_life_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_life_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_life_r"];
            break;
        case GAME_OPTION_THEME_RANDOM:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_random_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_random_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_random_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_random_r"];
            break;
        case GAME_OPTION_THEME_SCENE:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_film_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_film_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_film_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_film_r"];
            break;
        case GAME_OPTION_THEME_SONG:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_song_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_song_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_song_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_song_r"];
            break;
        case GAME_OPTION_THEME_CARTOON:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_game_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_game_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_game_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_game_r"];
            break;
        case GAME_OPTION_THEME_MOVIE:
            if (isCracked && isVertical) return [UIImage imageNamed:@"game_tv_cracked_v"];
            if (isCracked && !isVertical) return [UIImage imageNamed:@"game_tv_cracked_r"];
            if (!isCracked && isVertical) return [UIImage imageNamed:@"game_tv_v"];
            if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_tv_r"];
            break;
    }
    
    if (isCracked && isVertical) return [UIImage imageNamed:@"game_random_cracked_v"];
    if (isCracked && !isVertical) return [UIImage imageNamed:@"game_random_cracked_r"];
    if (!isCracked && isVertical) return [UIImage imageNamed:@"game_random_v"];
    if (!isCracked && !isVertical) return [UIImage imageNamed:@"game_random_r"];
    
    return nil;
}

- (UIImage *)getImageForBtn:(UIButton *)btn
                orientation:(BOOL)isVertical
                    cracked:(BOOL)isCracked
{
    GameOptionTheme themeID = GAME_OPTION_THEME_RANDOM;
    for (int i=0; i<self.game.answerCN.count; i++)
    {
        if ([btn.currentTitle isEqualToString:[self.game.answerCN objectAtIndex:i]])
        {
            themeID = [self getThemeFromID:[self.game.answerID objectAtIndex:i]];
            break;
        }
    }
    
    return [self getImageForThemeID:themeID orientation:isVertical cracked:isCracked];
}

- (UIFont *)getFontForGuessBtn:(UIButton *)btn
                          text:(NSString *)text
                          type:(MenuViewControllerType)type
{
    UIFont *font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    
    int i;
    for(i = 27; i > 5; i=i-2)
    {
        font = [font fontWithSize:i];
        
        CGSize constraintSize = CGSizeMake(40.0f, MAXFLOAT);
        CGSize labelSize = [text sizeWithFont:font
                            constrainedToSize:constraintSize
                                lineBreakMode:UILineBreakModeWordWrap];
        
        switch (type) {
            case MENU_VIEW_CONTROLLER_TYPE_GUESS:
                if(labelSize.height <= 160.0f)
                    return font;
                break;
            case MENU_VIEW_CONTROLLER_TYPE_RECORD:
                if(labelSize.height <= 95.0f)
                    return font;
                break;
        }
        
    }
    
    return font;
}

- (void)rotateBtn:(UIButton *)button
{
    CGFloat x = button.frame.origin.x;
    CGFloat y = button.frame.origin.y;
    CGFloat width = button.frame.size.width;
    CGFloat height = button.frame.size.height;
    
    CGPoint center = CGPointMake(x + width/2, y + height/2);
    
    button.frame = CGRectMake(center.x - height/2, center.y - width/2, height, width);
}

- (void)showBtnVertical:(UIButton *)button
                cracked:(BOOL)isCracked
             menuVCType:(MenuViewControllerType)type
{
    if (isCracked) return;
    
    //[self rotateBtn:button];
    
    switch (type) {
        case MENU_VIEW_CONTROLLER_TYPE_GUESS:
            [button setContentEdgeInsets:UIEdgeInsetsMake(40, 10, 5, 10)];
            break;
        case MENU_VIEW_CONTROLLER_TYPE_RECORD:
            [button setContentEdgeInsets:UIEdgeInsetsMake(40, 10, 35, 10)];
            break;
    }
    
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
}

- (void)showBtnHorizontal:(UIButton *)button
                  cracked:(BOOL)isCracked
               menuVCType:(MenuViewControllerType)type
{
    if (isCracked) return;
    
    [self rotateBtn:button];
    button.transform=CGAffineTransformMakeRotation(M_PI / 2);
    switch (type) {
        case MENU_VIEW_CONTROLLER_TYPE_GUESS:
            [button setContentEdgeInsets:UIEdgeInsetsMake(10, 43, 10, 3)];
            break;
        case MENU_VIEW_CONTROLLER_TYPE_RECORD:
            [button setContentEdgeInsets:UIEdgeInsetsMake(10, 43, 10, 35)];
            break;
    }
    
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
}
- (BOOL)isChinese:(NSString*) text
             type:(MenuViewControllerType)type
{
    NSLog(@"%d", text.length);
    for (int i=0; i<text.length-1; ++i)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [text substringWithRange:range];
        const char    *cString = [subString UTF8String];
        if (strlen(cString) == 3)
        {
        }
        else
        {
            int tmp = *cString;
            if((tmp >=65 && tmp <=90) ||(tmp >=97 && tmp <=122))
            return FALSE;
        }
    }
    
    switch (type) {
        case MENU_VIEW_CONTROLLER_TYPE_GUESS:
            if (text.length-1 > 9) return FALSE;
            break;
        case MENU_VIEW_CONTROLLER_TYPE_RECORD:
            if (text.length-1 > 7) return FALSE;
            break;
    }
    // Text too long
    
    return TRUE;
}

- (void)configureOptionBtn:(UIButton *)btn
                   cracked:(BOOL)isCracked
                menuVCType:(MenuViewControllerType)type
{
    bool isVertical = [self isChinese:btn.currentTitle type:type];
    UIImage *image = [self getImageForBtn:btn orientation:isVertical cracked:isCracked];
    
    btn.titleLabel.font = [self getFontForGuessBtn:btn text:btn.currentTitle type:type];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:image forState:UIControlStateSelected];
    [btn setBackgroundImage:image forState:UIControlStateHighlighted];
    
    if (isVertical) [self showBtnVertical:btn cracked:isCracked menuVCType:type];
    else [self showBtnHorizontal:btn cracked:isCracked menuVCType:type];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"屏蔽该玩家"])
    {
        [self.game banOppPlayer];
        [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                             target:self
                                                           selector:@selector(spinnerTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

@end
