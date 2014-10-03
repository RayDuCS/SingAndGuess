//
//  Player.h
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpConn.h"

@class GuessGame;
@class Inventory;

@protocol PlayerSpinnerDelegate <NSObject>

@required
- (void)requestDidFinish:(BOOL)success
            withResponse:(NSDictionary *)serverResponse
                withType:(RequestType)type;

@end

@interface Player : NSObject<HttpConnDelegate>

@property (weak, nonatomic) id delegate;

@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *email;
@property (nonatomic) BOOL isMale;
@property (nonatomic) int level;
@property (nonatomic) int exp;
@property (nonatomic) int gold;
@property (nonatomic, strong) NSDictionary *gamesDict;
@property (nonatomic, strong) NSArray *gamesArray;
@property (nonatomic) NSString *ID;
@property (strong , nonatomic) NSString *refer;

@property (strong, nonatomic) UIImage *portrait;
@property (nonatomic) int totalRef;
@property (nonatomic) int uncollectRef;
@property (nonatomic) int follower;

@property (weak, nonatomic) NSDictionary * serverResponse;
@property (strong, nonatomic) HttpConn *httpConn;

@property (strong, nonatomic) Inventory *inventory;

@property (strong, nonatomic) NSString *deviceToken;

@property (strong, nonatomic) NSString *msg;

+ (float)getExpForLevel:(int)level;

- (Player *)initWithEmail:(NSString *)email
              andNickname:(NSString *)nickname
              andPassword:(NSData *)password
                   andSex:(BOOL)isMale;

- (Player *)initWithDictionary:(NSDictionary *)dictionary;
- (Player *)initWithPlayer:(Player *) aPlayer;

- (void)createGameWithPlayer:(Player *)oppPlayer;
- (void)joinGame:(GuessGame *)oppGame
      WithPlayer:(Player *)oppPlayer;
- (void)exitGame:(GuessGame *)game;

- (void)updateGame:(GuessGame *)game;
- (void)reloadPlayer;
- (void)reloadGames;
- (void)reloadGamesWithResponse:(NSDictionary *)response
                           type:(RequestType)type; // Reload latest game within response for player

- (void)requestLogin;
//- (void)login;

-(void) upLoadProtrait:(BOOL)isNew forUser:(NSString*)userID;
- (void)registerNewPlayerIsUpdatePortrait:(BOOL) isUpdate;
- (void)searchOppWithInput:(NSString *)input
                WithOption:(SearchOppType)searchOppType;


- (void)unbanOppPlayer:(NSString *)oppNickname;
- (void)unbanOppPlayerUsingEmail:(NSString *)oppEmail;
- (void)updateInfoWithOldPwd:(NSData *)oldPwd
                  withNewPwd:(NSData *)pwd
                withNickname:(NSString *)nickname
                withPortrait:(UIImage *) portrait;

- (float)calLevelingRatio;
- (void)retrieveInfo;
- (void)getPortrait;
- (void)collectBonusForType:(BonusType)type
                       gold:(int)gold
                     hammer:(int)hammer
                        key:(int)key
                   dayOfVIP:(int)dayOfVIP;

- (void)setDeviceToken:(NSString*)token;
- (void)logout;
- (void)restoreIAPsWithGold:(int)gold
                   dayOfVIP:(int)dayOfVIP;

@end
