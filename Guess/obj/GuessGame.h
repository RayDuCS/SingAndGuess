//
//  GuessGame.h
//  Guess
//
//  Created by Rui Du on 6/14/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpConn.h"

@class Player;

@protocol GuessGameSpinnerDelegate <NSObject>

@required
- (void)requestDidFinish:(BOOL)success
            withResponse:(NSDictionary *)serverResponse
                withType:(RequestType)type;;

@end

@interface GuessGame : NSObject<HttpConnDelegate>

typedef enum 
{
    GAMESTATE_WAIT = 101,           // Opp turn
    GAMESTATE_ACCEPT = 102,         // Accept the game
    GAMESTATE_PRE_RECORD = 103,     // Before recording, topic needs chosen
    GAMESTATE_RECORD = 104,         // Topic chosen, do record
    GAMESTATE_GUESS = 105,          // Make a guess
    GAMESTATE_RESULT = 106,         // Needs display result
    GAMESTATE_DELETED = 107         // Game has been deleted by opp player
}GameState;

typedef enum
{
    GAME_OPTION_THEME_RANDOM = 15,      // random
    GAME_OPTION_THEME_NATURE = 11,      // life
    GAME_OPTION_THEME_EMOTION = 12,     // emotion
    GAME_OPTION_THEME_CHARACTER = 13,   // scene
    GAME_OPTION_THEME_GOODS = 14,       // magic
    GAME_OPTION_THEME_SCENE = 16,       // film
    GAME_OPTION_THEME_SONG = 17,        // song
    GAME_OPTION_THEME_MOVIE = 18,       // tv
    GAME_OPTION_THEME_CARTOON = 19       // game
}GameOptionTheme;

@property (weak, nonatomic) id delegate;

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *oppID;
@property (strong, nonatomic) NSString *oppNickname;
@property (nonatomic) int oppLevel;
@property (nonatomic) BOOL oppSex;
@property (nonatomic) int oppDayOfVIP;

@property (nonatomic) GameState playerGameState;
@property (nonatomic) int round;
@property (strong, nonatomic) NSString *answer;
//@property (strong, nonatomic) NSString *answerID;
@property (strong, nonatomic) NSString *audioPath;
@property (strong, nonatomic) NSString *audioFileName;
@property (strong, nonatomic) NSString *commentPath;
@property (strong, nonatomic) NSString *guess;
@property (nonatomic) int reward;
@property (nonatomic) BOOL startOfGame;
@property (nonatomic) BOOL vipEnpowered;
@property (nonatomic) BOOL snoozable;

@property (weak, nonatomic) NSDictionary * serverResponse;
@property (strong, nonatomic) HttpConn *httpConn;
//@property (strong, nonatomic) Player *tempPlayer;
/*
@property (strong, nonatomic) NSString *option1;
@property (strong, nonatomic) NSString *option2;
@property (strong, nonatomic) NSString *option3;
@property (strong, nonatomic) NSString *option4;
@property (strong, nonatomic) NSString *option5;
@property (strong, nonatomic) NSString *idoption1;
@property (strong, nonatomic) NSString *idoption2;
@property (strong, nonatomic) NSString *idoption3;
@property (strong, nonatomic) NSString *idoption4;
@property (strong, nonatomic) NSString *idoption5;
*/
@property (strong, nonatomic) NSMutableArray *answerCN;
@property (strong, nonatomic) NSMutableArray *answerID;
@property (nonatomic) int hammerUsed;    // 0 -- not used, 1 -- used
@property (nonatomic) int crackedOption1;
@property (nonatomic) int crackedOption2;
@property (nonatomic) GameOptionTheme themeID;


- (void)finishAcceptGameForPlayer:(Player *)player;

- (void)finishShowResultForPlayer:(Player *)player;

- (void)startRecordingForPlayer:(Player *)player;

//- (void)uploadFinishRecordingForPlayer:(NSString *)userID withOppID:(NSString *)oppID;
- (void)uploadForPlayer:(NSString *)userID withOppID:(NSString *)oppID isComment:(BOOL)isComment;

- (void)finishRecordingForPlayer:(Player *)player
                        WithPath:(NSString *)audioPath
                       forAnswer:(NSString *)answer
                      withReward:(int)reward;

- (void)finishGuessingForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath;

- (void)finishContinueForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath;

-(void)downloadFileForUser:(NSString*)userID FromOpp:(NSString*)oppID isComment:(BOOL)isComment;
- (void)downloadFileFrom:(NSString *)filePath;

- (void)banOppPlayer;

- (void)getOppPortrait;

+ (int)getExpForTurn:(int)turn;

- (GuessGame *)initWithUser:(Player *)user
                     andOpp:(Player *)opp
               andGameState:(GameState)gameState;

- (GuessGame *)initWithUserID:(NSString *)userID
                     andOppID:(NSString *)oppID
               andOppNickname:(NSString *)oppNickname
                  andOppLevel:(int)oppLevel
                    andOppSex:(BOOL)oppSex
               andOppDayOfVIP:(int)oppDayOfVIP
           usePlayerGameState:(GameState)playerGameState
                     andRound:(int)round
                   withAnswer:(NSString *)answer
                withAudioPath:(NSString *)audioPath
                   withReward:(int)reward
                    withGuess:(NSString *)guess
              withCommentPath:(NSString *)commentPath
                    snoozable:(BOOL)snoozable
                 vipEnpowered:(BOOL)vipEnpowered
                    andValues:(NSArray *)values;


- (void)nextStateforPlayer:(Player *)player;

@end
