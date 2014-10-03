//
//  GameViewController.h
//  Guess
//
//  Created by Rui Du on 7/10/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>
#import <AudioToolbox/AudioServices.h>

#define GAME_AUDIO_VOLUMN 10

typedef enum
{
    MENU_VIEW_CONTROLLER_TYPE_RECORD = 1,
    MENU_VIEW_CONTROLLER_TYPE_GUESS = 2
}MenuViewControllerType;

@class Player;
@class GuessGame;

@interface GameViewController : UIViewController<AVAudioRecorderDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index;
- (void)viewDidLoad;
- (void)backToMenu:(UIButton *)sender;
- (void)backToLogin;
- (BOOL)startRecording;
- (BOOL)stopRecording;
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;
- (void)banGame:(GuessGame *)game;
- (NSString *)getTurnString:(int)turn;
- (void)configureOptionBtn:(UIButton *)btn
                   cracked:(BOOL)isCracked
                menuVCType:(MenuViewControllerType)type;
- (void)animateReward;
- (void)animateResultTopViews:(NSArray *)topArray
                     midViews:(NSArray *)midArray
                     btmViews:(NSArray *)btmArray
                   resultGold:(int)resultGold
                    resultExp:(int)resultExp
                      vipGold:(int)vipGold
                       vipExp:(int)vipExp;
- (BOOL)validateUserAndGame;
- (BOOL)checkServerResponse:(int)code;
- (void)showErrorAlert;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
