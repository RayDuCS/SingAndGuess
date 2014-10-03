//
//  Player.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "Player.h"
#import "GuessGame.h"
#import "Inventory.h"

@interface Player()

@property (strong, nonatomic) NSData *password;

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define usersDataFile @"usersData.plist"
#define usernameCoder @"Username"
#define emailCoder @"Email"
#define sexCoder @"Sex"
#define levelCoder @"Level"
#define goldCoder @"Gold"
#define gamesDictCoder @"GamesDict"
#define gamesArrayCoder @"GamesArray"
#define passwordCoder @"Password"
#define expCoder @"Exp"
#define usersDataCoder @"UsersData"
#define idCoder @"ID"

@end

static NSString* const DeviceTokenKey = @"DeviceToken";

@implementation Player

@synthesize delegate = _delegate;

@synthesize nickname = _nickname;
@synthesize email = _email;
@synthesize isMale = _isMale;
@synthesize level = _level;
@synthesize exp = _exp;
@synthesize gold = _gold;
@synthesize gamesDict = _gamesDict;
@synthesize gamesArray = _gamesArray;
@synthesize password = _password;
@synthesize ID = _ID;

@synthesize portrait = _portrait;
@synthesize uncollectRef = _uncollectRef;
@synthesize totalRef = _totalRef;
@synthesize follower = _follower;

@synthesize httpConn = _httpConn;
@synthesize serverResponse = _serverResponse;
@synthesize inventory = _inventory;
@synthesize deviceToken = _deviceToken;
@synthesize msg = _msg;


- (Player *)initWithEmail:(NSString *)email andNickname:(NSString *)nickname andPassword:(NSData *)password andSex:(BOOL)isMale
{
    self = [super init];
    if (!self)
        return self;
    
    self.email = email;
    self.nickname = nickname;
    self.password = password;
    self.isMale = isMale;
    self.level = 1;
    self.exp = 0;
    self.gamesDict = [[NSMutableDictionary dictionaryWithCapacity:0] copy];
    self.gamesArray = [NSArray arrayWithObjects: nil];
    self.gold = 0;
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    
    
    return self;
}
- (Player *)initWithPlayer:(Player *) aPlayer
{
    self = [super init];
    if (!self)
        return self;
    
    self.email = aPlayer.email;
    self.nickname = aPlayer.nickname;
    self.password = aPlayer.password;
    self.isMale = aPlayer.isMale;
    self.level = aPlayer.level;
    self.exp = aPlayer.exp;
    self.gamesDict = aPlayer.gamesDict;
    self.gamesArray = aPlayer.gamesArray;
    self.gold = aPlayer.gold;
    self.ID = aPlayer.ID;
    self.totalRef = aPlayer.totalRef;
    self.uncollectRef = aPlayer.uncollectRef;
    self.follower = aPlayer.follower;
    
    self.inventory = aPlayer.inventory;
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    
    
    return self;
    
}

/*
- (Player *)initWithEmail:(NSString *)email andNickname:(NSString *)nickname andPassword:(NSData *)password andSex:(BOOL)isMale andLevel:(int)level andExp:(int)exp andGamesDict:(NSDictionary *)gamesDict andGamesArray:(NSArray *)gamesArray andGold:(int)gold andID:(NSString *)ID
{
    self = [super init];
    if (!self)
        return self;
    
    self.email = email;
    self.nickname = nickname;
    self.password = password;
    self.isMale = isMale;
    self.level = level;
    self.exp = exp;
    self.gamesDict = gamesDict;
    self.gamesArray = gamesArray;
    self.gold = gold;
    self.ID = ID;
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    
    
    return self;
}

- (Player *)initWithEmail:(NSString *)email andNickname:(NSString *)nickname andPassword:(NSString *)password andSex:(BOOL)isMale andLevel:(int)level andExp:(int)exp andGold:(int)gold andID:(int)ID
{
    self = [super init];
    if (!self)
        return self;
    
    self.email = email;
    self.nickname = nickname;
    self.password = password;
    self.isMale = isMale;
    self.level = level;
    self.exp = exp;
    //self.games = [games copy];
    self.gold = gold;
    self.ID = ID;
    
    return self;
}


+ (NSData *)loadFile
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, usersDataFile]];
    NSData *usersData = [[NSData alloc] initWithContentsOfURL:url];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:usersData];
    usersData = [unarchiver decodeObjectForKey:usersDataCoder];
    [unarchiver finishDecoding];
    
    return usersData;
}
*/
- (void)reloadPlayer
{
    /*
    NSMutableArray *gamesUpdated = [[NSMutableArray alloc] init];
    for (GuessGame *game in self.games)
    {
        GuessGame *gameUpdated = [GuessGame gameWithGameid:game.gameid];
        if (gameUpdated) [gamesUpdated addObject:gameUpdated];
    }
    
    self.games = [gamesUpdated copy];
    [self savePlayer];
     */
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    [self.httpConn reloadGameForPlayer:self];
    
    //self.gamesArray = [self.gamesDict allValues];
}
- (void)reloadGames
{
    self.gamesArray = [self.gamesDict allValues];
    int count = [self.gamesArray count];

    NSMutableArray *activeGame = [[NSMutableArray alloc]init];
    NSMutableArray *waitingGame = [[NSMutableArray alloc]init];
    NSMutableArray *deletedGame = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < count; i++) {
        GuessGame * tempGame;
        tempGame = [self.gamesArray objectAtIndex: i];
        if (tempGame.playerGameState == GAMESTATE_WAIT)
        {
            [waitingGame addObject:tempGame];
        }
        else if (tempGame.playerGameState == GAMESTATE_DELETED)
        {
            [deletedGame addObject:tempGame];
        }
        else
        {
            [activeGame addObject:tempGame];
        }
    }
    [activeGame addObjectsFromArray: waitingGame];
    [activeGame addObjectsFromArray: deletedGame];
    self.gamesArray = [[NSArray alloc] initWithArray:activeGame];
    
}
// xiaofei

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

/*
- (void)downloadFiles:(NSArray *)filePaths
{
    for (NSString *partialPath in filePaths)
    {
        [self.httpConn downloadFileFrom:partialPath];
        
    }
    
}*/

/*
+ (Player *)playerWithEmail:(NSString *)email
{       
    NSDictionary *users = (NSDictionary *)[Player loadFile];
    Player *player = [users objectForKey:email];
    [player reloadPlayer];
    
    return player;
}

+ (Player *)playerWithNickname:(NSString *)nickname
{   
    NSDictionary *users = (NSDictionary *)[Player loadFile];
    
    for (NSString *email in users)
    {
        Player *player = [users objectForKey:email];
        if ([player.nickname isEqualToString:nickname])
        {
            [player reloadPlayer];
            return player;
        }
    }
    
    return nil;    
}*/
 

- (Player *)initWithDictionary:(NSDictionary *)dictionary
{
    NSString * levelstring = [dictionary objectForKey:@"level"];
    int level = [levelstring intValue];
    NSString * expstring = [dictionary objectForKey:@"exp"];
    int exp = [expstring intValue];
    NSString * goldstring = [dictionary objectForKey:@"gold"];
    int gold = [goldstring intValue];
    NSString * IDstring = [dictionary objectForKey:@"id"];
    NSString * isMalestring = [dictionary objectForKey:@"ismale"];
    int isMale = [isMalestring intValue];
    int numOfHammers=0, numOfKeys=0, dayOfVIP=0;
    NSString *albumInfo = @"00000000";
    
    self = [super init];
    if (!self)
        return self;
    
    self.email = [dictionary objectForKey:@"email"];
    self.nickname = [dictionary objectForKey:@"nickname"];
    //self.password = [dictionary objectForKey:@"pwd"];
    self.password = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPwd"];
    self.isMale = isMale;
    self.level = level; // gaoshen reward
    self.exp = exp;
    self.gamesDict = [[NSMutableDictionary dictionaryWithCapacity:0] copy];
    self.gamesArray = [NSArray arrayWithObjects: nil];
    self.gold = gold;
    self.ID = IDstring;
    self.uncollectRef = [[dictionary objectForKey:@"uncollectRef"] intValue];
    self.totalRef = [[dictionary objectForKey:@"totalRef"] intValue];
    self.follower = [[dictionary objectForKey:@"follower"] intValue];
    if ([dictionary objectForKey:@"hammer"]) numOfHammers = [[dictionary objectForKey:@"hammer"] intValue];
    if ([dictionary objectForKey:@"silverkey"]) numOfKeys = [[dictionary objectForKey:@"silverkey"] intValue];
    if ([dictionary objectForKey:@"vip"]) dayOfVIP = [[dictionary objectForKey:@"vip"] intValue];
    if ([dictionary objectForKey:@"albumstr"]) albumInfo = [dictionary objectForKey:@"albumstr"];
    
    
    self.inventory = [[Inventory alloc] initWithUserID:self.ID numOfHammers:numOfHammers numOfKeys:numOfKeys dayOfVIP:dayOfVIP albumInfo:albumInfo];
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    
    return self;
    
}

/*
- (GuessGame *)gameWithOppEmail:(NSString *)email
{
    return [self.gamesDict objectForKey:email];
}


+ (BOOL)checkEmailExists:(NSString *)email
{
    NSDictionary *users = (NSDictionary *)[Player loadFile];
    
    if (![users objectForKey:email])
        return NO;
    
    return YES;
}

+ (BOOL)checkNicknameExists:(NSString *)nickname
{
    NSDictionary *users = (NSDictionary *)[Player loadFile];
    
    for (NSString *email in users)
    {
        if ([[[users objectForKey:email] nickname] isEqualToString:nickname])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)checkPasswordCorrectness:(NSString *)pwd forEmail:(NSString *)email
{
    NSDictionary *users = (NSDictionary *)[Player loadFile];
    Player *player = [users objectForKey:email];
    if ([player.password isEqualToString:pwd])
        return YES;
    else 
        return NO;
}
 */

- (void)createGameWithPlayer:(Player *)oppPlayer
{
    GuessGame *game = [[GuessGame alloc] initWithUser:self andOpp:oppPlayer andGameState:GAMESTATE_PRE_RECORD];
    NSMutableDictionary *currentGamesDict = [self.gamesDict mutableCopy];
    [currentGamesDict setObject:game forKey:game.oppID];
    
    for(id key in currentGamesDict)
    {
        NSLog(@"%@", key);
        
        
    }
    self.gamesDict = [currentGamesDict copy];
    
    //[self.gamesDict setObject:game forKey:game.oppEmail];

    //[self savePlayer];
}

- (void)joinGame:(GuessGame *)oppGame
      WithPlayer:(Player *)oppPlayer
{
    GuessGame *game = [[GuessGame alloc] initWithUser:self andOpp:oppPlayer andGameState:GAMESTATE_WAIT];
    game.startOfGame = NO;
    game.reward = oppGame.reward;
    game.audioPath = oppGame.audioPath;
    game.answer = oppGame.answer;
    
    [self updateGame:game];
}

- (void)exitGame:(GuessGame *)game
{
    //if (!game.startOfGame)
    [self.httpConn deleteGameForPlayerID:game.userID withOppID:game.oppID];
    
    NSMutableDictionary *currentGamesDict = [self.gamesDict mutableCopy];
    [currentGamesDict removeObjectForKey:game.oppID];
    self.gamesDict = [currentGamesDict copy];
    
    [self reloadGames];
}

- (void)updateGame:(GuessGame *)game
{
    // Update the game for this Player
    NSMutableDictionary *currentGamesDict = [self.gamesDict mutableCopy];
    [currentGamesDict setObject:game forKey:game.oppID];
    self.gamesDict = [currentGamesDict copy];
    
    //[self savePlayer];
}

- (void)requestLogin
{
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setValue:token forKey:@"token"];
    //[defaults synchronize];
    //NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];
    //NSLog(@"My token is: %@", [defaults1 objectForKey:@"token"]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenStr = [defaults objectForKey:@"token"];
    if (tokenStr) self.deviceToken = [NSString stringWithString:tokenStr];
    else self.deviceToken = nil;
    //self.deviceToken = [NSString stringWithString:[defaults objectForKey:@"token"]];
    
    //self.deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    [self.httpConn loginWithEmail:self.email andPassword:self.password andDeviceToken:self.deviceToken];
}

/*
- (void)login
{
    [self.httpConn loginForPlayer:self];
}*/

- (void)registerNewPlayerIsUpdatePortrait:(BOOL) isUpdate
{
    if(isUpdate == TRUE)
    {
        [self.httpConn registNewNickname:self.nickname
                                 withSex:self.isMale
                                  withID:self.ID
                               withEmail:self.email
                                 withPwd:self.password
                               withRefer:self.refer
                            withPortrait:self.portrait];
    }
    else
    {
        [self.httpConn registNewNickname:self.nickname
                                 withSex:self.isMale
                                  withID:self.ID
                               withEmail:self.email
                                 withPwd:self.password
                               withRefer:self.refer
                            withPortrait:NULL];
        
    }
}
-(void) upLoadProtrait:(BOOL)isNew forUser:(NSString*)userID
{
    [self.httpConn isCopyProtrait:isNew ForUser:userID];
}


- (void)searchOppWithInput:(NSString *)input WithOption:(SearchOppType)searchOppType
{
    [self.httpConn searchOppWithOption:searchOppType withPostfix:input withUserID:self.ID];
}

- (void)unbanOppPlayer:(NSString *)oppNickname
{
    [self.httpConn unbanPlayerID:self.ID withTargetPlayerNickname:oppNickname];
}

- (void)unbanOppPlayerUsingEmail:(NSString *)oppEmail
{
    [self.httpConn unbanPlayerID:self.ID withTargetPlayerEmail:oppEmail];
}

- (void)updateInfoWithOldPwd:(NSData *)oldPwd
                  withNewPwd:(NSData *)pwd
                withNickname:(NSString *)nickname
                withPortrait:(UIImage *) portrait
{
    [self.httpConn updateInfoForPlayerID:self.ID
                              withOldPwd:oldPwd
                              withNewPwd:pwd
                            withNickname:nickname
                            withPortrait:portrait];
}

- (void)retrieveInfo
{
    [self.httpConn retrieveInfoPlayerID:self.ID];
}

- (void)getPortrait
{
    NSString *filePath = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@/user.png", self.ID];
    [self.httpConn getPortraitOfPlayerID:self.ID storeAtPath:filePath];
}

- (void)collectBonusForType:(BonusType)type gold:(int)gold hammer:(int)hammer key:(int)key dayOfVIP:(int)dayOfVIP
{
    [self.httpConn collectBonusForPlayerID:self.ID type:type gold:gold hammer:hammer key:key dayOfVIP:dayOfVIP productID:nil];
}

+ (float)getExpForLevel:(int)level
{
    if (level <   0) return      0;
    if (level ==  1) return    120;
    if (level ==  2) return    361;
    if (level ==  3) return    727;
    if (level ==  4) return   1222;
    if (level ==  5) return   1854;
    if (level ==  6) return   2630;
    if (level ==  7) return   3558;
    if (level ==  8) return   4648;
    if (level ==  9) return   5909;
    if (level == 10) return   7352;
    if (level == 11) return   8915;
    if (level == 12) return  10598;
    if (level == 13) return  12401;
    if (level == 14) return  14324;
    if (level == 15) return  16367;
    if (level == 16) return  18530;
    if (level == 17) return  20813;
    if (level == 18) return  23216;
    if (level == 19) return  25739;
    if (level == 20) return  28382;
    if (level == 21) return  31145;
    if (level == 22) return  34028;
    if (level == 23) return  37031;
    if (level == 24) return  40154;
    if (level == 25) return  43397;
    if (level == 26) return  46760;
    if (level == 27) return  50243;
    if (level == 28) return  54031;
    if (level == 29) return  58180;
    if (level == 30) return  62708;
    if (level == 31) return  67638;
    if (level == 32) return  72989;
    if (level == 33) return  78781;
    if (level == 34) return  85037;
    if (level == 35) return  91778;
    if (level == 36) return  99025;
    if (level == 37) return 106801;
    if (level == 38) return 115128;
    if (level == 39) return 124030;
    //if (level == 39) return 133528;
    
    
    return -1;
}

- (float)calLevelingRatio
{
    float ceil = [Player getExpForLevel:self.level];
    if (ceil == -1) return 1;
    
    float floor = [Player getExpForLevel:self.level-1];
    
    return (self.exp-floor)/(ceil-floor);
}

- (void)reloadGamesWithResponse:(NSDictionary *)response
                           type:(RequestType)type
{   
    int numOfGames = 0;
    NSMutableDictionary *currentGamesDict = nil;
    
    numOfGames = [[response objectForKey:@"numOfGame"] intValue];
    NSLog(@"%@", response);
    currentGamesDict = [self.gamesDict mutableCopy];
    self.msg = [response objectForKey:@"msg"];
    
    while (numOfGames >0) {
        NSLog(@"update a game now %d", numOfGames);
        NSString * name = [NSString stringWithFormat:@"game%d",numOfGames];
        NSDictionary * gameDic = [response objectForKey:name];
        NSString * gamestate = [gameDic objectForKey:@"gamestate"];
        NSString * oppID = [gameDic objectForKey:@"player2ID"];
        
        
        if([gamestate intValue]== GAMESTATE_DELETED && type == REQUEST_TYPE_UPDATE_PLAYER)
        {
            // update to delete
            GuessGame *game = [currentGamesDict objectForKey:oppID];
            game.playerGameState = GAMESTATE_DELETED;
        } else {
         
            // give up and creat a game
            NSLog(@"add a game now %d", numOfGames);
            //NSString *name = [NSString stringWithFormat:@"game%d",numOfGames];
            //NSDictionary *gameDic = [response objectForKey:name];
            NSString *reward = [gameDic objectForKey:@"reward"];
            NSString *answer = [gameDic objectForKey:@"answer"];
            NSString *audioPath = [gameDic objectForKey:@"audiopath"];
            NSString *round = [gameDic objectForKey:@"round"];
            NSString *guess = [gameDic objectForKey:@"guess"];
            //NSString *gamestate = [gameDic objectForKey:@"gamestate"];
            //NSString *oppID = [gameDic objectForKey:@"player2ID"];
            NSString *userID = [gameDic objectForKey:@"player1ID"];
            NSString *oppnickname = [gameDic objectForKey:@"nickname"];
            NSString *opplevel = [gameDic objectForKey:@"level"];  // gaoshen reward
            NSArray *values = [self getTokensOfDiscardString:[gameDic objectForKey:@"discard"]];
            NSString * oppismale = [gameDic objectForKey:@"ismale"];
            int oppDayOfVIP = [[gameDic objectForKey:@"vip"] intValue];
            BOOL oppismaleBool;
            BOOL snoozable;
            BOOL vipEnpowered;
            
            if ([oppismale integerValue] == 1) oppismaleBool = TRUE;
            else oppismaleBool = FALSE;
            if ([[gameDic objectForKey:@"snooze"] integerValue] == 1) snoozable = TRUE;
            else snoozable = FALSE;
            if ([[gameDic objectForKey:@"vipEnpowered"] integerValue] == 1) vipEnpowered = TRUE;
            else vipEnpowered = FALSE;
            
            GuessGame *game = [[GuessGame alloc] initWithUserID:userID
                                                       andOppID:oppID
                                                 andOppNickname:oppnickname
                                                    andOppLevel:[opplevel integerValue]
                                                      andOppSex:oppismaleBool
                                                 andOppDayOfVIP:oppDayOfVIP
                                             usePlayerGameState:[gamestate integerValue]
                                                       andRound:[round integerValue]
                                                     withAnswer:answer
                                                  withAudioPath:audioPath
                                                     withReward:[reward integerValue]
                                                      withGuess:guess
                                                withCommentPath:NULL
                                                      snoozable:snoozable
                                                   vipEnpowered:vipEnpowered
                                                      andValues:values];
            //id and chinese update
            int  numOfChoice = [[gameDic objectForKey:@"numChoice"] integerValue];
            if (numOfChoice == 5) {
                game.answerCN = NULL;
                game.answerID = NULL;
                game.answerCN = [[NSMutableArray alloc]init];
                game.answerID = [[NSMutableArray alloc]init];
                for(int m = 0; m <numOfChoice; m++)
                {
                    NSString * tmp = [NSString stringWithFormat:@"choice%d",m ];
                    [game.answerCN  addObject:[gameDic objectForKey:tmp]];
                }
                for(int m = 0; m <numOfChoice; m++)
                {
                    [game.answerID  addObject:[gameDic objectForKey:[NSString stringWithFormat:@"choice%dID",m]]];
                }
            }
            
            [currentGamesDict removeObjectForKey:oppID];
            [currentGamesDict setObject:game forKey:oppID];
        }
        
        numOfGames--;
    }
    
    self.gamesDict = [currentGamesDict copy];
    [self reloadGames];
}

- (void)logout
{
    [self.httpConn changeOnlineStateForLogout:self.ID];
}


- (void)restoreIAPsWithGold:(int)gold
                   dayOfVIP:(int)dayOfVIP
{
    [self.httpConn collectBonusForPlayerID:self.ID
                                      type:BONUS_TYPE_IAP
                                      gold:gold
                                    hammer:0
                                       key:0
                                  dayOfVIP:dayOfVIP
                                 productID:nil];
}

- (void)didFinishSelector:(NSDictionary *)response withType:(RequestType)type
{   
    switch (type) {            
        case REQUEST_TYPE_LOGIN:
            break;
            
        case REQUEST_TYPE_UPDATE_PLAYER:
            NSLog(@"%@", response);
            [self reloadGamesWithResponse:response type:type];
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
/*
- (void) setDeviceToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
}
*/

/*
- (void)savePlayer
{   
    NSDictionary *users = (NSDictionary *)[Player loadFile];
    if (!users)
    {
        users = [NSDictionary dictionaryWithObject:self forKey:self.email];
    }
    else
    {
        NSMutableDictionary *usersChanged = [users mutableCopy];
        [usersChanged setObject:self forKey:self.email];
        users = [usersChanged copy];
    }
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, usersDataFile]];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:users forKey:usersDataCoder];
    [archiver finishEncoding];
    [data writeToURL:url atomically:YES];
}

+ (void)player:(NSString *)email GetReward:(int)reward
{
    Player *player = [Player playerWithEmail:email];
    player.gold += reward;
    [player savePlayer];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.email forKey:emailCoder];
    [aCoder encodeObject:self.nickname forKey:usernameCoder];
    [aCoder encodeBool:self.isMale forKey:sexCoder];
    [aCoder encodeObject:self.password forKey:passwordCoder];
    [aCoder encodeObject:self.gamesDict forKey:gamesDictCoder];
    [aCoder encodeObject:self.gamesArray forKey:gamesArrayCoder];
    [aCoder encodeInt:self.gold forKey:goldCoder];
    [aCoder encodeInt:self.level forKey:levelCoder];
    [aCoder encodeInt:self.exp forKey:expCoder];
    [aCoder encodeInt:self.ID forKey:idCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *email = [aDecoder decodeObjectForKey:emailCoder];
    NSString *nickname = [aDecoder decodeObjectForKey:usernameCoder];
    NSString *password = [aDecoder decodeObjectForKey:passwordCoder];
    NSDictionary *gamesDict = [aDecoder decodeObjectForKey:gamesDictCoder];
    NSArray *gamesArray = [aDecoder decodeObjectForKey:gamesArrayCoder];
    int level = [aDecoder decodeIntForKey:levelCoder];
    int gold = [aDecoder decodeIntForKey:goldCoder];
    int exp = [aDecoder decodeIntForKey:expCoder];
    BOOL sex = [aDecoder decodeBoolForKey:sexCoder];
    int ID = [aDecoder decodeIntForKey:idCoder];
    
    return [self initWithEmail:email andNickname:nickname andPassword:password andSex:sex andLevel:level andExp:exp andGamesDict:gamesDict andGamesArray:gamesArray andGold:gold andID:ID];
}
 */

@end
