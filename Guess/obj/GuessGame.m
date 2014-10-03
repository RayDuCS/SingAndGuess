//
//  GuessGame.m
//  Guess
//
//  Created by Rui Du on 6/14/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "GuessGame.h"
#import "Player.h"
#import "Inventory.h"

@interface GuessGame()

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define gamesDataFile @"gamesData.plist"
#define userIDCoder @"UserEmail"
#define oppIDCoder @"OppEmail"
#define gameidCoder @"Gameid"
#define playerGameStateCoder @"PlayerGameState"
#define oppNicknameCoder @"OppNickname"
#define oppLeverCoder @"OppLevel"
#define oppSexCoder @"OppSex"
#define roundCoder @"Round"
#define gamesDataCoder @"GamesData"
#define answerCoder @"Answer"
#define audioPathCoder @"AudioPath"
#define rewardCoder @"Reward"
#define commentPathCoder @"CommentPathCoder"
#define guessCoder @"GuessCoder"
#define startOfGameCoder @"StartOfGame"

@end

@implementation GuessGame

@synthesize delegate = _delegate;

@synthesize userID = _userID;
@synthesize oppID = _oppID;
@synthesize oppDayOfVIP = _oppDayOfVIP;
@synthesize playerGameState = _playerGameState;
@synthesize oppNickname = _oppNickname;
@synthesize oppLevel = _oppLevel;
@synthesize oppSex = _oppSex;
@synthesize round = _round;
@synthesize answer = _answer;
//@synthesize answerID = _answerID;
@synthesize audioPath = _audioPath;
@synthesize audioFileName = _audioFileName;
@synthesize commentPath = _commentPath;
@synthesize reward = _reward;
@synthesize guess = _guess;
@synthesize startOfGame = _startOfGame;
@synthesize vipEnpowered = _vipEnpowered;
@synthesize snoozable = _snoozable;

@synthesize httpConn = _httpConn;
@synthesize serverResponse = _serverResponse;
@synthesize themeID = _themeID;
//@synthesize tempPlayer = _tempPlayer;
/*
@synthesize option1 = _option1;
@synthesize option2 = _option2;
@synthesize option3 = _option3;
@synthesize option4 = _option4;
@synthesize option5 = _option5;

@synthesize idoption1 = _idoption1;
@synthesize idoption2 = _idoption2;
@synthesize idoption3 = _idoption3;
@synthesize idoption4 = _idoption4;
@synthesize idoption5 = _idoption5;
 */

@synthesize answerCN = _answerCN;
@synthesize answerID = _answerID;
@synthesize crackedOption1 = _crackedOption1;
@synthesize crackedOption2 = _crackedOption2;
@synthesize hammerUsed = _hammerUsed;

/*
+ (NSString *)generateGameIDForPlayer:(NSString *)player1Email
                            andPlayer:(NSString *)player2Email
{
    NSComparisonResult result = [player1Email compare:player2Email];
    if (result == NSOrderedAscending)
    {
        return [NSString stringWithFormat:@"%@ vs %@", player1Email, player2Email];
    }
    else {
        return [NSString stringWithFormat:@"%@ vs %@", player2Email, player1Email];
    }
    
}*/

- (GuessGame *)initWithUser:(Player *)user andOpp:(Player *)opp andGameState:(GameState)gameState
{
    self = [super init];
    if (!self) return self;
    
    self.userID = user.ID;
    self.oppID = opp.ID;
    self.oppNickname = opp.nickname;
    self.oppLevel = opp.level;
    self.oppSex = opp.isMale;
    self.playerGameState = gameState;
    self.round = 1;
    self.startOfGame = TRUE;
    self.oppDayOfVIP = opp.inventory.dayOfVIP;
    //self.gameid = [GuessGame generateGameIDForPlayer:self.userEmail andPlayer:self.oppEmail];
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    
    
    return self;
}

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
                    andValues:(NSArray *)values
{
    self = [super init];
    if (!self) return self;
    
    self.userID = userID;
    self.oppID = oppID;
    self.oppNickname = oppNickname;
    self.oppLevel = oppLevel;
    self.oppSex = oppSex;
    self.oppDayOfVIP = oppDayOfVIP;
    self.playerGameState = playerGameState;
    self.round = round;
    self.answer = answer;
    self.audioPath = audioPath;
    self.reward = reward;
    self.guess = guess;
    self.commentPath = commentPath;
    self.snoozable = snoozable;
    self.vipEnpowered = vipEnpowered;
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    self.startOfGame = NO;
    self.hammerUsed = [(NSNumber *)[values objectAtIndex:0] integerValue];
    self.crackedOption1 = [(NSNumber *)[values objectAtIndex:1] integerValue];
    self.crackedOption2 = [(NSNumber *)[values objectAtIndex:2] integerValue];
    
    return self;
}

/*
+ (NSData *)loadFile
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, gamesDataFile]];
    NSData *gamesData = [[NSData alloc] initWithContentsOfURL:url];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:gamesData];
    gamesData = [unarchiver decodeObjectForKey:gamesDataCoder];
    [unarchiver finishDecoding];
    
    return gamesData;
}

- (void)saveGameWithUpdatedGames:(NSDictionary *)games
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, gamesDataFile]];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:games forKey:gamesDataCoder];
    [archiver finishEncoding];
    [data writeToURL:url atomically:YES];
}*/

/*
- (void)saveGame
{
    NSDictionary *games = (NSDictionary *)[GuessGame loadFile];
    if (!games)
    {
        games = [NSDictionary dictionaryWithObject:self forKey:self.gameid];
    }
    else
    {
        NSMutableDictionary *gamesChanged = [games mutableCopy];
        [gamesChanged setObject:self forKey:self.gameid];
        games = [gamesChanged copy];
    }
    
    [self saveGameWithUpdatedGames:games];
}
 */

- (void)updateOppGameforPlayer:(Player *)player
                  andOppPlayer:(Player *)oppPlayer
{
    self.oppLevel = player.level;
    
    [oppPlayer updateGame:self];
    
}

- (void)updateRewardFromPlayer:(Player *)oppPlayer
{
    GuessGame *game = [oppPlayer.gamesDict objectForKey:self.userID];
    self.reward = game.reward;
}

- (void)nextStateforPlayer:(Player *)player
{
    //Player *oppPlayer;
    //GuessGame *game;
    
    switch (self.playerGameState) 
    {
        case GAMESTATE_WAIT:
            self.playerGameState = GAMESTATE_GUESS;
            //[self updateRewardFromPlayer:[Player playerWithID:self.oppID]];
            break;
            
        case GAMESTATE_ACCEPT:
            self.playerGameState = GAMESTATE_GUESS;
            //[self updateRewardFromPlayer:[Player playerWithID:self.oppID]];
            break;
            
        case GAMESTATE_GUESS:
            self.playerGameState = GAMESTATE_PRE_RECORD;
            /*
            oppPlayer = [Player playerWithID:self.oppID];
            game = [oppPlayer.gamesDict objectForKey:self.userID];
            game.playerGameState = GAMESTATE_RESULT;
            game.commentPath = self.commentPath;
            game.reward = self.reward;
            [game updateOppGameforPlayer:player andOppPlayer:oppPlayer];
            */
            break;
            
        case GAMESTATE_PRE_RECORD:
            self.playerGameState = GAMESTATE_RECORD;
            break;
            
        case GAMESTATE_RECORD:
            self.playerGameState = GAMESTATE_WAIT;
            /*
            oppPlayer = [Player playerWithID:self.oppID];
            game = [oppPlayer.gamesDict objectForKey:self.userID];
            if (game.playerGameState == GAMESTATE_WAIT) game.playerGameState = GAMESTATE_GUESS;
            
            game.audioPath = self.audioPath;
            //game.reward = self.reward;
            game.answer = self.answer;
            [game updateOppGameforPlayer:player andOppPlayer:oppPlayer];
            */
            break;
            
        case GAMESTATE_RESULT:
            /*
            oppPlayer = [Player playerWithID:self.oppID];
            game = [oppPlayer.gamesDict objectForKey:self.userID];
            
            if (game.playerGameState == GAMESTATE_RECORD ||
                game.playerGameState == GAMESTATE_PRE_RECORD)
                self.playerGameState = GAMESTATE_WAIT;
            else
            {
                [self updateRewardFromPlayer:[Player playerWithID:self.oppID]];
                self.playerGameState = GAMESTATE_GUESS;
            }*/
            self.playerGameState = GAMESTATE_WAIT;
            
            break;
            
        default:
            break;
            
    }
    
    //[player updateGame:self];
}

- (void)finishAcceptGameForPlayer:(Player *)player
{
    [self.httpConn finishAcceptGameForPlayer:player forGame:self];
    //self.tempPlayer = player;
    
    //[self nextStateforPlayer:player];
}

- (void)finishShowResultForPlayer:(Player *)player
{
    /*
    [Player player:player.email GetReward:self.reward];
    player = [Player playerWithEmail:player.email];
    [self nextStateforPlayer:player];
     */
    
    [self.httpConn finishShowResultForPlayer:player forGame:self];
    //self.tempPlayer = player;
 
    //[self nextStateforPlayer:player];
}

- (void)startRecordingForPlayer:(Player *)player
{
    if (self.playerGameState != GAMESTATE_PRE_RECORD)
        return;
    
    [self.httpConn startRecordingForPlayer:player forGame:self];
    //self.tempPlayer = player;
    
    //[self nextStateforPlayer:player];
}

- (void)finishGuessingForPlayer:(Player *)player 
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath
{   
    [self.httpConn finishGuessingForPlayer:player WithGuess:guess andCommentPath:commentPath forGame:self];
    //self.tempPlayer = player;
    
    //[self nextStateforPlayer:player];
}

- (void)finishContinueForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath
{
    [self.httpConn finishContinueForPlayer:player WithGuess:guess andCommentPath:commentPath forGame:self];
    
    self.playerGameState = GAMESTATE_RECORD;
    [player updateGame:self];
}

- (void)uploadForPlayer:(NSString *)userID withOppID:(NSString *)oppID isComment:(BOOL)isComment
{
    [self.httpConn S3UploadFileForUser:userID withOppID:oppID isComment:isComment];
}

- (void)finishRecordingForPlayer:(Player *)player 
                        WithPath:(NSString *)audioPath 
                       forAnswer:(NSString *)answer
                      withReward:(int)reward
{
      [self.httpConn finishRecordingForPlayer:player
                                   WithPath:audioPath 
                                  forAnswer:answer 
                                 withReward:reward
                                    forGame:self];
}

+ (int)getExpForTurn:(int)turn
{
    int exp = 40 + (turn-1)*5;
    if (exp>=60) return 60;
    
    return exp;
}

- (void)banOppPlayer
{
    [self.httpConn banPlayerID:self.userID withTargetPlayerID:self.oppID];
}

-(void)downloadFileForUser:(NSString*)userID FromOpp: (NSString*) oppID isComment:(BOOL) isComment
{
    [self.httpConn S3DownloadFileForUser:userID fromOpp:oppID isComment:isComment];
}

- (void)downloadFileFrom:(NSString *)filePath
{
    [self.httpConn downloadFileFrom:filePath];
}

- (void)getOppPortrait
{
    NSString *path = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@/%@.png", self.userID, self.oppID];
    [self.httpConn getPortraitOfPlayerID:self.oppID storeAtPath:path];
}

/*
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userID forKey:userIDCoder];
    [aCoder encodeObject:self.oppID forKey:oppIDCoder];
    [aCoder encodeObject:self.oppNickname forKey:oppNicknameCoder];
    [aCoder encodeInt:self.oppLevel forKey:oppLeverCoder];
    [aCoder encodeBool:self.oppSex forKey:oppSexCoder];
    [aCoder encodeInt:self.playerGameState forKey:playerGameStateCoder];
    [aCoder encodeInt:self.round forKey:roundCoder];
    [aCoder encodeObject:self.answer forKey:answerCoder];
    [aCoder encodeObject:self.audioPath forKey:audioPathCoder];
    [aCoder encodeInt:self.reward forKey:rewardCoder];
    [aCoder encodeObject:self.guess forKey:guessCoder];
    [aCoder encodeObject:self.commentPath forKey:commentPathCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *userID = [aDecoder decodeObjectForKey:userIDCoder];
    NSString *oppID = [aDecoder decodeObjectForKey:oppIDCoder];
    NSString *oppNickname = [aDecoder decodeObjectForKey:oppNicknameCoder];
    int oppLevel = [aDecoder decodeIntForKey:oppLeverCoder];
    BOOL oppSex = [aDecoder decodeBoolForKey:oppSexCoder];
    int playerGameState = [aDecoder decodeIntForKey:playerGameStateCoder];
    int round = [aDecoder decodeIntForKey:roundCoder];
    NSString *answer = [aDecoder decodeObjectForKey:answerCoder];
    NSString *audioPath = [aDecoder decodeObjectForKey:audioPathCoder];
    int reward = [aDecoder decodeIntForKey:rewardCoder];
    NSString *guess = [aDecoder decodeObjectForKey:guessCoder];
    NSString *commentPath = [aDecoder decodeObjectForKey:commentPathCoder];
    
    return [self initWithUserID:userID
                       andOppID:oppID
                 andOppNickname:oppNickname
                    andOppLevel:oppLevel
                      andOppSex:oppSex
             usePlayerGameState:playerGameState
                       andRound:round
                     withAnswer:answer
                  withAudioPath:audioPath
                     withReward:reward
                      withGuess:guess
                withCommentPath:commentPath];
}*/

- (BOOL)checkResponseHasChoices:(NSDictionary *)response
{
    int numOfChoice = 5;
    for(int m = 0; m <numOfChoice; m++)
    {
        if (![response objectForKey:[NSString stringWithFormat:@"choice%d",m]])
            return FALSE;
        if (![response objectForKey:[NSString stringWithFormat:@"choice%dID",m]])
            return FALSE;
    }
    
    return TRUE;
}
- (NSArray *)getTokensOfDiscardString:(NSString *)discard
{
    if (discard.length < 3) {
        return [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], nil];
    }
    
    int usedHammer = 0;
    int option1, option2;
    if (discard.length > 4) usedHammer = 1;
    option1 = [discard characterAtIndex:0] - '0';
    option2 = [discard characterAtIndex:2] - '0';
    
    option1++;
    option2++;
    
    NSNumber *usedHammerNS = [NSNumber numberWithInt:usedHammer];
    NSNumber *option1NS = [NSNumber numberWithInt:option1];
    NSNumber *option2NS = [NSNumber numberWithInt:option2];
    return [[NSArray alloc] initWithObjects: usedHammerNS, option1NS, option2NS, nil];
}

- (void)loadAnswerIDAndCNForResponse:(NSDictionary *)response
{
    if (![self checkResponseHasChoices:response]) return;
    
    int  numOfChoice = 5;

    self.answerCN = [[NSMutableArray alloc]init];
    self.answerID = [[NSMutableArray alloc]init];
    for(int m = 0; m <numOfChoice; m++)
    {
        [self.answerCN  addObject:[response objectForKey:[NSString stringWithFormat:@"choice%d",m]]];
    }
    for(int m = 0; m <numOfChoice; m++)
    {
        [self.answerID  addObject:[response objectForKey:[NSString stringWithFormat:@"choice%dID",m]]];
    }
    //self.answerID
    self.answer = [response objectForKey:@"answer"];
    
    NSArray *values = [self getTokensOfDiscardString:[response objectForKey:@"discard"]];
    
    self.hammerUsed = [(NSNumber *)[values objectAtIndex:0] integerValue];
    self.crackedOption1 = [(NSNumber *)[values objectAtIndex:1] integerValue];
    self.crackedOption2 = [(NSNumber *)[values objectAtIndex:2] integerValue];
    
    
    //self.hammerUsed
    //self.crackedOption1 = [(NSNumber *)[values objectAtIndex:1] integerValue];
    //self.crackedOption2 = [(NSNumber *)[values objectAtIndex:2] integerValue];
    
    //self.
    //[self getTokensOfDiscardString:[gameDic objectForKey:@"discard"]];
    
}
- (void)didFinishSelector:(NSDictionary *)response withType:(RequestType)type
{
    self.serverResponse = response;
    switch (type) {
        case REQUEST_TYPE_START_RECORDING:
            NSLog(@"%@", response);
            
            if (!response) break;
            
            [self loadAnswerIDAndCNForResponse:response];
            
            self.startOfGame = NO;
            self.playerGameState = [[response objectForKey:@"gamestate"] integerValue];
            
            break;
            //break;
        case REQUEST_TYPE_FINISH_RECORDING:
            NSLog(@"%@", response);            
            self.playerGameState = [[response objectForKey:@"gamestate"] integerValue];
            break;
            //break;
        case REQUEST_TYPE_FINISH_ACCEPT:
            self.playerGameState = [[response objectForKey:@"gamestate"] integerValue];
            [self loadAnswerIDAndCNForResponse:response];
            self.startOfGame = NO;
            
            
            break;
        case REQUEST_TYPE_FINISH_CONTINUE:
        case REQUEST_TYPE_FINISH_GUESSING:
            self.playerGameState = [[response objectForKey:@"gamestate"] integerValue];
            break;
            
        case REQUEST_TYPE_FINISH_SHOW_RESULT:
            self.playerGameState = [[response objectForKey:@"gamestate"] integerValue];
            self.round = [[response objectForKey:@"round"] integerValue];
            self.audioPath = [response objectForKey:@"audiopath"];
            
            self.reward = [[response objectForKey:@"reward"] integerValue];
            [self loadAnswerIDAndCNForResponse:response];
            
            break;
        
        default:
            break;
    }
    
    if (self.delegate) [self.delegate requestDidFinish:YES withResponse:response withType:type];
}

- (void)didFailSelector:(NSDictionary *)response withType:(RequestType)type
{
    if (self.delegate) [self.delegate requestDidFinish:NO withResponse:response withType:type];
}



@end
