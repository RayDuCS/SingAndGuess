//
//  Inventory.h
//  Guess
//
//  Created by Rui Du on 10/9/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpConn.h"

typedef enum {
    HAMMER_USAGE_OPTION_REFRESH = 1,
    HAMMER_USAGE_OPTION_CRACK = 2
}HammerUsageOption;

typedef enum {
    ALBUM_NAME_EMOTION = 1,
    ALBUM_NAME_FILM = 2,
    ALBUM_NAME_GAME = 3,
    ALBUM_NAME_LIFE = 4,
    ALBUM_NAME_MAGIC = 5,
    ALBUM_NAME_SCENE = 6,
    ALBUM_NAME_SONG = 7,
    ALBUM_NAME_TV = 8,
}AlbumName;

@protocol InventorySpinnerDelegate <NSObject>

@required
- (void)requestDidFinish:(BOOL)success
            withResponse:(NSDictionary *)serverResponse
                withType:(RequestType)type;

@end

@interface Inventory : NSObject<HttpConnDelegate>

@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *userID;
@property (nonatomic) int numOfHammers;
@property (nonatomic) int numOfKeys;
@property (nonatomic) int dayOfVIP;
@property (strong, nonatomic) NSString *albumInfo;
@property (strong, nonatomic) HttpConn *httpConn;

- (Inventory *)initWithUserID:(NSString *)userID
                 numOfHammers:(int)numOfHammers
                    numOfKeys:(int)numOfKeys
                     dayOfVIP:(int)dayOfVIP
                    albumInfo:(NSString *)albumInfo;
- (BOOL)usesHammerWithAmount:(int)amount
                       oppID:(NSString *)oppID
                      option:(HammerUsageOption)option;
- (void)purchaseHammerAmount:(int)amount
                        gold:(int)gold;
- (void)purchaseKeyAmount:(int)amount
                     gold:(int)gold;
- (void)purchaseVIPAmount:(int)amount
                     gold:(int)gold;
- (void)useKeyTargetAlbumID:(AlbumName)albumName;

@end
