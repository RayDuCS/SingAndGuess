//
//  GuessIAP.h
//  Guess
//
//  Created by Rui Du on 12/3/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "IAPHelper.h"
#import "HttpConn.h"

@protocol IAPSpinnerDelegate <NSObject>

@required
- (void)requestDidFinish:(BOOL)success
withResponse:(NSDictionary *)serverResponse
withType:(RequestType)type;

@end

@interface GuessIAP : IAPHelper<HttpConnDelegate>

@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) HttpConn *httpConn;

+ (GuessIAP *)sharedInstance;
- (void)initializeHttp;
- (void)buyProduct:(SKProduct *)product;
+ (void)resetProductIDs;
@end
