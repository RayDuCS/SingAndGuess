//
//  MenuViewController.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "MenuViewController.h"
#import "UserView.h"
#import "RDMTPopupWindow.h"
#import "RecordGameViewController.h"
#import "GuessGameViewController.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"
#import "NSData+Encryption.h"
#import "UICustomColor.h"
#import "GuessAppDelegate.h"
#import "GuessIAP.h"


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define ADBANNER_APPEAR_DURATION 1.5
#define ADBANNER_MARGIN_DISTENCE_TOP 20

#define TABLEVIEW_MOVE_DOWN_DURATION 3.0
#define TABLE_TRANSFORM_DISTENCE 40
#define TABLEREFRESHHEADER_TRANSFORM_DISTENCE 30

#define GAME_URL @"https://itunes.apple.com/us/app/heng-gei-ni-ting/id583767432?ls=1&mt=8"

//#define ADBANNER_MARGIN_DISTENCE_BOTTOM

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *gameTableView;
@property (weak, nonatomic) IBOutlet UIView *tableRefreshHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *tableRefreshHeaderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tableRefreshImageView;
@property (nonatomic) TableState currentTableState;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *prizeBtn;
@property (weak, nonatomic) IBOutlet UIButton *sinaBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoBtn;

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) GuessGame *game;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) RDMTPopupWindow *popupCreateGameWindow;
@property (weak, nonatomic) MenuSliderView *hiddenMenuView;
@property (weak, nonatomic) MenuNewGamePopupView *createNewGameView;

@property (nonatomic) int index;

@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;
@property (weak, nonatomic) NSMutableArray *oppIDGamesNeedsDownload;

@property (weak, nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (weak, nonatomic) UISwipeGestureRecognizer *swipeRight;
@property (weak, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (weak, nonatomic) UISwipeGestureRecognizer *swipeDown;
@property (weak, nonatomic) UITapGestureRecognizer *tap1;
@property (weak, nonatomic) UITapGestureRecognizer *tap2;

@property (nonatomic) BOOL waitingForComment;

@property (nonatomic) int adBannerStage;
@property (weak, nonatomic) IBOutlet UIButton *adSlidea;
@property (strong, nonatomic) AVAudioPlayer *sePlayer;
@property (strong, nonatomic) NSData *updatedPassword;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@property (strong, nonatomic) TutorialView *tutorialView;
@property (nonatomic) BOOL needsNotRefreshInfo;

@property (weak, nonatomic) UITextView *weiboField;
@property (weak, nonatomic) NSDictionary *userInfo;

@property BOOL isUpdatePortrait;
@end

@implementation MenuViewController
@synthesize gameTableView = _gameTableView;
@synthesize tableRefreshHeaderView = _tableRefreshHeaderView;
@synthesize tableRefreshHeaderLabel = _tableRefreshHeaderLabel;
@synthesize tableRefreshImageView = _tableRefreshImageView;
@synthesize currentTableState = _currentTableState;
@synthesize user = _user;
@synthesize game = _game;
@synthesize userView = _userView;
@synthesize hiddenMenuView = _hiddenMenuView;
@synthesize popupCreateGameWindow = _popupCreateGameWindow;
@synthesize createNewGameView = _createNewGameView;
@synthesize index = _index;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize oppIDGamesNeedsDownload = _oppIDGamesNeedsDownload;
@synthesize waitingForComment = _waitingForComment;
@synthesize adBannerStage = _adBannerStage;
@synthesize adSlidea = _adSlidea;
@synthesize sePlayer = _sePlayer;
@synthesize updatedPassword = _updatedPassword;
@synthesize isUpdatePortrait = _isUpdatePortrait;
@synthesize sinaweibo = _sinaweibo;
@synthesize tutorialView = _tutorialView;
@synthesize weiboField = _weiboField;
@synthesize needsNotRefreshInfo = _needsNotRefreshInfo;
@synthesize swipeLeft = _swipeLeft;
@synthesize swipeRight = _swipeRight;
@synthesize swipeUp = _swipeUp;
@synthesize swipeDown = _swipeDown;
@synthesize tap1 = _tap1;
@synthesize tap2 = _tap2;
@synthesize spinnerTimer = _spinnerTimer;
@synthesize userInfo = _userInfo;


- (void)setGameTableView:(UITableView *)gameTableView
{
    _gameTableView = gameTableView;
    self.gameTableView.delegate = self;
    self.gameTableView.dataSource = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)createFolderForPlayer:(Player *)player
{
    NSFileManager *filemgr;
    NSString *dir = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, player.ID];
    
    filemgr =[NSFileManager defaultManager];
    
    NSError *err = nil;
    if ([filemgr fileExistsAtPath:dir]) return;
    
    if ([filemgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error: &err] == NO)
    {
        // Failed to create directory
        NSLog(@"%@", err);
        return;
    }
    
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"user.png"]);
    [filemgr createFileAtPath:[dir stringByAppendingFormat:@"/user.png"] contents:imageData attributes:nil];
    //player.delegate = self;
    //[player getPortrait];
}

- (void)loadWithRegisteredUser:(Player *)registeredPlayer
                      userInfo:(NSDictionary *)userInfo
                 usingPopIndex:(int)index;
{
    self.userInfo = userInfo;
    [self unpackUserInfo];
    
    // Check for status in database.
    self.user = NULL;
    self.user = registeredPlayer;
    self.index = index;
    [self createFolderForPlayer:self.user];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [DOCUMENTS_FOLDER stringByAppendingString:@"/user.png"];
    NSString *destiPath = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@/user.png", self.user.ID];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSError *err;
        if ([fileManager fileExistsAtPath:destiPath]) [fileManager removeItemAtPath:destiPath error:&err];
        
        [fileManager copyItemAtPath:filePath toPath:destiPath error:&err];
        if (err) [UIViewCustomAnimation showAlert:@"获取您最新图片出错，请点击头像重新获取"];
            
        [fileManager removeItemAtPath:filePath error:&err];
    }
    
    if(self.user.inventory.dayOfVIP != 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.adBannerStage = -1;
        [defaults setObject:[NSString stringWithFormat:@"%d", self.adBannerStage]  forKey:@"bannerStage"];
        [defaults synchronize];
    }
    else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.adBannerStage = [[defaults objectForKey:@"bannerStage"] integerValue];
        if(self.adBannerStage == -1)
        {
            self.adBannerStage = 0;
        }
        [defaults setObject:[NSString stringWithFormat:@"%d", self.adBannerStage]  forKey:@"bannerStage"];
        [defaults synchronize];
    }
}

- (void)unpackUserInfo
{
    self.user = [self.userInfo objectForKey:@"user"];
    
    self.game = [self.userInfo objectForKey:@"game"];
    
    self.userView = [self.userInfo objectForKey:@"userView"];
    
    self.popupCreateGameWindow = [self.userInfo objectForKey:@"popup"];
    
    self.hiddenMenuView = [self.userInfo objectForKey:@"hidden"];
    
    self.createNewGameView = [self.userInfo objectForKey:@"createGameView"];
    
    self.spinner = [self.userInfo objectForKey:@"spinner"];
    
    self.editableItems = [self.userInfo objectForKey:@"editableItems"];
    
    self.oppIDGamesNeedsDownload = [self.userInfo objectForKey:@"array1"];
    
    self.adSlidea = [self.userInfo objectForKey:@"adSlidea"];
    
    self.weiboField = [self.userInfo objectForKey:@"textView"];
    
    self.swipeLeft = [self.userInfo objectForKey:@"swipeLeft"];
    
    self.swipeRight = [self.userInfo objectForKey:@"swipeRight"];
    
    self.swipeUp = [self.userInfo objectForKey:@"swipeUp"];
    
    self.swipeDown = [self.userInfo objectForKey:@"swipeDown"];
    
    self.tap1 = [self.userInfo objectForKey:@"tap1"];
    
    self.tap2 = [self.userInfo objectForKey:@"tap2"];
    
    bannerView_ = [self.userInfo objectForKey:@"bannerView"];
    
    postImageStatusText = [self.userInfo objectForKey:@"string1"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createFolderForPlayer:self.user];

    //self.hiddenMenuView = nil;
    self.hiddenMenuView = [self.hiddenMenuView initWithFrame:CGRectMake(0, 464.5, 320, 46.25) withController:self];
    
    //self.hiddenMenuView = [[MenuSliderView alloc] initWithFrame:CGRectMake(0, 464.5, 320, 46.25) withController:self];
    
    
    self.hiddenMenuView.delegate = self;
    [self.view addSubview:self.hiddenMenuView.view];
    
    self.tableRefreshHeaderView.alpha = 0;
    self.currentTableState = TABLE_STATE_NORMAL;
    
    self.tableRefreshHeaderLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    self.tableRefreshHeaderLabel.textColor = [UIColor whiteColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user.ID forKey:@"userID"];
    [defaults synchronize];
    
    self.bgView.userInteractionEnabled = YES;
    
    /*
    bannerView_ = [bannerView_ initWithFrame:CGRectMake(0.0,
                                            self.userView.view.frame.size.height+ADBANNER_MARGIN_DISTENCE_TOP,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    */
    bannerView_.frame = CGRectMake(0.0,FRAME_HEIGHT+ADBANNER_MARGIN_DISTENCE_TOP,GAD_SIZE_320x50.width,GAD_SIZE_320x50.height);
    
    NSLog(@"in the init frame");
    bannerView_.adUnitID = @"a1507f758be8091";
    
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    bannerView_.alpha = 0.0;
    
    GADRequest *request = [GADRequest request];
    //request.testing = YES; // test mode
    [bannerView_ loadRequest:request];
    
    self.adSlidea.frame = CGRectMake(0.0,FRAME_HEIGHT+ADBANNER_MARGIN_DISTENCE_TOP,GAD_SIZE_320x50.width,GAD_SIZE_320x50.height);
    
    [self.adSlidea setBackgroundImage:[UIImage imageNamed:@"adSlidea.png"] forState:UIControlStateNormal];
    //[self.adSlidea setTitle:@"亲，快来买VIP去掉广告吧！" forState:UIControlStateNormal];
    [self.adSlidea setTitle:@"" forState:UIControlStateNormal];
    UIFont *font = [UICustomFont fontWithFontType:FONT_HUAKANG size:20];
    self.adSlidea.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self.adSlidea setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.adSlidea.titleLabel.font = font;
    
    self.adSlidea.alpha = 0.0;
    NSLog(@"before target");
    
    [self.view addSubview:self.adSlidea];
    
    
    //[UIApplication sharedApplication].delegate
    GuessAppDelegate *delegate = (GuessAppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate.sinaweibo logIn];
    _sinaweibo =delegate.sinaweibo;
    _sinaweibo.delegate = self;
    
    // Check if any leftover IAPs
    [self restoreIAPs];
    
    // display msg.
    if (self.user.msg) {
        if (![self.user.msg isEqualToString:@""]) {
            [UIViewCustomAnimation showAlert:self.user.msg];
            self.user.msg = @"";
        }
    }
}

- (void)restoreIAPs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int gold=0, dayOfVIP=0;
    int item_1 = [defaults integerForKey:@"com.slidea.Guess.buy_gold.tier1"];
    int item_2 = [defaults integerForKey:@"com.slidea.Guess.buy_gold.tier2"];
    int item_3 = [defaults integerForKey:@"com.slidea.Guess.buy_gold.tier4"];
    //int item_4 = [defaults integerForKey:@"com.slidea.Guess.buy_vip.tier1"];
    //int item_5 = [defaults integerForKey:@"com.slidea.Guess.buy_vip.tier5"];
    
    
    gold = item_1 * 2500 + item_2 * 6250 + item_3 * 15500;
    //if (item_5 > 0) dayOfVIP = -1;
    //else dayOfVIP = item_4 * 30;
    
    //if (gold == 0 && dayOfVIP == 0) return;
    if (gold == 0) return;
    
    self.user.delegate = self;
    [self.user restoreIAPsWithGold:gold dayOfVIP:dayOfVIP];
}


- (void)viewDidUnload
{
    [self setHiddenMenuView:nil];
    [self setGameTableView:nil];
    [self setTableRefreshHeaderView:nil];
    [self setTableRefreshHeaderLabel:nil];
    [self setBgView:nil];
    [self setPrizeBtn:nil];
    [self setSinaBtn:nil];
    [self setLogoBtn:nil];
    [self setTableRefreshImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setUser:nil];
    [self setGame:nil];
    [self setUserView:nil];
    [self setPopupCreateGameWindow:nil];
    [self setCreateNewGameView:nil];
    [self setSpinner:nil];
    [self setSePlayer:nil];
    [self setEditableItems:nil];
    [self setShade:nil];
    [self setOppIDGamesNeedsDownload:nil];
    [self setAdSlidea:nil];
    [self setUpdatedPassword:nil];
    [self setTutorialView:nil];
    [self setWeiboField:nil];
    [self setSpinnerTimer:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userView = [self.userView initWithPlayer:self.user];
    [self.view addSubview:self.userView.view];
    [self.view sendSubviewToBack:self.userView.view];
    [self.view sendSubviewToBack:self.bgView];
    
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.view addSubview:self.shade];
    
    self.spinner = [self.spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    [self.view addSubview:self.spinner];
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    [self.editableItems addObject:self.gameTableView];
    [self.editableItems addObject:self.hiddenMenuView];
    [self.editableItems addObject:self.userView];
    
    self.oppIDGamesNeedsDownload = [self.oppIDGamesNeedsDownload init];
    [self.oppIDGamesNeedsDownload removeAllObjects];
    
    //Add a left swipe gesture recognizer
    self.swipeLeft = [self.swipeLeft initWithTarget:self
                                             action:@selector(handleSwipeLeft:)];
    [self.swipeLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.gameTableView addGestureRecognizer:self.swipeLeft];
    
    //Add a right swipe gesture recognizer
    self.swipeRight = [self.swipeRight initWithTarget:self
                                               action:@selector(handleSwipeRight:)];
    self.swipeRight.delegate = self;
    [self.swipeRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.gameTableView addGestureRecognizer:self.swipeRight];
    
    self.tap1 = [self.tap1 initWithTarget:self action:@selector(handleTap:)];
    self.tap2 = [self.tap2 initWithTarget:self action:@selector(handleTap:)];
    [self.bgView addGestureRecognizer:self.tap1];
    [self.gameTableView addGestureRecognizer:self.tap2];
    
    self.swipeUp = [self.swipeUp initWithTarget:self
                                         action:@selector(handleSwipeUp:)];
    [self.swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.hiddenMenuView.view addGestureRecognizer:self.swipeUp];
    
    self.swipeDown = [self.swipeDown initWithTarget:self
                                             action:@selector(handleSwipeDown:)];
    self.swipeDown.delegate = self;
    [self.swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.hiddenMenuView.view addGestureRecognizer:self.swipeDown];
    
    [self.hiddenMenuView slideInSlider];
    
    
    [self.adSlidea addTarget:self action:@selector(adSlideaPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.adBannerStage = [[defaults objectForKey:@"bannerStage"] integerValue];
    //self.adBannerStage = 1;
    if(self.gameTableView.frame.origin.y == 105)
    {
        switch (self.adBannerStage) {
                
            case -1:
                self.gameTableView.transform = CGAffineTransformMakeTranslation(0, 0);
                self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, 0);
                self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, 0);
                self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                bannerView_.alpha = 0.0;
                self.adSlidea.alpha = 0.0;
                break;
            case 0:
                break;
            case 1:
                self.gameTableView.transform = CGAffineTransformMakeTranslation(0, TABLE_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                bannerView_.alpha = 1.0;
                break;
            case 2:
                self.gameTableView.transform = CGAffineTransformMakeTranslation(0, TABLE_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                break;
            case 3:
                self.gameTableView.transform = CGAffineTransformMakeTranslation(0, TABLE_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                bannerView_.alpha = 1.0;
                break;
            case 4:
                self.gameTableView.transform = CGAffineTransformMakeTranslation(0, TABLE_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
                break;
            default:
                //self.adBannerStage = 0;
                break;
        }

        
    }
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSURL * temp = [NSURL URLWithString:[defaults objectForKey:@"sinaUrl"]];
    //if (temp) {
    //    [self.sinaweibo handleOpenURL:temp];
    //}
    
    /* Animate heartbeat for button */
    if (self.user.uncollectRef > 0) {
        [UIViewCustomAnimation heartbeatAnimationForView:self.prizeBtn ratio:1.2 duration:0.5 repeat:20];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.adBannerStage = [[defaults objectForKey:@"bannerStage"] integerValue];
    //self.adBannerStage = 1;
    //self.adBannerStage = 4;
    

    switch (self.adBannerStage) {
        case -1:
            self.gameTableView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, 0);
            self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, 0);
            bannerView_.alpha = 0.0;
            self.adSlidea.alpha = 0.0;
            break;
        case 0:
            [UIView beginAnimations:@"stage 0" context:nil];
            [UIView setAnimationDuration:TABLEVIEW_MOVE_DOWN_DURATION];
            self.gameTableView.transform = CGAffineTransformMakeTranslation(0, TABLE_TRANSFORM_DISTENCE);
            bannerView_.alpha = 1.0;
            self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
            self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
            self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, TABLEREFRESHHEADER_TRANSFORM_DISTENCE);
            
            [UIView commitAnimations];
            
            self.adBannerStage++;
            break;
        case 1:
            
            self.adBannerStage++;
            break;
        case 2:
            
            [UIView beginAnimations:@"stage 2" context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(tableDidMoveDown)];
            [UIView setAnimationDuration:TABLEVIEW_MOVE_DOWN_DURATION];
            bannerView_.alpha = 0.0;
            self.adSlidea.alpha = 1.0;
            [UIView commitAnimations];
            
            self.adBannerStage++;
            break;
        case 3:
            self.adBannerStage++;
            break;
        case 4:
            [UIView beginAnimations:@"stage 4" context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(tableWillMoveUp)];
            [UIView setAnimationDuration:TABLEVIEW_MOVE_DOWN_DURATION];
            bannerView_.alpha = 0.0;
            self.adSlidea.alpha = 1.0;
            [UIView commitAnimations];
            
            self.adBannerStage++;
            break;
            
        default:
            self.adBannerStage = 0;
            break;
    }
    
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", self.adBannerStage] forKey:@"bannerStage"];
    [defaults synchronize];
     
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self setShade:nil];
    [self.tutorialView uninitialize];
    [self setTutorialView:nil];
    
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    [self.userView.view removeFromSuperview];
    [self.editableItems removeAllObjects];
    [self.oppIDGamesNeedsDownload removeAllObjects];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)tableDidMoveDown{
    
    [UIView beginAnimations:@"stage 2- continue" context:nil];
    [UIView setAnimationDuration:TABLEVIEW_MOVE_DOWN_DURATION];
    bannerView_.alpha = 1.0;
    self.adSlidea.alpha = 0.0;
    [UIView commitAnimations];
    
}

- (void)tableWillMoveUp{
    
    [UIView beginAnimations:@"stage 2- continue" context:nil];
    [UIView setAnimationDuration:TABLEVIEW_MOVE_DOWN_DURATION];
    self.adSlidea.alpha = 0.0;
    self.gameTableView.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView commitAnimations];
    
}

- (BOOL)shouldAutorotate {    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"recordGameSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:0];
    }
    else if ([segue.identifier isEqualToString:@"guessGameSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:0];
    }
    else if ([segue.identifier isEqualToString:@"preRecordGameSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:0];
    }
    else if ([segue.identifier isEqualToString:@"showResultSeg"])
    {
        [segue.destinationViewController loadWithPlayer:self.user
                                                 inGame:self.game
                                               userInfo:self.userInfo
                                            usePopIndex:0];
    }
}

- (void)loggedOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"logged"];
    [defaults synchronize];
}

- (void)logoutBtnPressed:(UIButton *)sender
{   
    UIViewController *vc = self.presentingViewController;
    
    for (int i=0; i<self.index; i++)
    {
        vc = vc.presentingViewController;
    }

    self.user.delegate = self;
    [self.user logout];
    [self loggedOut];

    [vc dismissModalViewControllerAnimated:YES];
}

- (void)tutorialBtnPressed:(UIButton *)sender
{
    self.tutorialView = [[TutorialView alloc] initWithFrame:self.view.frame];
    self.tutorialView.delegate = self;
    [self.tutorialView initialize];
    [self.view addSubview:self.tutorialView];
}

- (void)closeTutorial
{
    [self.tutorialView removeFromSuperview];
    [self setTutorialView:nil];
}

- (void)spinnerTimeout
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    //[UIViewCustomAnimation showAlert:@"连接超时"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.user.gamesArray count] + 1;
}

+ (UIImage *)getLevelImageForLevel:(int)level
{
    if (level <  5) return [UIImage imageNamed:@"menu_lv_1.png"];
    if (level < 10) return [UIImage imageNamed:@"menu_lv_2.png"];
    if (level < 15) return [UIImage imageNamed:@"menu_lv_3.png"];
    if (level < 20) return [UIImage imageNamed:@"menu_lv_4.png"];
    if (level < 25) return [UIImage imageNamed:@"menu_lv_5.png"];
    
    return [UIImage imageNamed:@"menu_lv_6.png"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"GuessGameCell";
    
    if (indexPath.row == 0)
    {
        CellIdentifier = @"NewGameCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unknown.png"]];
    }
    
    // Configure the cell...
    if ([CellIdentifier isEqualToString:@"NewGameCell"])
    {
        return cell;
    }
    
    // games on the go...
    
    GuessGame *game = [self.user.gamesArray objectAtIndex:indexPath.row - 1];
    GameState gameState = game.playerGameState;
    
    UIImageView *oppImageView = (UIImageView *)[cell.contentView viewWithTag:TABLE_CELL_TAG_IMAGE];
    NSString *oppImageFilePath = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@/%@.png", game.userID, game.oppID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oppImageFilePath])
    {
        [oppImageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png", DOCUMENTS_FOLDER, game.userID, game.oppID]]];
    }
    else
    {
        game.delegate = self;
        [game getOppPortrait];
    }
    
    UILabel *oppNameLabel = (UILabel *)[cell.contentView viewWithTag:TABLE_CELL_TAG_OPP_NAME];
    oppNameLabel.text = game.oppNickname;
    oppNameLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:17];
    
    UIImageView *oppLevelImageView = (UIImageView *)[cell.contentView viewWithTag:TABLE_CELL_TAG_LV_IMAGE];
    [oppLevelImageView setImage:[MenuViewController getLevelImageForLevel:game.oppLevel]];
    
    UILabel *oppLevelLabel = (UILabel *)[cell.contentView viewWithTag:TABLE_CELL_TAG_OPP_LEVEL];
    oppLevelLabel.text = [NSString stringWithFormat:@"%d", game.oppLevel];
    oppLevelLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:20];
    oppLevelLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_YELLOW1];
    
    UIImageView *oppSexImageView = (UIImageView *)[cell.contentView viewWithTag:TABLE_CELL_TAG_OPP_SEX];
    if (!game.oppSex) oppSexImageView.image = [UIImage imageNamed:@"female.png"];
    else oppSexImageView.image = [UIImage imageNamed:@"male.png"];
    
    UILabel *roundLabel = (UILabel *)[cell.contentView viewWithTag:TABLE_CELL_TAG_ROUND];
    roundLabel.text = [NSString stringWithFormat:@"Turn %d", game.round];
    roundLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    roundLabel.textColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_CADE_BLUE];
    
    UIButton *playButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_PLAY_BTN];
    [self configurePlayButton:playButton forGameState:gameState];
    playButton.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:14];
    
    UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_DELETE_BTN];
    [deleteButton addTarget:self action:@selector(deleteGamePressed:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:15];
    
    UIButton *banButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BAN_BTN];
    [banButton addTarget:self action:@selector(banPlayerPressed:) forControlEvents:UIControlEventTouchUpInside];
    banButton.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:14];
    
    UIButton *refreshButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_REFRESH_IMAGE_BTN];
    [refreshButton addTarget:self action:@selector(getOppPortraitPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *snoozeButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_SNOOZE_BTN];
    [snoozeButton addTarget:self action:@selector(snoozePressed:) forControlEvents:UIControlEventTouchUpInside];
    if (game.playerGameState != GAMESTATE_WAIT) {
        snoozeButton.enabled = NO;
        game.snoozable = NO;
    } else {
        snoozeButton.enabled = game.snoozable;
    }
    
    UIImageView *bgImageView = (UIImageView *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BG_IMAGE];
    bgImageView.image = [UIImage imageNamed:@"menu_bg.png"];
    
    UIImageView *vipImageView = (UIImageView *)[cell.contentView viewWithTag:TABLE_CELL_TAG_VIP_IMAGE];
    if (game.oppDayOfVIP == 0) {
        vipImageView.alpha = 0;
    } else {
        vipImageView.alpha = 1;
        bgImageView.image = [UIImage imageNamed:@"menu_vip_bg.png"];
    }
    // enable
    // put function together
    
    return cell;
}

- (void)configurePlayButton:(UIButton *)button
               forGameState:(GameState)gameState
{
    [button removeTarget:self action:@selector(acceptGamePressed:) forControlEvents:UIControlEventTouchUpInside];
    [button removeTarget:self action:@selector(guessGamePressed:) forControlEvents:UIControlEventTouchUpInside];
    [button removeTarget:self action:@selector(preRecordGamePressed:) forControlEvents:UIControlEventTouchUpInside];
    [button removeTarget:self action:@selector(recordGamePressed:) forControlEvents:UIControlEventTouchUpInside];
    [button removeTarget:self action:@selector(resultOfGamePressed:) forControlEvents:UIControlEventTouchUpInside];
    button.enabled = YES;
    
    switch (gameState) 
    {
        case GAMESTATE_WAIT:
            [button setImage:[UIImage imageNamed:@"menu_btn_opp_turn.png"] forState:UIControlStateNormal];
            //[button setTitle:@"对方回合" forState:UIControlStateNormal];
            button.enabled = NO;
            break;
            
        case GAMESTATE_ACCEPT:
            [button setImage:[UIImage imageNamed:@"menu_btn_accept.png"] forState:UIControlStateNormal];
            //[button setTitle:@"接受" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(acceptGamePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case GAMESTATE_GUESS:
            [button setImage:[UIImage imageNamed:@"menu_btn_guess.png"] forState:UIControlStateNormal];
            //[button setTitle:@"猜猜看" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(guessGamePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case GAMESTATE_PRE_RECORD:
            [button setImage:[UIImage imageNamed:@"menu_btn_record.png"] forState:UIControlStateNormal];
            //[button setTitle:@"出题吧" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(preRecordGamePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case GAMESTATE_RECORD:
            [button setImage:[UIImage imageNamed:@"menu_btn_record.png"] forState:UIControlStateNormal];
            //[button setTitle:@"出题吧" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(recordGamePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case GAMESTATE_RESULT:
            [button setImage:[UIImage imageNamed:@"menu_btn_result.png"] forState:UIControlStateNormal];
            //[button setTitle:@"结果" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(resultOfGamePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case GAMESTATE_DELETED:
            [button setImage:[UIImage imageNamed:@"menu_btn_deleted.png"] forState:UIControlStateNormal];
            //[button setTitle:@"被删除了" forState:UIControlStateNormal];
            button.enabled = NO;
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0)
        return 60;
    
    return 45;
        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        // Create a game.
        
        //[self setCreateNewGameView:nil];
        self.createNewGameView = [self.createNewGameView initWithSuperView:self.view
                                  andUser:self.user];
        self.createNewGameView.delegate = self;
        [self.hiddenMenuView slideOutSlider];
        
        //[self reloadData];
    }
    else
    {
        UITableViewCell *cell = [self.gameTableView cellForRowAtIndexPath:indexPath];
        
        UIButton *banButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BAN_BTN];
        UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_DELETE_BTN];
        UIButton *snoozeButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_SNOOZE_BTN];
        UIButton *playButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_PLAY_BTN];
        
        [self showBtn:snoozeButton andBtn:playButton hideBtn:banButton andBtn:deleteButton];
    }
}

- (void)showBtn:(UIButton *)btn1
         andBtn:(UIButton *)btn2
        hideBtn:(UIButton *)btn3
         andBtn:(UIButton *)btn4
{
    if (btn1.alpha != 1)
    {
        [UIView animateWithDuration:0.5
                              delay:0.01
                            options:UIViewAnimationCurveLinear
                         animations:^(){
                             btn1.alpha = 1;
                             btn3.alpha = 0;
                         }completion:^(BOOL finished){
                             
                         }];
    }
    
    if (btn2.alpha != 1)
    {
        [UIView animateWithDuration:0.5
                              delay:0.01
                            options:UIViewAnimationCurveLinear
                         animations:^(){
                             btn2.alpha = 1;
                             btn4.alpha = 0;
                         }completion:^(BOOL finished){
                             
                         }];
    }
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.gameTableView];
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.gameTableView indexPathForRowAtPoint:location];
    
    //Check if index path is valid
    if(indexPath)
    {
        if (indexPath.row == 0) return; // first row is create new game.
        
        //Get the cell out of the table view
        UITableViewCell *cell = [self.gameTableView cellForRowAtIndexPath:indexPath];
        
        UIButton *banButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BAN_BTN];
        UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_DELETE_BTN];
        UIButton *snoozeButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_SNOOZE_BTN];
        UIButton *playButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_PLAY_BTN];
        
        [self showBtn:banButton andBtn:deleteButton hideBtn:snoozeButton andBtn:playButton];
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //same code for getting UITableViewCell like before
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.gameTableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.gameTableView indexPathForRowAtPoint:location];
    
    //Check if index path is valid
    if(indexPath)
    {
        if (indexPath.row == 0) return;
        
        //Get the cell out of the table view
        UITableViewCell *cell = [self.gameTableView cellForRowAtIndexPath:indexPath];
        
        UIButton *banButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BAN_BTN];
        UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_DELETE_BTN];
        UIButton *snoozeButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_SNOOZE_BTN];
        UIButton *playButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_PLAY_BTN];
        
        [self showBtn:banButton andBtn:deleteButton hideBtn:snoozeButton andBtn:playButton];
    }

}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self.hiddenMenuView slideInSlider];
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self.hiddenMenuView slideOutSlider];
}

- (void)resetAllButtonsInTableView
{
    for (int section = 0; section < [self.gameTableView numberOfSections]; section++) {
        for (int row = 0; row < [self.gameTableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.gameTableView cellForRowAtIndexPath:cellPath];
            
            UIButton *banButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BAN_BTN];
            UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_DELETE_BTN];
            UIButton *snoozeButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_SNOOZE_BTN];
            UIButton *playButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_PLAY_BTN];
            
            [self showBtn:snoozeButton andBtn:playButton hideBtn:banButton andBtn:deleteButton];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    
    CGPoint location = [gestureRecognizer locationInView:self.gameTableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.gameTableView indexPathForRowAtPoint:location];
    
    if(indexPath)
    {
        UITableViewCell *cell = [self.gameTableView cellForRowAtIndexPath:indexPath];
        CGPoint locationWithinCell = [gestureRecognizer locationInView:cell];
        
        if (indexPath.row == 0)
        {
            NSLog(@"%d", self.user.gamesArray.count);
            if (self.user.inventory.dayOfVIP == 0 && self.user.gamesArray.count > 19) {
                [UIViewCustomAnimation showAlert:@"游戏个数超过上限啦!\n推荐游戏给好友赢取VIP礼包，享受无上限游戏乐趣！"];
                return;
            }
            
            //[self setCreateNewGameView:nil];
            self.createNewGameView = [self.createNewGameView initWithSuperView:self.view
                                                                       andUser:self.user];
            self.createNewGameView.delegate = self;
            [self.hiddenMenuView slideOutSlider];
        }
        else
        {
            UIButton *banButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_BAN_BTN];
            UIButton *deleteButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_DELETE_BTN];
            UIButton *snoozeButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_SNOOZE_BTN];
            UIButton *playButton = (UIButton *)[cell.contentView viewWithTag:TABLE_CELL_TAG_PLAY_BTN];
            
            if (playButton.alpha == 1 && CGRectContainsPoint(playButton.frame, locationWithinCell))
                [playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            if (banButton.alpha == 1 && CGRectContainsPoint(banButton.frame, locationWithinCell))
                [banButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            if (deleteButton.alpha == 1 && CGRectContainsPoint(deleteButton.frame, locationWithinCell))
                [deleteButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            if (snoozeButton.alpha == 1 && CGRectContainsPoint(snoozeButton.frame, locationWithinCell))
                [snoozeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self resetAllButtonsInTableView];
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete your data
        
        // Delete the table cell
        //[self.gameTableView deleteRowAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
 */

- (void)setCurrentTableState:(TableState)currentTableState
{
    _currentTableState = currentTableState;
    switch (_currentTableState) {
        case TABLE_STATE_NORMAL:
            self.tableRefreshHeaderView.alpha = 0;
            self.tableRefreshHeaderLabel.text = @"";
            self.tableRefreshImageView.image = [UIImage imageNamed:@"icon_refresh_down.png"];
            break;
            
        case TABLE_STATE_REFRESH_LOADING:
            self.tableRefreshHeaderView.alpha = 0;
            self.tableRefreshHeaderLabel.text = @"正在更新";
            self.tableRefreshImageView.image = [UIImage imageNamed:@"icon_refreshing.png"];
            break;
            
        case TABLE_STATE_REFRESH_NORMAL:
            self.tableRefreshHeaderView.alpha = 1;
            self.tableRefreshHeaderLabel.text = @"可以松手啦";
            self.tableRefreshImageView.image = [UIImage imageNamed:@"icon_refresh_up.png"];
            break;
            
        case TABLE_STATE_REFRESH_PULLING:
            self.tableRefreshHeaderView.alpha = 1;
            self.tableRefreshHeaderLabel.text = @"再往下拉一点";
            self.tableRefreshImageView.image = [UIImage imageNamed:@"icon_refresh_down.png"];
            break;
        
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging)
    {
        if (self.currentTableState != TABLE_STATE_REFRESH_PULLING &&
            scrollView.contentOffset.y > - 40.0f &&
            scrollView.contentOffset.y < 0.0f)
        {
            self.currentTableState = TABLE_STATE_REFRESH_PULLING;
        }
        else if (self.currentTableState != TABLE_STATE_REFRESH_NORMAL &&
                 scrollView.contentOffset.y < - 40.0f)
        {
            self.currentTableState = TABLE_STATE_REFRESH_NORMAL;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y <= - 40.0f)
    {
        self.currentTableState = TABLE_STATE_REFRESH_LOADING;
        self.needsNotRefreshInfo = YES;
        [self reloadData];
    }
    else
    {
        self.currentTableState = TABLE_STATE_NORMAL;
    }
}

- (void)reloadData
{
    self.user.delegate = self;
    [self.user reloadPlayer];
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)reloadDataForPlayer:(Player *)player
{    
    self.user = player;
    [self.user reloadGames];
    [self.userView reloadWithPlayer:self.user];
    [self.gameTableView reloadData];
    
    for (GuessGame *game in self.user.gamesArray)
    {
        NSLog(@"%@ vs %@ at %d", game.userID, game.oppID, game.playerGameState);
    }
}

- (void)reloadUserInfo
{
    self.user.delegate = self;
    [self.user retrieveInfo];
}

- (void)closeWindow
{
    [self reloadUserInfo];
}

- (GuessGame *)fetchGuessGameAtIndex:(NSIndexPath *)path
{
    GuessGame *gameInArray = [self.user.gamesArray objectAtIndex:path.row - 1];
    
    return [self.user.gamesDict objectForKey:gameInArray.oppID];
}

- (void)acceptGamePressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    self.game.delegate = self;
    [self.game finishAcceptGameForPlayer:self.user];
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)postResultOfGamePressedAction
{
    self.waitingForComment = NO;
    
    [self performSegueWithIdentifier:@"showResultSeg" sender:nil];
}

- (void)resultOfGamePressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    self.game.delegate = self;
    
    [self performSegueWithIdentifier:@"showResultSeg" sender:nil];
    return;
    
    int indexOfLastSlash = (int)([self.game.audioPath rangeOfString:@"/" options:NSBackwardsSearch].location);
    NSString *commentTmpPath = [DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat: @"/%@", [self.game.audioPath substringFromIndex:indexOfLastSlash+1]]];
    int indexOfLastUnderscore = (int)([commentTmpPath rangeOfString:@"_" options:NSBackwardsSearch].location);

    NSString *commentPath = [NSString stringWithFormat:@"%@_com%@", [commentTmpPath substringToIndex:indexOfLastUnderscore], [commentTmpPath substringFromIndex:indexOfLastUnderscore]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:commentPath])
    {
        [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                             target:self
                                                           selector:@selector(spinnerTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
        self.oppIDGamesNeedsDownload = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@comment", self.game.oppID]];
        self.waitingForComment = YES;
        
        [self downloadFiles];
    }
    else [self postResultOfGamePressedAction];
}

- (void)guessGamePressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];

    [self performSegueWithIdentifier:@"guessGameSeg" sender:sender];
}

- (void)recordGamePressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];

    //[self.game startRecordingForPlayer:self.user];
    [self performSegueWithIdentifier:@"recordGameSeg" sender:sender];
}

- (void)preRecordGamePressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    
    [self performSegueWithIdentifier:@"preRecordGameSeg" sender:sender];
}

- (void)deleteGame
{
    if (!self.game) return;
    
    [self resetAllButtonsInTableView];
    NSFileManager *filemgr;
    NSArray *filelist;
    int count;
    int i;
    
    filemgr = [NSFileManager defaultManager];
    filelist = [filemgr contentsOfDirectoryAtPath: DOCUMENTS_FOLDER error: nil];
    count = [filelist count];
    for (i = 0; i < count; i++)
    {
        NSString *fileName = [filelist objectAtIndex:i];
        
        if ([fileName hasPrefix:self.game.oppID] && [fileName hasSuffix:@".caf"])
        {
            NSError *err;
            [filemgr removeItemAtPath:[DOCUMENTS_FOLDER stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]] error:&err];
        }
    }
    
    self.user.delegate = self;
    self.game.delegate = self;
    [self.user exitGame:self.game];
    
    /*
    if (self.game.startOfGame)
    {
        [self.user reloadGames];
        [self.gameTableView reloadData];
        return;
    }
     */
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)deleteGamePressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    [self deleteGame];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"屏蔽该玩家"])
    {
        [self.game banOppPlayer];
        [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                             target:self
                                                           selector:@selector(spinnerTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    else if ([option isEqualToString:@"同步TA的头像"])
    {
        [self.game getOppPortrait];
        [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                             target:self
                                                           selector:@selector(spinnerTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    else if ([option isEqualToString:@"分享游戏"])
    {
        [self postImageStatus];
        
    }
    else if ([option isEqualToString:@"关注我们"])
    {
        [self createFriendshipImageStatus];
    }
    
    actionSheet = nil;
}

- (void)banPlayerPressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    self.game.delegate = self;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                             otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:@"屏蔽该玩家"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"取消"];
    [actionSheet showInView:self.view];
}

- (void)getOppPortraitPressed:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    self.game.delegate = self;
    //NSString *titleStr = [NSString stringWithFormat:@"同步%@的头像？", (self.game.oppSex)?@"他":@"她"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:nil
                             destructiveButtonTitle:nil
                             otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:@"同步TA的头像"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"取消"];
    [actionSheet showInView:self.view];
}

-(void)snoozePressed:(UIButton *)sender
{   
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *path = [self.gameTableView indexPathForCell:cell];
    
    self.game = [self fetchGuessGameAtIndex:path];
    self.game.delegate = self;
    
    if (!self.game.snoozable) return;
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    [self.game.httpConn snoozeForGame:self.game];
}
/*
-(void)adSlideaPressed:(UIButton *)sender
{

}
*/
- (IBAction)adSlideaPressed:(id)sender {
    NSLog(@"in adsldiea press");
    [self.hiddenMenuView shopBtnPressed:sender tag:SHOP_TAG_INVENTORY];
}

- (void)unbanWithOppNickname:(NSString *)oppNickname
{
    self.user.delegate = self;
    [self.user unbanOppPlayer:oppNickname];
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)updateInfoWithOldPwd:(NSString *)oldPwd
                  withNewPwd:(NSString *)pwd
                withNickname:(NSString *)nickname
                withPortrait:(UIImage *)portrait
{
    self.user.delegate = self;
    if (!oldPwd) return;
    
    if (!pwd && !nickname && !portrait) return;
    
    if (pwd) self.updatedPassword = [[pwd dataUsingEncoding:NSUTF8StringEncoding] AES256Encrypt];
    else self.updatedPassword = nil;
    
    if(portrait != NULL)
        self.isUpdatePortrait = TRUE;
    else
        self.isUpdatePortrait = FALSE;
    [self.user updateInfoWithOldPwd:[[oldPwd dataUsingEncoding:NSUTF8StringEncoding] AES256Encrypt]
                         withNewPwd:self.updatedPassword
                       withNickname:nickname
                       withPortrait:NULL];
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (UIView *)resultViewOfGame:(GuessGame *)game
                   withFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    
    UIImage *goldImg = [UIImage imageNamed:@"gold.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:goldImg];
    imageView.frame = CGRectMake(0, 0, 25, 26);
    
    
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 74, 20)];
    resultLabel.text = [NSString stringWithFormat: @"+%d", game.reward];
    resultLabel.font = [UIFont systemFontOfSize:20];
    resultLabel.backgroundColor = [UIColor clearColor];
    
    [view addSubview:imageView];
    [view addSubview:resultLabel];
    
    return view;
}

- (Player *)getUser
{
    return self.user;
}

- (UIActivityIndicatorView *)getSpinner
{
    return self.spinner;
}

- (UIView *)getShade
{
    return self.shade;
}

- (UIView *)getView
{
    return self.view;
}

- (UserView *)getUserView
{
    return self.userView;
}

- (BOOL)downloadFiles
{
    if (!self.oppIDGamesNeedsDownload) return FALSE;
    if (self.oppIDGamesNeedsDownload.count == 0) return FALSE;
    
    NSString *target = [self.oppIDGamesNeedsDownload objectAtIndex:0];
    NSString *oppID;
    NSString *filePath;
    GuessGame *game;
    if ([target hasSuffix:@"comment"])
    {
        oppID = [target substringToIndex:target.length-7];
        game = [self.user.gamesDict objectForKey:oppID];
        game.delegate = self;
        int indexOfLastUnderscore = (int)([game.audioPath rangeOfString:@"_" options:NSBackwardsSearch].location);

        filePath = [NSString stringWithFormat:@"%@_com%@",[game.audioPath substringToIndex:indexOfLastUnderscore], [game.audioPath substringFromIndex:indexOfLastUnderscore]];
    }
    else
    {
        oppID = target;
        game = [self.user.gamesDict objectForKey:oppID];
        game.delegate = self;
        filePath = game.audioPath;
    }
    
    [game downloadFileFrom:filePath];
    
    NSMutableArray *updated = [self.oppIDGamesNeedsDownload mutableCopy];
    [updated removeObjectAtIndex:0];
    self.oppIDGamesNeedsDownload = [updated copy];
    return TRUE;
}

- (void)purchaseItemWithGold:(PurchaseItemType)type
                      amount:(int)amount
                       gold:(int)gold
{
    self.user.inventory.delegate = self;
    switch (type) {
        case PURCHASE_ITEM_TYPE_HAMMER:
            [self.user.inventory purchaseHammerAmount:amount gold:gold];
            break;
        case PURCHASE_ITEM_TYPE_KEY:
            [self.user.inventory purchaseKeyAmount:amount gold:gold];
            break;
        case PURCHASE_ITEM_TYPE_VIP:
            [self.user.inventory purchaseVIPAmount:amount gold:gold];
        default:
            break;
    }
}

- (void)animateItemPurchase:(PurchaseItemType)type
{
    UIImageView *view;
    UIImage *image;
    CGRect endPos;
    switch (type) {
        case PURCHASE_ITEM_TYPE_HAMMER:
            image = [UIImage imageNamed:@"popup_table_icon_hammer.png"];
            view = [[UIImageView alloc] initWithImage:image];
            view.frame = CGRectMake(138, 260, 45, 45);
            endPos = CGRectMake(220, 140, 30, 30);
            break;
        case PURCHASE_ITEM_TYPE_KEY:
            image = [UIImage imageNamed:@"popup_table_icon_key.png"];
            view = [[UIImageView alloc] initWithImage:image];
            view.frame = CGRectMake(138, 260, 45, 45);
            endPos = CGRectMake(220, 140, 30, 30);
            break;
        case PURCHASE_ITEM_TYPE_VIP:
            if (self.user.inventory.dayOfVIP == -1) {
                image = [UIImage imageNamed:@"popup_table_icon_gift_2.png"];
            } else {
                image = [UIImage imageNamed:@"popup_table_icon_gift_1.png"];
            }
                
            view = [[UIImageView alloc] initWithImage:image];
            view.frame = CGRectMake(138, 260, 45, 45);
            endPos = CGRectMake(220, 140, 30, 30);
            break;
            
        default:
            break;
    }
    
    [self.view addSubview:view];
    [UIView animateWithDuration:1
                          delay:0.01
                        options:UIViewAnimationCurveEaseIn
                     animations:^() {
                         view.frame = endPos;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

- (void)animateVIP
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", -1]  forKey:@"bannerStage"];
    [defaults synchronize];
    [UIView beginAnimations:@"stage 0" context:nil];
    [UIView setAnimationDuration:TABLEVIEW_MOVE_DOWN_DURATION];
    self.gameTableView.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableRefreshHeaderView.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableRefreshHeaderLabel.transform = CGAffineTransformMakeTranslation(0, 0);
    self.tableRefreshImageView.transform = CGAffineTransformMakeTranslation(0, 0);
    bannerView_.alpha = 0.0;
    self.adSlidea.alpha = 0.0;
    [UIView commitAnimations];
}

- (BOOL)checkServerResponse:(int)code
{
    if (code == E_BAD_DATA) {
        [UIViewCustomAnimation showAlert:@"服务器故障，请重新操作"];
        return FALSE;
    }
    else if (code == E_WRONG_SESSION) {
        [self showWrongSession];
        return FALSE;
    }
    
    return TRUE;
}

- (void)showWrongSession
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                           message:[NSString stringWithFormat:@"登陆过期了！请重新登陆"]
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"只能这样了", nil];
    [alertView show];
}

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    if (type != REQUEST_TYPE_DOWNLOAD_FILE) {
        [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        [self.spinnerTimer invalidate];
        [self setSpinnerTimer:nil];
    }
    
    if (!success)
    {
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        if (type == REQUEST_TYPE_DOWNLOAD_FILE) {
            [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
            [self.spinnerTimer invalidate];
            [self setSpinnerTimer:nil];
        }
        return;
    }
    
    if (![self checkServerResponse:[[serverResponse objectForKey:@"s"] intValue]]) {
        return;
    }
    
    NSString *state = nil;
    NSData *imageData;
    NSError *error;
    
    switch (type) {
        case REQUEST_TYPE_BAN_PLAYER:
            [UIViewCustomAnimation showAlert:@"屏蔽成功！\n在设置中可解除屏蔽"];
            [self deleteGame];
            break;
            
        case REQUEST_TYPE_UNBAN_PLAYER:
            state = [serverResponse objectForKey:@"s"];
            UnbanStatus unBanStatus = [state intValue];
            switch (unBanStatus) {
                case UNBAN_STATUS_SUCCESS:
                    [UIViewCustomAnimation showAlert:@"解除屏蔽成功！"];
                    [self deleteGame];
                    break;
                case UNBAN_STATUS_NOT_IN_LIST:
                    [UIViewCustomAnimation showAlert:@"该玩家不在你的黑名单内"];
                    break;
            }
            break;
            
        case REQUEST_TYPE_DOWNLOAD_FILE:
            if (![self downloadFiles])
            {
                [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
                
                [self.spinnerTimer invalidate];
                [self setSpinnerTimer:nil];
                self.currentTableState = TABLE_STATE_NORMAL;
                if (self.waitingForComment) [self postResultOfGamePressedAction];
            }
            break;
            
        case REQUEST_TYPE_DELETE_GAME:
            [self.gameTableView reloadData];
            break;
            
        case REQUEST_TYPE_LOGIN:
            break;
            
        case REQUEST_TYPE_RETRIEVE_PLAYER_INFO:
            self.user.level = [[serverResponse objectForKey:@"level"] intValue];
            self.user.exp = [[serverResponse objectForKey:@"exp"] intValue];
            self.user.gold = [[serverResponse objectForKey:@"gold"] intValue];
            self.user.nickname = [serverResponse objectForKey:@"nickname"];
            self.user.totalRef = [[serverResponse objectForKey:@"totalRef"] intValue];
            self.user.uncollectRef = [[serverResponse objectForKey:@"uncollectRef"] intValue];
            self.user.follower = [[serverResponse objectForKey:@"follower"] intValue];
            self.user.inventory.numOfKeys = [[serverResponse objectForKey:@"silverkey"] intValue];
            self.user.inventory.numOfHammers = [[serverResponse objectForKey:@"hammer"] intValue];
            self.user.inventory.albumInfo = [serverResponse objectForKey:@"albumstr"];
            self.user.inventory.dayOfVIP = [[serverResponse objectForKey:@"vip"] intValue];
            [self.userView reloadWithPlayer:self.user];
            
            /* Animate heartbeat for button */
            if (self.user.uncollectRef > 0) {
                [UIViewCustomAnimation heartbeatAnimationForView:self.prizeBtn ratio:1.2 duration:0.5 repeat:20];
            }
            
            break;
            
        case REQUEST_TYPE_UPDATE_PLAYER:
            [self.gameTableView reloadData];            
            self.currentTableState = TABLE_STATE_NORMAL;            
            [self.user reloadGames];
            if (self.needsNotRefreshInfo) self.needsNotRefreshInfo = NO;
            else {
                // Retrieve latest info.
                [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
                self.user.delegate = self;
                [self.user retrieveInfo];
                self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                                     target:self
                                                                   selector:@selector(spinnerTimeout)
                                                                   userInfo:nil
                                                                    repeats:NO];
            }
            
            [self.userView reloadWithPlayer:self.user];
            
            /* Animate heartbeat for button */
            if (self.user.uncollectRef > 0) {
                [UIViewCustomAnimation heartbeatAnimationForView:self.prizeBtn ratio:1.2 duration:0.5 repeat:20];
            }
            
            break;
            
        case REQUEST_TYPE_UPDATE_PLAYER_INFO:
            state = [serverResponse objectForKey:@"s"];
            int reloadUser = 1;
            if ([state isEqualToString:[NSString stringWithFormat:@"%d", UPDATE_INFO_WRONG_PWD]]) {
                [UIViewCustomAnimation showAlert:@"旧密码错误"];
            }
            if ([state isEqualToString:[NSString stringWithFormat:@"%d", UPDATE_INFO_NICKNAME_EXIST]]) {
                [UIViewCustomAnimation showAlert:@"该昵称已存在"];
            }
            if ([state isEqualToString:[NSString stringWithFormat:@"%d", UPDATE_INFO_SUCCESS]]) {
                if(self.isUpdatePortrait == TRUE)
                {
                    [self.user upLoadProtrait:TRUE forUser:self.user.ID];
                    reloadUser = 0;
                    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
                    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                                         target:self
                                                                       selector:@selector(spinnerTimeout)
                                                                       userInfo:nil
                                                                        repeats:NO];
                }
                if (self.updatedPassword) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.updatedPassword forKey:@"userPwd"];
                    [defaults synchronize];
                }
                
                self.user.nickname = [serverResponse objectForKey:@"nickname"];
                self.user.level = [[serverResponse objectForKey:@"level"] intValue];
                self.user.gold = [[serverResponse objectForKey:@"gold"] intValue];
                self.user.exp = [[serverResponse objectForKey:@"exp"] intValue];
                if(reloadUser == 1)
                {
                    [UIViewCustomAnimation showAlert:@"更新成功！"];
                    [self.userView reloadWithPlayer:self.user];
                }
                
            }
            break;
        case REQUEST_TYPE_S3_UPLOAD_PORTAIT:
            //NSString *imagePath = ;
            imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:[DOCUMENTS_FOLDER stringByAppendingFormat:@"/user.png"]]);
            [[NSFileManager defaultManager]  createFileAtPath:[NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER,self.user.ID] contents:imageData attributes:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[DOCUMENTS_FOLDER stringByAppendingFormat:@"/user.png"] error:&error];
            
            [UIViewCustomAnimation showAlert:@"更新成功！"];
            [self.userView reloadWithPlayer:self.user];
            
            break;
        case REQUEST_TYPE_FINISH_ACCEPT:
            if(self.game.playerGameState == GAMESTATE_GUESS)
                [self performSegueWithIdentifier:@"guessGameSeg" sender:nil];
            else {
                [self.user reloadGames];
                [self.gameTableView reloadData];
            }
            break;
            
        case REQUEST_TYPE_FINISH_SHOW_RESULT:
            self.user.gold = [[serverResponse objectForKey:@"gold"] integerValue];
            [self.userView reloadWithPlayer:self.user];
            [self.gameTableView reloadData];

            break;
            
        case REQUEST_TYPE_GET_PORTRAIT:
            [self.gameTableView reloadData];
            [self.userView reloadWithPlayer:self.user];
            break;
        case REQUEST_TYPE_PUSH_SNOOZE:
            
            NSLog(@"%@",[serverResponse objectForKey:@"debug"]);
            [UIViewCustomAnimation showAlert:@"推送已发送"];
            self.game.snoozable = NO;
            [self.gameTableView reloadData];
            // snooze finished
            break;
            
        case REQUEST_TYPE_PURCHASE_ITEM_WITH_GOLD:
            state = [serverResponse objectForKey:@"s"];
            PurchaseItemStatus purchaseStatus = [state intValue];
            switch (purchaseStatus) {
                case PURCHASE_ITEM_STATUS_SUCCESS:
                    self.sePlayer = [UIViewCustomAnimation audioPlayerAtPath:[[NSBundle mainBundle] pathForResource:@"guess_gold" ofType:@"wav"] volumn:1];
                    [self.sePlayer play];
                    
                    self.user.gold = [[serverResponse objectForKey:@"gold"] intValue];
                    self.user.inventory.numOfHammers = [[serverResponse objectForKey:@"hammer"] intValue];
                    self.user.inventory.numOfKeys = [[serverResponse objectForKey:@"silverkey"] intValue];
                    self.user.inventory.dayOfVIP = [[serverResponse objectForKey:@"vip"] intValue];
                    self.user.inventory.albumInfo = [serverResponse objectForKey:@"albumstr"];
                    self.user.level = [[serverResponse objectForKey:@"level"] intValue];
                    self.user.exp = [[serverResponse objectForKey:@"exp"] intValue];

                    [self animateItemPurchase:[[serverResponse objectForKey:@"item"] intValue]];
                    [self.userView reloadWithPlayer:self.user];
                    
                    if(self.user.inventory.dayOfVIP !=0)
                    {
                        [self animateVIP];
                    }
                    
                    break;
                case PURCHASE_ITEM_STATUS_NOT_ENOUGH_GOLD:
                    [UIViewCustomAnimation showAlert:@"金币不够"];
                    break;
                case PURCHASE_ITEM_STATUS_WRONG_ITEM_TYPE:
                    [UIViewCustomAnimation showAlert:@"该物品不存在"];
                    break;
                case PURCHASE_ITEM_STATUS_WRONG_REQ_TYPE:
                    [UIViewCustomAnimation showAlert:@"服务器错误"];
                    break;
            }
            
            break;
            
        case REQUEST_TYPE_COLLECT_BONUS:
            [GuessIAP resetProductIDs];
            [UIViewCustomAnimation showAlert:@"之前的交易失败，现在已补上:)"];
            
            self.user.gold = [[serverResponse objectForKey:@"gold"] intValue];
            self.user.inventory.dayOfVIP = [[serverResponse objectForKey:@"vip"] intValue];
            [self.userView reloadWithPlayer:self.user];
            break;
            
        default:
            break;
    }
    
}
- (IBAction)sinaBtnPressed {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    NSLog(@"%@", [keyWindow subviews]);
    
    //[[UIApplication sharedApplication] delegate].sinaweibo ;
    
    //GuessAppDelegate *delegate = (GuessAppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate.sinaweibo logIn];
    [self removeAuthData];
    [self.sinaweibo logIn];
    
    //[self postImageStatus];
}

- (IBAction)logoBtnPressed:(UIButton *)sender
{
    NSString *urlString = GAME_URL;
    /*
    NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                   (CFStringRef)urlString,
                                                                                   NULL, NULL, kCFStringEncodingUTF8);
    NSLog(@"%@", encodedString);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedString]];
     */
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)prizeBtnPressed:(UIButton *)sender
{
    [self.hiddenMenuView shopBtnPressed:sender tag:SHOP_TAG_INVENTORY];
}

- (IBAction)addMoneyBtnPressed:(UIButton *)sender
{
    [self.hiddenMenuView shopBtnPressed:sender tag:SHOP_TAG_GOLD];
}

/*- (void)sinaBtnPressed
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    NSLog(@"%@", [keyWindow subviews]);
    
    SinaWeibo *sinaweibo = [self sinaweibo];
    [sinaweibo logIn];
}*/

- (void)postImageStatus
{
    
    postImageStatusText = [NSString stringWithFormat:@"我在玩哼给你听,我的昵称是 %@ ,来我和一起玩吧！填写我为推荐人，获得无上限奖励！IPHONE手机下载直接点击这里：%@ @哼给你听互动游戏", self.user.nickname, GAME_URL];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"微博分享"
                                                        message:[NSString stringWithFormat:@"将会在您的新浪微博更新以下内容: %@", postImageStatusText]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"好的", nil];
    

    [alertView show];
}

- (void)createFriendshipImageStatus
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"关注我们"
                                                        message:[NSString stringWithFormat:@"确定关注我们的微博？"]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"关注!", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"好的"])
    {
        /*
        postImageStatusText = self.weiboField.text;
        NSLog(@"%@", postImageStatusText);
        
        [self.sinaweibo requestWithURL:@"statuses/upload.json"
                                params:[NSMutableDictionary dictionaryWithObjectsAndKeys:postImageStatusText, @"status", nil]
                            httpMethod:@"POST"
                              delegate:self];
        */
        [self.sinaweibo requestWithURL:@"statuses/upload.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   postImageStatusText, @"status",
                                   [UIImage imageNamed:@"weibo1.jpg"], @"pic", nil]
                       httpMethod:@"POST"
                         delegate:self];
        
        
    }
    else if([title isEqualToString:@"关注!"])
    {
        [self.sinaweibo requestWithURL:@"friendships/create.json"
                                params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"哼给你听互动游戏"], @"screen_name", nil]
                            httpMethod:@"POST"
                              delegate:self];
        
    }
    else if ([title isEqualToString:@"只能这样了"])
    {
        [self logoutBtnPressed:nil];
    }
}

- (void)storeAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.sinaweibo.accessToken, @"AccessTokenKey",
                              self.sinaweibo.expirationDate, @"ExpirationDateKey",
                              self.sinaweibo.userID, @"UserIDKey",
                              self.sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

-(IBAction)weiboActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"分享游戏"];
    [actionSheet addButtonWithTitle:@"关注我们"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"取消"];
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [actionSheet showInView: self.view];
}
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accessToken = %@ expirationDate = %@ refresh_token = %@", self.sinaweibo.userID, self.sinaweibo.accessToken, self.sinaweibo.expirationDate, self.sinaweibo.refreshToken);
    [self storeAuthData];
    
    //[self postImageStatus];
    [self weiboActionSheet];
    //[UIViewCustomAnimation showAlert:@"login done"];
}



- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@. Please login again", error);
    [self removeAuthData];
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *alertView;
    if([request.url hasSuffix:@"statuses/update.json"])
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                               message:[NSString stringWithFormat:@"更新微博失败，请稍后再试"]
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"好的", nil];
        [alertView show];
        //[alertView release];
        NSLog(@"Post status failed with error: %@", error);
    }
    else if([request.url hasSuffix:@"statuses/upload.json"])
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                               message:[NSString stringWithFormat:@"操作失败，请稍后再试"]
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"好的", nil];
        [alertView show];
        //[alertView release];
        NSLog(@"Post image status failed with error: %@", error);
    }
    else if([request.url hasSuffix:@"friendships/create.json"])
    {
        NSLog(@"%@",[error localizedDescription]);
        if(error.code == 20506)
        {
             alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                                    message:[NSString stringWithFormat:@"您已经关注我们了，谢谢"]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"好的", nil];
        }
        else
        {
             alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                                    message:[NSString stringWithFormat:@"操作失败，请稍后再试"]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"好的", nil];
        }
        [alertView show];
        //[alertView release];
        NSLog(@"Post image status failed with error: %@", error);
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    UIAlertView *alertView;
    if([request.url hasSuffix:@"statuses/update.json"])
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                               message:[NSString stringWithFormat:@"分享成功！"]
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"好的", nil];
        [alertView show];
        //[alertView release];
    }
    else if([request.url hasSuffix:@"statuses/upload.json"])
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"通知"
                                               message:[NSString stringWithFormat:@"分享成功！"]
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"好的", nil];
        [alertView show];
        //[alertView release];
    }
    /*
    else if([request.url hasSuffix:@"friendships/create.json"])
    {
        
    }
     */
     
}

@end
