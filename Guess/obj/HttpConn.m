//
//  HttpConn.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "HttpConn.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIS3ObjectRequest.h"
#import "JSON.h"
#import "GuessGame.h"
#import "Player.h"
#import "Inventory.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface HttpConn()
@end

@implementation HttpConn

@synthesize delegate = _delegate;
@synthesize UUID = _UUID;
@synthesize serverAddress = _serverAddress;
@synthesize bucketName = _bucketName;
@synthesize accessID = _accessID;
@synthesize accessKey = _accessKey;

static ASINetworkQueue *requestQueue;
static SBJsonParser *parser;

NSString * const StringFormat_SearchOppType[] = {
    @"1",
    @"2",
    @"3"
};

NSString * const StringFormat_DownloadRequestType[] = {
    @"1"
};

NSString * const FILE_ADDRESS_ON_SERVER_PREFIX = @"http://slidea-guess-game.elasticbeanstalk.com/";
NSString * const S3_BUCKET = @"slidea-guess-storage";
NSString * const USER_COMMEN_PATH_AT_SERVER = @"guess";

+ (void)init
{
    requestQueue = [[ASINetworkQueue alloc] init];
    requestQueue.maxConcurrentOperationCount = 15;
    [requestQueue setShouldCancelAllRequestsOnFailure:NO];
    [requestQueue go];
    [ASIS3Request setSharedSecretAccessKey:@"wua8lOD25nbZCJuswif0WiJTtbtq2S+Ea/FDPKRM"];
    [ASIS3Request setSharedAccessKey:@"AKIAI776XZTAKD6H6UEA"];
    
    
    parser = [[SBJsonParser alloc] init];
}

- (NSString *)intToStr:(int)value
{
    return [NSString stringWithFormat:@"%d", value];
}

- (HttpConn *)initWithDelegate:(id)delegate
{
    self = [super init];
    self.delegate = delegate;
    self.UUID = [[UIDevice currentDevice] uniqueIdentifier];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.serverAddress = [defaults objectForKey:@"serverAddress"];
    if(self.serverAddress == NULL)
        self.serverAddress = [NSString stringWithFormat:@"%@",FILE_ADDRESS_ON_SERVER_PREFIX];
    
    self.bucketName= [defaults objectForKey:@"bucketName"];
    if(self.bucketName == NULL)
        self.bucketName = [NSString stringWithFormat:@"%@",S3_BUCKET];
    
    // TODO ?????
    //self.accessID = [defaults objectForKey:@"accessID"];
    //self.accessKey = [defaults objectForKey:@"accessKey"];
    
    return self;
}

+ (void)addOperation:(ASIFormDataRequest *)request
{
    [requestQueue addOperation:request];
}

+ (NSDictionary *)parseResponse:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSLog(@"%@",response);
    
    //SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [parser objectWithString:response];
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON b objects
    return responseDict;
}

- (void)loginWithEmail:(NSString *)email andPassword:(NSData *)password andDeviceToken:(NSString *)deviceToken
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_login.php", self.serverAddress]];
    
    NSString *typeStr = [self intToStr:REQUEST_TYPE_LOGIN];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didLogin:)];
    [request setDidFailSelector:@selector(didLoginFail:)];
    [request setUseSessionPersistence:YES];
    //[request setUsername:email];
    // POST Query
    
    [request setPostValue:typeStr  forKey:@"type"];
    [request setPostValue:email    forKey:@"email"];
    [request setPostValue:password forKey:@"pwd"];
    
    if (deviceToken) {
        [request setPostValue:@"online"   forKey:@"cmd"];
        [request setPostValue:deviceToken forKey:@"deviceToken"];
    }
    
    // also post UDID for log usage

    // post UUID for prevent multi login
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
    
    //[self loginDeviceToken:email andDeviceToken:deviceToken];
}

- (void)didLogin:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGIN];
}

- (void)didLoginFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGIN];
}

- (void)registNewNickname:(NSString *)nickmame
                  withSex:(BOOL)isMale
                   withID:(NSString *)userID
                withEmail:(NSString *)email
                  withPwd:(NSData *)pwd
                withRefer:(NSString *)refer
             withPortrait:(UIImage*)portrait
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_register.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didNickName:)];        
    [request setDidFailSelector:@selector(didNickNameFail:)];
    
    [request setUseSessionPersistence:YES];
    // POST Query
    [request setPostValue:nickmame forKey:@"nickname"];
    [request setPostValue:userID   forKey:@"id"];
    [request setPostValue:email    forKey:@"email"];
    [request setPostValue:pwd      forKey:@"pwd"];
    [request setPostValue:refer    forKey:@"refer"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tokenStr = [defaults objectForKey:@"token"];
    if (tokenStr) {
        [request setPostValue:@"online" forKey:@"cmd"];
        [request setPostValue:[NSString stringWithString:tokenStr] forKey:@"deviceToken"];
    }
    
    
    if(isMale) [request setPostValue:[self intToStr:1] forKey:@"isMale"];
    else [request setPostValue:[self intToStr:0] forKey:@"isMale"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didNickName:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGIN];
}

- (void)didNickNameFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGIN];
}

-(void)isCopyProtrait:(BOOL)isNew ForUser:(NSString *)userID
{
    if(isNew) {
        NSString *filePath = [NSString stringWithFormat:@"%@/user.png", DOCUMENTS_FOLDER];
        NSString *destination = [NSString stringWithFormat:@"%@/%@/user.png", USER_COMMEN_PATH_AT_SERVER, userID];
        [self S3UploadFilePath:filePath toDestination:destination];
    } else {
        NSString *destination = [NSString stringWithFormat:@"%@/%@/user.png", USER_COMMEN_PATH_AT_SERVER, userID];
        [self S3CopyUserPortraitToDestination:destination];
    }
}

-(void)S3UploadFilePath:(NSString*)filePath
          toDestination:(NSString*)destination
{
    ASIS3ObjectRequest *request =[ASIS3ObjectRequest PUTRequestForFile:filePath withBucket:self.bucketName key:destination];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didS3UploadPortait:)];
    [request setDidFailSelector:@selector(didS3UploadPortaitFail:)];
    
    [requestQueue addOperation:request];
    
}
-(void)S3CopyUserPortraitToDestination:(NSString*)destination
{
    ASIS3ObjectRequest *request =
    [ASIS3ObjectRequest COPYRequestFromBucket:self.bucketName key:@"test/user.png"
                                     toBucket:self.bucketName key:destination];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didS3UploadPortait:)];
    [request setDidFailSelector:@selector(didS3UploadPortaitFail:)];
    
    [requestQueue addOperation:request];
}

-(void)didS3UploadPortait:(ASIS3ObjectRequest*)request
{
    NSLog(@"Succes upload portait");
    //[self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGIN];
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_S3_UPLOAD_PORTAIT];
}
-(void)didS3UploadPortaitFail:(ASIS3ObjectRequest*)request
{
    NSLog(@"Failed upload portait");
    if ([request error]) {
        NSLog(@"%@",[[request error] localizedDescription]);
    }
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_S3_UPLOAD_PORTAIT];
}

- (void)searchOppWithOption:(SearchOppType)searchOppType
                withPostfix:(NSString *)postfix
                 withUserID:(NSString *)userID
{
    if(searchOppType == SEARTH_OPP_WITH_RANDOM) {
        //Random select opponents
        [self searchOppRandomwithUserID: userID];
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_search_opp.php", self.serverAddress]];
    
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

        [request setDelegate:self];
        [request setDidFinishSelector:@selector(didSearchOppSuccess:)];
        [request setDidFailSelector:@selector(didSearchOppFail:)];
        
        int temp = searchOppType;
        NSLog(@"postfix = %@, searchOppType = %i", postfix, temp);
        [request setPostValue:userID forKey:@"userID"];
        // POST Query
        [request setPostValue:StringFormat_SearchOppType[searchOppType-1] forKey:@"searchOppType"];
        if(searchOppType == SEARTH_OPP_WITH_EMAIL) {
            [request setPostValue:postfix forKey:@"oppEmail"];
        } else if(searchOppType == SEARTH_OPP_WITH_NICKNAME) {
            [request setPostValue:postfix forKey:@"oppNickName"];
        } else {
            //Error handling
        }
        
        [request setPostValue:self.UUID forKey:@"UUID"];
        [HttpConn addOperation:request];
    }
}
- (void)searchOppRandomwithUserID:(NSString *)userID
{
   // NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/menuNewGamePopupView_random.php"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_search_opp_random.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didSearchOppSuccess:)];
    [request setDidFailSelector:@selector(didSearchOppFail:)];
    
    [request setPostValue:userID forKey:@"userID"];
    // POST Query
    //[request setPostValue:StringFormat_SearchOppType[searchOppType-1] forKey:@"searchOppType"];
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
    
}
- (void)didSearchOppSuccess:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_SEARCH_OPP];
}

- (void)didSearchOppFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_SEARCH_OPP];
}

- (NSString *)convertToUTF8String:(NSString *)string
{
    return [NSString stringWithFormat:@"%s", [string UTF8String]];
}
-(NSString *) S3GetDestinationFor:(NSString *)userID withOppID:(NSString *) oppID isComment:(BOOL)isCommnet
{
    if(isCommnet)
        return [NSString stringWithFormat:@"%@/%@/%@_com.caf", USER_COMMEN_PATH_AT_SERVER, userID , oppID];
    else
        return [NSString stringWithFormat:@"%@/%@/%@.caf", USER_COMMEN_PATH_AT_SERVER, userID , oppID];
}
- (void)S3UploadFileForUser:(NSString *) userID withOppID:(NSString*) oppID isComment:(BOOL) isComment
{
    //if(isComment)
    //    NSString *filePath = [DOCUMENTS_FOLDER stringByAppendingString:@"/mycomment.caf"];
    //else
        NSString *filePath = [DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"];
    
    NSString *destination = [self S3GetDestinationFor:userID
                                            withOppID:oppID
                                            isComment:isComment];
    
    ASIS3ObjectRequest *request =[ASIS3ObjectRequest PUTRequestForFile:filePath withBucket:self.bucketName key:destination];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didS3UploadSuccess:withType:) ];
    [request setDidFailSelector:@selector(didS3UploadFail:)];
    [requestQueue addOperation:request];

}
-(void)didS3UploadSuccess:(ASIS3ObjectRequest*)request withType:(int) type
{
    NSLog(@"S3 upload Succes");
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_S3_UPLOAD];
}
-(void)didS3UploadFail:(ASIS3ObjectRequest*)request withType:(int) type
{
    NSLog(@"S3 upload Failed");
    if ([request error]) {
        NSLog(@"%@",[[request error] localizedDescription]);
    }
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_S3_UPLOAD];
}

- (void)finishRecordingForPlayer:(Player *)player
                        WithPath:(NSString *)audioPath 
                       forAnswer:(NSString *)answer
                      withReward:(int)reward
                         forGame:(GuessGame*)game
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_game_finish_recording.php", self.serverAddress]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishRecordingForPlayer:)];
    [request setDidFailSelector:@selector(didFinishRecordingForPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_FINISH_RECORDING];
    [request setPostValue:type forKey:@"type"];
    
    // Update the game under userID
    [request setPostValue:game.userID forKey:@"userID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", game.round] forKey:@"round"];
    [request setPostValue:[NSString stringWithFormat:@"%d", reward] forKey:@"userReward"];
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_WAIT] forKey:@"userGameState"];
    
    // Update the game under oppID
    [request setPostValue:game.oppID forKey:@"oppID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", game.round] forKey:@"round"];
    
    NSString *answerEncoded = [self convertToUTF8String:answer];
    //NSString *answerEncoded1 = [answer UTF8String];
    //NSString *answerEncoded1 = [NSString stringWithUTF8String:answer];
    
    
    [request setPostValue: answerEncoded forKey:@"oppAnswer"];
    
    if (game.startOfGame)
    {
        [request setPostValue:@"1" forKey:@"needsInsert"]; // need insert
        [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_ACCEPT] forKey:@"oppGameState"];
    }
    else
    {
        [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_GUESS] forKey:@"oppGameState"];
        [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_WAIT] forKey:@"oppGameStateCheckValue"];
    }
    
    [request setPostValue:[NSString stringWithFormat:@"%d", reward] forKey:@"oppReward"];
    NSLog(@"In httpconn: audioName = %@", game.audioFileName);
    [request setPostValue:game.audioFileName forKey:@"audioName"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}


- (void)changeOnlineStateForLogout:(NSString *)userID
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/push_notification.php"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@push_notification.php", self.serverAddress]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didChangeOnlineState:)];
    [request setDidFailSelector:@selector(didFailChangeOnlineState:)];
    
    [request setPostValue:@"offline" forKey:@"cmd"];
    [request setPostValue:userID forKey:@"userID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didChangeOnlineState:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGOUT];
}

- (void)didFailChangeOnlineState:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_LOGOUT];
}

- (void)finishAcceptGameForPlayer:(Player *)player
                          forGame:(GuessGame *)game
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/GuessGame.php"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_game_general.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishAcceptForPlayer:)];
    [request setDidFailSelector:@selector(didFinishAcceptForPlayerFail:)];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_FINISH_ACCEPT];
    [request setPostValue:type forKey:@"type"];
    
    // Update the game under userID
    [request setPostValue:game.userID forKey:@"userID"];
    [request setPostValue:game.oppID forKey:@"oppID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_GUESS] forKey:@"userGameState"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)finishShowResultForPlayer:(Player *)player
                          forGame:(GuessGame *)game
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/GuessGame.php"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_game_general.php", self.serverAddress]];
    
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishShowResultForPlayer:)];
    [request setDidFailSelector:@selector(didFinishShowResultForPlayerFail:)];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_FINISH_SHOW_RESULT];
    [request setPostValue:type forKey:@"type"];
    
    // Update the game under userID
    [request setPostValue:game.userID forKey:@"userID"];
    [request setPostValue:game.oppID forKey:@"oppID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", game.reward] forKey:@"needsReward"];
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_GUESS] forKey:@"userGameState"];
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_WAIT] forKey:@"needsCheckFinishRecording"];
    int exp = [GuessGame getExpForTurn:game.round-1];
    if (player.inventory.dayOfVIP != 0) exp += 10;
    [request setPostValue:[NSString stringWithFormat:@"%d", exp] forKey:@"gainedExp"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];

}

- (void)startRecordingForPlayer:(Player *)player
                        forGame:(GuessGame *)game
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/GenerateQuestion.php"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_game_start_recording.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didStartRecordingForPlayer:)];
    [request setDidFailSelector:@selector(didStartRecordingForPlayerFail:)];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_START_RECORDING];
    [request setPostValue:type forKey:@"type"];
    
    // Update the game under userID
    [request setPostValue:game.userID forKey:@"userID"];
    [request setPostValue:game.oppID forKey:@"oppID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_RECORD] forKey:@"userGameState"];
    if(game.startOfGame)
        [request setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"FirstTime"];
    [request setPostValue:[NSString stringWithFormat:@"%d", game.themeID] forKey:@"superiorClass"];
    [request setPostValue:[NSString stringWithFormat:@"%@", game.vipEnpowered?@"1":@"0"] forKey:@"vipEnpowered"];
    
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}


- (void)S3UploadForFinishGuessForPlayer:(NSString *)userID
                              withOppID:(NSString *)oppID
{
    NSString *filePath = [DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"];
    
    NSString *destination = [self S3GetDestinationFor:userID
                                            withOppID:oppID
                                            isComment:TRUE];
    
    ASIS3ObjectRequest *request =[ASIS3ObjectRequest PUTRequestForFile:filePath withBucket:self.bucketName key:destination];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didS3UploadSuccess:withType:)];
    [request setDidFailSelector:@selector(didS3UploadFail:)];
    [requestQueue addOperation:request];
    
}
/*
-(void)didS3UploadSuccess:(ASIS3ObjectRequest*)request withType:(int) type
{
    NSLog(@"S3 upload Succes");
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_S3_UPLOAD];
}
-(void)didS3UploadFail:(ASIS3ObjectRequest*)request withType:(int) type
{
    NSLog(@"S3 upload Failed");
    if ([request error]) {
        NSLog(@"%@",[[request error] localizedDescription]);
    }
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_S3_UPLOAD];
}
*/

- (void)finishGuessForPlayer:(Player *)player
                   WithGuess:(NSString *)guess
              andCommentPath:(NSString *)commentPath
                     forGame:(GuessGame *)game
                 withRequest:(ASIFormDataRequest *)request
{
    // Update the game under userID
    [request setPostValue:game.userID forKey:@"userID"];
    [request setPostValue:game.oppID forKey:@"oppID"];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_PRE_RECORD] forKey:@"userGameState"];
    [request setPostValue:[NSString stringWithFormat:@"%d", game.reward] forKey:@"needsReward"];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", GAMESTATE_RESULT] forKey:@"oppGameState"];
    [request setPostValue:commentPath forKey:@"oppCommentPath"];
    
    [request setPostValue:[NSString stringWithFormat:@"%s", [guess UTF8String]] forKey:@"oppGuess"];
    [request setPostValue:[NSString stringWithFormat:@"%d", game.reward] forKey:@"oppRealReward"];
    int exp = [GuessGame getExpForTurn:game.round];
    if (player.inventory.dayOfVIP != 0) exp += 10;
    [request setPostValue:[NSString stringWithFormat:@"%d", exp] forKey:@"gainedExp"];
    [request setPostValue:guess forKey:@"guess"];
    
    if (game.commentPath)
    {
        //
        [request setFile:[DOCUMENTS_FOLDER stringByAppendingString:@"/record.caf"] forKey:@"file"];
        //[request setFile:game.commentPath forKey:@"file"];
    }
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)finishGuessingForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath
                        forGame:(GuessGame *)game
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/GuessGame.php"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_game_general.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishGuessingForPlayer:)];
    [request setDidFailSelector:@selector(didFinishGuessingForPlayerFail:)];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_FINISH_GUESSING];
    [request setPostValue:type forKey:@"type"];
    
    [self finishGuessForPlayer:player WithGuess:guess andCommentPath:commentPath forGame:game withRequest:request];
}

- (void)finishContinueForPlayer:(Player *)player
                      WithGuess:(NSString *)guess
                 andCommentPath:(NSString *)commentPath
                        forGame:(GuessGame *)game
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/GuessGame.php"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_game_general.php", self.serverAddress]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didFinishContinueForPlayer:)];
    [request setDidFailSelector:@selector(didFinishContinueForPlayerFail:)];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_FINISH_GUESSING];
    [request setPostValue:type forKey:@"type"];
    
    [self finishGuessForPlayer:player WithGuess:guess andCommentPath:commentPath forGame:game withRequest:request];
}

- (void)deleteGameForPlayerID:(NSString *)userID withOppID:(NSString *)oppID
{
    //NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/DeleteGame.php"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_delete_game.php", self.serverAddress]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didDeleteGameForPlayer:)];
    [request setDidFailSelector:@selector(didDeleteGameForPlayerFail:)];
    
    // POST Query
    NSString * type = [NSString stringWithFormat:@"%d", REQUEST_TYPE_DELETE_GAME];
    [request setPostValue:type forKey:@"type"];
    
    // Update the game under userID
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oppID forKey:@"oppID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)deleteFile:(NSString *)requestFilePath
{
    int indexOfLastSlash = (int)([requestFilePath rangeOfString:@"/" options:NSBackwardsSearch].location);
    
    NSString *path = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat: @"/%@", [requestFilePath substringFromIndex:indexOfLastSlash+1]]];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (BOOL)checkFileExists:(NSString *)requestFilePath
{
    int indexOfLastSlash = (int)([requestFilePath rangeOfString:@"/" options:NSBackwardsSearch].location);
    
    NSString *path = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat: @"/%@", [requestFilePath substringFromIndex:indexOfLastSlash+1]]];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)deletePreviousFile:(NSString *)requestFilePath
{
    /*
    int indexOfLastSlash = (int)([requestFilePath rangeOfString:@"/" options:NSBackwardsSearch].location);
    NSString *filePath = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat: @"/%@", [requestFilePath substringFromIndex:indexOfLastSlash+1]]];
    
    int indexOfRound = (int)([filePath rangeOfString:@"_" options:NSBackwardsSearch].location);
    int round = [[filePath substringFromIndex:indexOfRound+1] integerValue];
    
    NSString *previousFilePath = [NSString stringWithFormat:@"%@_%d.caf", [filePath substringToIndex:indexOfRound], round-2];
     */
    
    NSString *previousFilePath = requestFilePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:previousFilePath])
    {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:previousFilePath error:&error];
    }
}

// gaoshen
- (void)getFileWithPath:(NSString *)filePath storeAt:(NSString*) savePath
{
    ASIS3ObjectRequest *request = [ASIS3ObjectRequest requestWithBucket:self.bucketName key:filePath];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didGetFile:)];
    [request setDidFailSelector:@selector(didGetFileFail:)];
    [request setDownloadDestinationPath:savePath];
    [requestQueue addOperation:request];
     
}
- (void)didGetFile:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_DOWNLOAD_FILE];
}

- (void)didGetFileFail:(ASIHTTPRequest *)request
{
    if ([request error]) {
        NSLog(@"%@",[[request error] localizedDescription]);
    }
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_DOWNLOAD_FILE];
}

- (void)S3DownloadFileForUser:(NSString*) userID fromOpp:(NSString*) oppID isComment:(BOOL) isComment
{
    // IMPORTANT : download from Opp's direcotoy
    NSString * path =[self S3GetDestinationFor:oppID withOppID:userID isComment:isComment];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *destination = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat:@"/%@/audio.caf", [defaults objectForKey:@"userID"]]];
    [self deletePreviousFile:destination];
    [self getFileWithPath:path storeAt:destination];
    
}
- (void)downloadFileFrom:(NSString*)requestFilePath
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat:@"/%@/audio.caf", [defaults objectForKey:@"userID"]]];
    
    [self deletePreviousFile:path];
    [self getFileWithPath:[NSString stringWithFormat:@"%@/%@",USER_COMMEN_PATH_AT_SERVER,requestFilePath] storeAt:path ];
}
- (void)getPortraitOfPlayerID:(NSString *)userID storeAtPath:(NSString *)filePath
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/user.png", USER_COMMEN_PATH_AT_SERVER, userID];
    ASIS3ObjectRequest *request = [ASIS3ObjectRequest requestWithBucket:self.bucketName key:path];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didGetPortrait:)];
    [request setDidFailSelector:@selector(didGetPortraitFail:)];
    
    [self deletePreviousFile:filePath];
    [request setDownloadDestinationPath:filePath];
    
    [requestQueue addOperation:request];
}

- (void)didGetPortrait:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_GET_PORTRAIT];
}

- (void)didGetPortraitFail:(ASIHTTPRequest *)request
{
    if ([request error]) {
        NSLog(@"%@",[[request error] localizedDescription]);
    }
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_GET_PORTRAIT];
}


- (void)didFinishRecordingForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_RECORDING];
}

- (void)didFinishRecordingForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_RECORDING];
}

- (void)didFinishShowResultForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_SHOW_RESULT];
}

- (void)didFinishShowResultForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_SHOW_RESULT];
}

- (void)didStartRecordingForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_START_RECORDING];
}

- (void)didStartRecordingForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_START_RECORDING];
}

- (void)didFinishAcceptForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_ACCEPT];
}

- (void)didFinishAcceptForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_ACCEPT];
}

- (void)didFinishGuessingForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_GUESSING];
}

- (void)didFinishGuessingForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_GUESSING];
}

- (void)didFinishContinueForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_CONTINUE];
}

- (void)didFinishContinueForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_FINISH_CONTINUE];
}

- (void)didDeleteGameForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_DELETE_GAME];
}

- (void)didDeleteGameForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_DELETE_GAME];
}


- (void)reloadGameForPlayer:(Player *)player
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_get_games.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseSessionPersistence:YES];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didReloadGamesForPlayer:)];
    [request setDidFailSelector:@selector(didReloadGamesForPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_UPDATE_PLAYER] forKey:@"type"];
    
    // POST Query
    NSString * userID = player.ID;
    [request setPostValue:userID forKey:@"userID"];
    
    int amount = 0;
    for (GuessGame *game in player.gamesArray)
    {
        if (game.playerGameState == GAMESTATE_WAIT )
        {
            amount++;
            NSString *targetVarName = [NSString stringWithFormat:@"target%d", amount];
            [request setPostValue:game.oppID forKey:targetVarName];
        }
    }
    
    [request setPostValue:[NSString stringWithFormat:@"%d", amount] forKey:@"amount"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    
    //[request setPostValue:game.userEmail forKey:@"userID"];
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
    
}

/*
- (void)loginForPlayer:(Player *)player
{
    NSURL *url = [NSURL URLWithString:@"http://ec2-184-169-195-183.us-west-1.compute.amazonaws.com/AppTest/Player_LogIn.php"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didLoginForPlayer:)];
    [request setDidFailSelector:@selector(didLoginForPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_RETRIEVE_PLAYER] forKey:@"type"];
    
    // POST Query
    NSString * userID = player.ID;
    [request setPostValue:userID forKey:@"userID"];
 
 [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];


}*/

- (void)didReloadGamesForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_UPDATE_PLAYER];
}

- (void)didReloadGamesForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_UPDATE_PLAYER];
}

/*
- (void)didLoginForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_RETRIEVE_PLAYER];
}

- (void)didLoginForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_RETRIEVE_PLAYER];
}*/

- (void)updateInfoForPlayerID:(NSString *)userID
                   withOldPwd:(NSData *)oldPwd
                   withNewPwd:(NSData *)newPwd
                 withNickname:(NSString *)nickname
                 withPortrait:(UIImage *)portrait
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_set_user_info.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didUpdateInfoForPlayerID:)];
    [request setDidFailSelector:@selector(didUpdateInfoForPlayerIDFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_UPDATE_PLAYER_INFO] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oldPwd forKey:@"pwd"];
    if (newPwd) [request setPostValue:newPwd forKey:@"newpwd"];
    if (nickname) [request setPostValue:nickname forKey:@"nickname"];
    if(portrait)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER, userID];
        
        [request setFile:filePath forKey:@"file"];
        [request setPostValue:@"1" forKey:@"upload"];
    }
    
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didUpdateInfoForPlayerID:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_UPDATE_PLAYER_INFO];
}

- (void)didUpdateInfoForPlayerIDFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_UPDATE_PLAYER_INFO];
}

- (void)retrieveInfoPlayerID:(NSString *)userID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_get_user_info.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didRetrieveInfoForPlayerID:)];
    [request setDidFailSelector:@selector(didRetrieveInfoForPlayerIDFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_RETRIEVE_PLAYER_INFO] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    // post UUID for prevent multi login
    [request setPostValue:self.UUID forKey:@"deviceID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didRetrieveInfoForPlayerID:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_RETRIEVE_PLAYER_INFO];
}

- (void)didRetrieveInfoForPlayerIDFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_RETRIEVE_PLAYER_INFO];
}

- (void)banPlayerID:(NSString *)userID withTargetPlayerID:(NSString *)oppID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_ban_user.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didBanPlayer:)];
    [request setDidFailSelector:@selector(didBanPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_BAN_PLAYER] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oppID forKey:@"oppID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didBanPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_BAN_PLAYER];
}

- (void)didBanPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_BAN_PLAYER];
}

- (void)unbanPlayerID:(NSString *)userID withTargetPlayerNickname:(NSString *)oppNickname
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_unban_user.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didUnbanPlayer:)];
    [request setDidFailSelector:@selector(didUnbanPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_UNBAN_PLAYER] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oppNickname forKey:@"nickname"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)unbanPlayerID:(NSString *)userID withTargetPlayerEmail:(NSString *)oppEmail
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_unban_user.php", self.serverAddress]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didUnbanPlayer:)];
    [request setDidFailSelector:@selector(didUnbanPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_UNBAN_PLAYER] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oppEmail forKey:@"nickname"];
    [request setPostValue:@"1" forKey:@"isEmail"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didUnbanPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_UNBAN_PLAYER];
}

- (void)didUnbanPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_UNBAN_PLAYER];
}

- (void)useCrackHammerForPlayerID:(NSString *)userID oppID:(NSString *)oppID
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_use_hammer_answer.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didUseCrackHammerForPlayer:)];
    [request setDidFailSelector:@selector(didUseCrackHammerForPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_USE_HAMMER] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oppID forKey:@"oppID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didUseCrackHammerForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_USE_HAMMER];
}

- (void)didUseCrackHammerForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_USE_HAMMER];
}

- (void)useRefreshHammerForPlayerID:(NSString *)userID oppID:(NSString *)oppID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_use_hammer_question.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didUseRefreshHammerForPlayer:)];
    [request setDidFailSelector:@selector(didUseRefreshHammerForPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_USE_HAMMER] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:oppID forKey:@"oppID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didUseRefreshHammerForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_USE_HAMMER];
}

- (void)didUseRefreshHammerForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_USE_HAMMER];
}

- (void)snoozeForGame:(GuessGame *)game
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@push_notification.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didsnoozeForGame:)];
    [request setDidFailSelector:@selector(didsnoozeForGameFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_PUSH_SNOOZE] forKey:@"type"];
    
    // POST Query
    //[request setPostValue:userID forKey:@"userID"];
    //[request setPostValue:oppID forKey:@"oppID"];
    
    [request setPostValue:@"push" forKey:@"cmd"];
    [request setPostValue:game.userID forKey:@"userID"];
    [request setPostValue:game.oppID forKey:@"oppID"];
    
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
    
}
- (void)didsnoozeForGame:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_PUSH_SNOOZE];
}

- (void)didsnoozeForGameFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_PUSH_SNOOZE];
}


- (void)purchaseItemWithGold:(PurchaseItemType)type amount:(int)amount gold:(int)gold userID:(NSString *)userID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_purchase_with_gold.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didPurchaseWithGoldForPlayer:)];
    [request setDidFailSelector:@selector(didPurchaseWithGoldForPlayerFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_PURCHASE_ITEM_WITH_GOLD] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", amount] forKey:@"amount"];
    [request setPostValue:[NSString stringWithFormat:@"%d", gold] forKey:@"gold"];
    [request setPostValue:[NSString stringWithFormat:@"%d", type] forKey:@"item"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didPurchaseWithGoldForPlayer:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_PURCHASE_ITEM_WITH_GOLD];
}

- (void)didPurchaseWithGoldForPlayerFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_PURCHASE_ITEM_WITH_GOLD];
}

- (void)useKeyForPlayerID:(NSString *)userID albumID:(NSString *)albumID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_use_key_album.php", self.serverAddress]];
    
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didUseKeyForPlayerID:)];
    [request setDidFailSelector:@selector(didUseKeyForPlayerIDFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_USE_KEY] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:albumID forKey:@"albumID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didUseKeyForPlayerID:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_USE_KEY];
}

- (void)didUseKeyForPlayerIDFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_USE_KEY];
}

- (void)collectBonusForPlayerID:(NSString *)userID
                           type:(BonusType)type
                           gold:(int)gold
                         hammer:(int)hammer
                            key:(int)key
                       dayOfVIP:(int)dayOfVIP
                      productID:(NSString *)productID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@guess_collect_bonus.php", self.serverAddress]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(didCollectBonusForPlayerID:)];
    [request setDidFailSelector:@selector(didCollectBonusForPlayerIDFail:)];
    
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=UTF-8;"];
    [request setPostValue:[NSString stringWithFormat:@"%d", REQUEST_TYPE_COLLECT_BONUS] forKey:@"type"];
    
    // POST Query
    [request setPostValue:userID forKey:@"userID"];
    [request setPostValue:[NSString stringWithFormat:@"%d", type] forKey:@"bonusType"];
    if (gold != 0) [request setPostValue:[NSString stringWithFormat:@"%d", gold] forKey:@"gold"];
    if (hammer != 0) [request setPostValue:[NSString stringWithFormat:@"%d", hammer] forKey:@"hammer"];
    if (key != 0) [request setPostValue:[NSString stringWithFormat:@"%d", key] forKey:@"key"];
    if (dayOfVIP != 0) [request setPostValue:[NSString stringWithFormat:@"%d", dayOfVIP] forKey:@"dayOfVIP"];
    if (productID) [request setPostValue:productID forKey:@"productID"];
    
    [request setPostValue:self.UUID forKey:@"UUID"];
    [HttpConn addOperation:request];
}

- (void)didCollectBonusForPlayerID:(ASIHTTPRequest *)request
{
    [self.delegate didFinishSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_COLLECT_BONUS];
}

- (void)didCollectBonusForPlayerIDFail:(ASIHTTPRequest *)request
{
    [self.delegate didFailSelector:[HttpConn parseResponse:request] withType:REQUEST_TYPE_COLLECT_BONUS];
}




@end