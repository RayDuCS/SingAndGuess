//
//  HttpConn.h
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

//Xiaofei Test type in file HttpConn.h

#import <Foundation/Foundation.h>
@class Player;
@class GuessGame;

#define E_SERVER_PROBLEM            -101
#define E_UPLOAD_FAILED             -102
#define E_LOGIN_FROM_ANOTHER_DEVICE -103
#define E_WRONG_SESSION             -104
#define E_BAD_DATA                  -105
#define E_OK                        1

#define E_TIMEOUT                   300

typedef enum
{
    REQUEST_TYPE_LOGIN                   = 1,  // Login, Register ..
    REQUEST_TYPE_FINISH_RECORDING        = 2,  // Player finished recording audio
    REQUEST_TYPE_UPDATE_PLAYER           = 3,  // Refresh games of a player, include downloading audios
    REQUEST_TYPE_FINISH_ACCEPT           = 4,  // Player accepted a game
    REQUEST_TYPE_FINISH_SHOW_RESULT      = 5,  // Player had seen the result of game
    REQUEST_TYPE_START_RECORDING         = 6,  // Player started recording games, had chosen topic
    REQUEST_TYPE_FINISH_GUESSING         = 7,  // Player made a guess
    REQUEST_TYPE_FINISH_CONTINUE         = 8,  // Same as above
    REQUEST_TYPE_DELETE_GAME             = 9,  // Player deleted a game
    //REQUEST_TYPE_RETRIEVE_PLAYER = 10,       // Player login, update games, don't download audios
    REQUEST_TYPE_DOWNLOAD_FILE           = 11, // Player download audios
    REQUEST_TYPE_UPDATE_PLAYER_INFO      = 12, // Update Player's personal info
    REQUEST_TYPE_RETRIEVE_PLAYER_INFO    = 13, // Get Player's personal info.
    REQUEST_TYPE_BAN_PLAYER              = 14, // Ban a player
    REQUEST_TYPE_UNBAN_PLAYER            = 15, // Unban a player
    REQUEST_TYPE_GET_PORTRAIT            = 16, // Get portrait of a player
    REQUEST_TYPE_USE_HAMMER              = 17, // USE a hammer !
    REQUEST_TYPE_LOGIN_DEVICE_TOKEN      = 18, // Register device token
    REQUEST_TYPE_PUSH_NOTIFICATION       = 19, // Push notification
    REQUEST_TYPE_PUSH_SNOOZE             = 20, // snooze
    REQUEST_TYPE_PURCHASE_ITEM_WITH_GOLD = 21, // Purchase with gold
    REQUEST_TYPE_USE_KEY                 = 22, // Use key to unlock database
    REQUEST_TYPE_LOGOUT                  = 23, // logout user so no more notification
    REQUEST_TYPE_S3_UPLOAD               = 24, // S3 upload file
    REQUEST_TYPE_S3_UPLOAD_PORTAIT       = 25, // s3 upload portait
    REQUEST_TYPE_COLLECT_BONUS           = 26, // Collect bonus
    REQUEST_TYPE_SEARCH_OPP              = 27, // Search opp for play
}RequestType;

typedef enum{
    SEARTH_OPP_WITH_NICKNAME = 1,
    SEARTH_OPP_WITH_EMAIL    = 2,
    SEARTH_OPP_WITH_RANDOM   = 3,
}SearchOppType;

typedef enum
{
    SEARCH_SUCCESS               = E_OK, // Success search
    SEARCH_CONFLICT              = -1,   // A game has exist between players
    SEARCH_CONFLICT_SELF_REMOVED = -6,   // A game has been removed by himself
    SEARCH_NOT_FOUND             = -2,   // No such opp player
    SEARCH_IN_BAN                = -3,   // Opp player banned
    SEARCH_BE_BANNED             = -4,   // Self player banned
    SEARCH_RANDOM_NOT_AVAILABLE  = -5,   // random not ok
}SearchStatus;

typedef enum
{
    UPDATE_INFO_WRONG_PWD = 1,
    UPDATE_INFO_NICKNAME_EXIST = 2,
    UPDATE_INFO_SUCCESS = 3
}UpdateInfoType;

typedef enum 
{
    LOGIN_STATUS_SUCCESS        = E_OK,
    LOGIN_STATUS_WRONG_PASSWORD = -1,
    LOGIN_STATUS_NEW_ACCOUNT    = 2,
    LOGIN_STATUS_WRONG_SESSION  = E_WRONG_SESSION
}LoginStatus;

typedef enum
{
    REGISTER_STATUS_SUCCESS        = E_OK,
    REGISTER_STATUS_USER_EXIST     = -3,
    REGISTER_STATUS_WRONG_REFER    = -2,
    REGISTER_STATUS_NICKNAME_EXIST = -1
}RegisterStatus;

typedef enum
{
    UPLOAD_FILE_SUCCESSFUL = 1,
    UPLOAD_FILE_FAILED = -1
}UploadStatus;

typedef enum
{
    DOWNLOAD_FILE_SUCCESSFUL = 1,
    DOWNLOAD_FILE_FAILED = -1
}DownloadStatus;

typedef enum
{
    REQUEST_FILE_PATH = 1
}DownloadRequestType;

typedef enum
{
    HAMMER_USE_STATUS_USED = -1,
    HAMMER_USE_STATUS_NO_MORE_HAMMER = -2
}HammerUseStatus;

typedef enum {
    PURCHASE_ITEM_TYPE_NONE   = 100,
    PURCHASE_ITEM_TYPE_HAMMER = 101,
    PURCHASE_ITEM_TYPE_KEY    = 102,
    PURCHASE_ITEM_TYPE_VIP    = 103,
}PurchaseItemType;

typedef enum {
    PURCHASE_ITEM_STATUS_SUCCESS = 1,
    PURCHASE_ITEM_STATUS_NOT_ENOUGH_GOLD = -1,
    PURCHASE_ITEM_STATUS_WRONG_REQ_TYPE = -2,
    PURCHASE_ITEM_STATUS_WRONG_ITEM_TYPE = -3,
}PurchaseItemStatus;

typedef enum {
    USE_KEY_STATUS_SUCCESS = 1,
    USE_KEY_STATUS_NOT_ENOUGH_KEY = -1,
    USE_KEY_STATUS_ALREADY_UNLOCKED = -2,
}UseKeyStatus;

typedef enum {
    UNBAN_STATUS_SUCCESS = 1,
    UNBAN_STATUS_NOT_IN_LIST = -1,
}UnbanStatus;

typedef enum {
    BONUS_TYPE_IAP               = 101,
    BONUS_TYPE_COLLECT_REF_BONUS = 102,
}BonusType;

typedef enum {
    COLLECT_BONUS_STATUS_SUCCESS = 1,
    COLLECT_BONUS_STATUS_IGP_FAIL = -2,
    COLLECT_BONUS_STATUS_NO_TYPE = -3
}CollectBonusStatus;

@interface HttpConn : NSObject

@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) NSString *serverAddress;
@property (strong, nonatomic) NSString *bucketName;
@property (strong, nonatomic) NSString *accessID;
@property (strong, nonatomic) NSString *accessKey;


+ (void)init;
- (void)S3UploadFileForUser:(NSString *) userID withOppID:(NSString*) oppID isComment:(BOOL) isComment;
- (void)S3DownloadFileForUser:(NSString*) userID fromOpp:(NSString*) oppID isComment:(BOOL) isComment;

- (void)downloadFileFrom:(NSString *)requestFilePath;
- (void)deleteFile:(NSString *)requestFilePath;
- (BOOL)checkFileExists:(NSString *)requestFilePath;

- (HttpConn *)initWithDelegate:(id)delegate;

- (void)loginWithEmail:(NSString *)email
           andPassword:(NSData *)password
           andDeviceToken:(NSString *)deviceToken;

- (void)registNewNickname:(NSString *)nickmame
                  withSex:(BOOL) isMale
                   withID:(NSString *) userID
                withEmail:(NSString *)email
                  withPwd:(NSData *)pwd
                withRefer:(NSString *)refer
            withPortrait:(UIImage*) portrait;
- (void) isCopyProtrait:(BOOL) isCopy ForUser:(NSString *) userID;


//- (void)searchWithEmail:(NSString *)email;

//- (void)searchWithID:(NSString *)ID;

//- (void)searchWithNickname:(NSString *)nickname;

//- (void)searchOppWithOption:(SearchOppType)searchOppType withPostfix:(NSString*)postfix;
- (void)searchOppWithOption:(SearchOppType)searchOppType
                withPostfix:(NSString *)postfix
                 withUserID:(NSString *)userID;
- (void)searchOppRandomwithUserID: (NSString *) userID;



- (void)finishRecordingForPlayer:(Player *)player 
                        WithPath:(NSString *)audioPath 
                       forAnswer:(NSString *)answer
                      withReward:(int)reward
                         forGame:(GuessGame *)game;

- (void)finishAcceptGameForPlayer:(Player *)player
                          forGame:(GuessGame *)game;

- (void)finishShowResultForPlayer:(Player *)player
                          forGame:(GuessGame *)game;

- (void)startRecordingForPlayer:(Player *)player
                        forGame:(GuessGame *)game;

- (void)finishGuessingForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath
                        forGame:(GuessGame *)game;

- (void)finishContinueForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath
                        forGame:(GuessGame *)game;

- (void)deleteGameForPlayerID:(NSString *)userID
                    withOppID:(NSString *)oppID;


- (void)reloadGameForPlayer:(Player *)player;

//- (void)loginForPlayer:(Player *)player;

- (void)updateInfoForPlayerID:(NSString *)userID
                   withOldPwd:(NSData *)oldPwd
                   withNewPwd:(NSData *)newPwd
                 withNickname:(NSString *)nickname
                 withPortrait:(UIImage *)portrait;

- (void)retrieveInfoPlayerID:(NSString *)userID;

- (void)banPlayerID:(NSString *)userID
 withTargetPlayerID:(NSString *)oppID;

- (void)unbanPlayerID:(NSString *)userID
withTargetPlayerNickname:(NSString *)oppNickname;

- (void)unbanPlayerID:(NSString *)userID
withTargetPlayerEmail:(NSString *)oppEmail;

- (void)getPortraitOfPlayerID:(NSString *)userID
                  storeAtPath:(NSString *)filePath;

- (void)useCrackHammerForPlayerID:(NSString *)userID
                            oppID:(NSString *)oppID;
- (void)useRefreshHammerForPlayerID:(NSString *)userID
                              oppID:(NSString *)oppID;
- (void)purchaseItemWithGold:(PurchaseItemType)type
                      amount:(int)amount
                       gold:(int)gold
                      userID:(NSString *)userID;
- (void)useKeyForPlayerID:(NSString *)userID
                  albumID:(NSString *)albumID;

- (void)snoozeForGame:(GuessGame *)game;
- (void)changeOnlineStateForLogout:(NSString *)userID;

- (void)collectBonusForPlayerID:(NSString *)userID
                           type:(BonusType)type
                           gold:(int)gold
                         hammer:(int)hammer
                            key:(int)key
                       dayOfVIP:(int)dayOfVIP
                      productID:(NSString *)productID;

@end

@protocol HttpConnDelegate <NSObject>

@required
-(void) didFinishSelector:(NSDictionary *)response
                 withType:(RequestType)type;
-(void) didFailSelector:(NSDictionary *)response
               withType:(RequestType)type;

@optional

@end




