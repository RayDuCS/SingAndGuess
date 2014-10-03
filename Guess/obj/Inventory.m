//
//  Inventory.m
//  Guess
//
//  Created by Rui Du on 10/9/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "Inventory.h"

@interface Inventory()

@end

@implementation Inventory
@synthesize userID = _userID;
@synthesize numOfHammers = _numOfHammers;
@synthesize numOfKeys = _numOfKeys;
@synthesize dayOfVIP = _dayOfVIP;
@synthesize albumInfo = _albumInfo;
@synthesize httpConn = _httpConn;
@synthesize delegate = _delegate;

- (Inventory *)initWithUserID:(NSString *)userID
                 numOfHammers:(int)numOfHammers
                    numOfKeys:(int)numOfKeys
                     dayOfVIP:(int)dayOfVIP
                    albumInfo:(NSString *)albumInfo
{
    self = [super init];
    if (!self)
        return self;
    
    self.numOfHammers = numOfHammers;
    self.numOfKeys = numOfKeys;
    self.dayOfVIP = dayOfVIP;
    self.userID = userID;
    self.albumInfo = albumInfo;
    
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
    
    return self;
}

- (BOOL)usesHammerWithAmount:(int)amount oppID:(NSString *)oppID option:(HammerUsageOption)option
{
    if (self.numOfHammers <= 0) return NO;
    
    self.numOfHammers -= amount;
    switch (option) {
        case HAMMER_USAGE_OPTION_CRACK:
            [self.httpConn useCrackHammerForPlayerID:self.userID oppID:oppID];
            break;
        case HAMMER_USAGE_OPTION_REFRESH:
            [self.httpConn useRefreshHammerForPlayerID:self.userID oppID:oppID];
            break;
    }
        
    return YES;
}

- (void)purchaseHammerAmount:(int)amount gold:(int)gold
{
    [self.httpConn purchaseItemWithGold:PURCHASE_ITEM_TYPE_HAMMER
                                 amount:amount
                                  gold:gold
                                 userID:self.userID];
}

- (void)purchaseKeyAmount:(int)amount gold:(int)gold
{
    [self.httpConn purchaseItemWithGold:PURCHASE_ITEM_TYPE_KEY
                                 amount:amount
                                  gold:gold
                                 userID:self.userID];
}

- (void)purchaseVIPAmount:(int)amount gold:(int)gold
{
    [self.httpConn purchaseItemWithGold:PURCHASE_ITEM_TYPE_VIP
                                 amount:amount
                                   gold:gold
                                 userID:self.userID];
}

- (void)useKeyTargetAlbumID:(AlbumName)albumName
{
    [self.httpConn useKeyForPlayerID:self.userID
                             albumID:[NSString stringWithFormat:@"%d", albumName]];
}

- (void)didFinishSelector:(NSDictionary *)response withType:(RequestType)type
{
    switch (type) {
        case REQUEST_TYPE_USE_HAMMER:
            break;
        case REQUEST_TYPE_PURCHASE_ITEM_WITH_GOLD:
            //self.numOfHammers =
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
