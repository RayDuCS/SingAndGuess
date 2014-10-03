//
//  GuessIAP.m
//  Guess
//
//  Created by Rui Du on 12/3/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "GuessIAP.h"
#import "UIViewCustomAnimation.h"

@interface GuessIAP()
@end

@implementation GuessIAP
@synthesize delegate = _delegate;
@synthesize userID = _userID;
@synthesize httpConn = _httpConn;


+ (GuessIAP *)sharedInstance
{
    static dispatch_once_t once;
    static GuessIAP * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.slidea.Guess.buy_gold.tier1",
                                      @"com.slidea.Guess.buy_gold.tier2",
                                      @"com.slidea.Guess.buy_gold.tier4",
                                      //@"com.slidea.Guess.buy_vip.tier1",
                                      //@"com.slidea.Guess.buy_vip.tier5",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (void)initializeHttp
{
    self.httpConn = [[HttpConn alloc] initWithDelegate:self];
}

- (void)buyProduct:(SKProduct *)product
{
    if (!self.userID) {
        [UIViewCustomAnimation showAlert:@"未知错误，请重新登陆"];
        return;
    }
    
    [super buyProduct:product];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [super provideContentForProductIdentifier:productIdentifier];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int previousPending = [defaults integerForKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setInteger:previousPending+1 forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    int gold=0, dayOfVIP=0;
    
    if ([productIdentifier isEqualToString:@"com.slidea.Guess.buy_gold.tier1"]) {
        gold = 2500;
    } else if ([productIdentifier isEqualToString:@"com.slidea.Guess.buy_gold.tier2"]) {
        gold = 6250;
    } else if ([productIdentifier isEqualToString:@"com.slidea.Guess.buy_gold.tier4"]) {
        gold = 15500;
    //} else if ([productIdentifier isEqualToString:@"com.slidea.Guess.buy_vip.tier1"]) {
    //    dayOfVIP = 30;
    //} else if ([productIdentifier isEqualToString:@"com.slidea.Guess.buy_vip.tier5"]) {
    //    dayOfVIP = -1;
    }
    
    [self.httpConn collectBonusForPlayerID:self.userID
                                      type:BONUS_TYPE_IAP
                                      gold:gold
                                    hammer:0
                                       key:0
                                  dayOfVIP:dayOfVIP
                                 productID:productIdentifier];
}

+ (void)resetProductIDs
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"com.slidea.Guess.buy_gold.tier1"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"com.slidea.Guess.buy_gold.tier2"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"com.slidea.Guess.buy_gold.tier4"];
    //[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"com.slidea.Guess.buy_vip.tier1"];
    //[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"com.slidea.Guess.buy_vip.tier5"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)decreaseProductID:(NSString *)productID
{
    if (!productID) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int previousPending = [defaults integerForKey:productID];
    previousPending--;
    [defaults setInteger:previousPending forKey:productID];
    [defaults synchronize];
}

- (void)didFinishSelector:(NSDictionary *)response withType:(RequestType)type
{
    NSString *productID;
    switch (type) {
        case REQUEST_TYPE_COLLECT_BONUS:
            productID = [response objectForKey:@"productID"];
            [GuessIAP decreaseProductID:productID];
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
