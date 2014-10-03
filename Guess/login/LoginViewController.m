//
//  LoginViewController.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuViewController.h"
#import "RegisterViewController.h"
#import "Player.h"
#import "GuessGame.h"
#import "Inventory.h"
#import "MenuNewGamePopupView.h"
#import "UIViewCustomAnimation.h"
#import "UICustomTextField.h"
#import "NSData+Encryption.h"
#import "UserView.h"
#import "OppView.h"
#import "GADBannerView.h"

#import "ASIHTTPRequest.h"
#import "JSON.h"
//#import "HttpConn.h"
//#import "ASIFormDataRequest.h"
//#import "ASINetworkQueue.h"
//#import "ASIHTTPRequest.h"
//#import "JSON.h"

#define LOGO_INTERVAL 10
#define LOGO_BACKGROUND_TAG 101
#define LOGO_BACKGROUND_AMINATION_TAG 102

#define DIR_SERVER_NORMAL 1
#define DIR_SERVER_TO_NEW_URL 2
#define DIR_SERVER_PROBLEM 3
#define WELCOME_DURATION_LONG 4
#define WELCOME_DURATION_SHORT 2

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UICustomTextField *emailTxt;
@property (weak, nonatomic) IBOutlet UICustomTextField *pwdTxt;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) NSDictionary * serverResponse;

@property (strong, nonatomic) UIImageView *welcomeView;
@property (strong, nonatomic) UIImageView *welcomeViewBackground;
@property (strong, nonatomic) NSTimer *welcomeViewTimer;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) Player *user;

@property (nonatomic) CGPoint center;
@property (strong, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;
@property (strong, nonatomic) NSData *passwordEncrypted;

@property (strong, nonatomic) TutorialView *tutorialView;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeDown;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation LoginViewController
@synthesize emailTxt = _emailTxt;
@synthesize pwdTxt = _pwdTxt;
@synthesize loginBtn = _loginBtn;
@synthesize welcomeView = _welcomeView;
@synthesize welcomeViewTimer = _welcomeViewTimer;
@synthesize spinner = _spinner;
@synthesize user = _user;
@synthesize center = _center;
@synthesize editableItems = _editableItems;
@synthesize serverResponse = _serverResponse;
@synthesize shade = _shade;
@synthesize welcomeViewBackground = _welcomeViewBackground;
@synthesize passwordEncrypted = _passwordEncrypted;
@synthesize tutorialView = _tutorialView;
@synthesize swipeDown = _swipeDown;
@synthesize userInfo = _userInfo;
@synthesize spinnerTimer = _spinnerTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadUserInfo
{
    NSMutableDictionary *mutableUserInfo = [[NSMutableDictionary alloc] init];
    
    Player *user = [[Player alloc] init];
    Inventory *inventory = [[Inventory alloc] init];
    user.inventory = inventory;
    [mutableUserInfo setObject:user forKey:@"user"];
    
    GuessGame *game = [[GuessGame alloc] init];
    [mutableUserInfo setObject:game forKey:@"game"];
    
    UserView *userView = [[UserView alloc] init];
    [mutableUserInfo setObject:userView forKey:@"userView"];
    
    OppView *oppView = [[OppView alloc] init];
    [mutableUserInfo setObject:oppView forKey:@"oppView"];
    
    RDMTPopupWindow *popup = [[RDMTPopupWindow alloc] init];
    [mutableUserInfo setObject:popup forKey:@"popup"];
    
    MenuSliderView *hidden = [[MenuSliderView alloc] init];
    [mutableUserInfo setObject:hidden forKey:@"hidden"];
    
    MenuNewGamePopupView *createGameView = [[MenuNewGamePopupView alloc] init];
    [mutableUserInfo setObject:createGameView forKey:@"createGameView"];
    
    TutorialView *tutorial = [[TutorialView alloc] init];
    [mutableUserInfo setObject:tutorial forKey:@"tutorial"];
    
    GADBannerView *bannerView = [[GADBannerView alloc] init];
    [mutableUserInfo setObject:bannerView forKey:@"bannerView"];
    
    NSMutableArray *editableItems = [[NSMutableArray alloc] init];
    [mutableUserInfo setObject:editableItems forKey:@"editableItems"];
    
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    [mutableUserInfo setObject:array1 forKey:@"array1"];
    
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    [mutableUserInfo setObject:array2 forKey:@"array2"];
    
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
    [mutableUserInfo setObject:array3 forKey:@"array3"];
    
    NSString *string1 = [[NSString alloc] init];
    [mutableUserInfo setObject:string1 forKey:@"string1"];
    
    NSString *string2 = [[NSString alloc] init];
    [mutableUserInfo setObject:string2 forKey:@"string2"];
    
    UITextView *textView = [[UITextView alloc] init];
    [mutableUserInfo setObject:textView forKey:@"textView"];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [mutableUserInfo setObject:spinner forKey:@"spinner"];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] init];
    [mutableUserInfo setObject:swipeUp forKey:@"swipeUp"];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] init];
    [mutableUserInfo setObject:swipeDown forKey:@"swipeDown"];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] init];
    [mutableUserInfo setObject:swipeLeft forKey:@"swipeLeft"];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] init];
    [mutableUserInfo setObject:swipeRight forKey:@"swipeRight"];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] init];
    [mutableUserInfo setObject:tap1 forKey:@"tap1"];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
    [mutableUserInfo setObject:tap2 forKey:@"tap2"];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [mutableUserInfo setObject:imagePicker forKey:@"imagePicker"];
    
    UIButton *adSlidea = [[UIButton alloc] init];
    [mutableUserInfo setObject:adSlidea forKey:@"adSlidea"];
    
    
    self.userInfo = [mutableUserInfo copy];
}

- (void)unpackUserInfo
{
    self.user = [self.userInfo objectForKey:@"user"];
    
    self.spinner = [self.userInfo objectForKey:@"spinner"];
    
    self.editableItems = [self.userInfo objectForKey:@"editableItems"];
    
    self.shade = [self.userInfo objectForKey:@"shade"];
    
    self.tutorialView = [self.userInfo objectForKey:@"tutorial"];
    
    self.swipeDown = [self.userInfo objectForKey:@"swipeDown"];
}

-(void)checkAnimation:(NSTimer *)timer
{
    [UIView animateWithDuration:1
                     animations:^() {
                         [self.welcomeViewBackground setAlpha:0];
                         self.welcomeView.alpha = 0;
                         [self setWelcomeView:nil];
                         [self setWelcomeViewBackground:nil];
                     }
                     completion:^(BOOL finished) {
                         [[self.view viewWithTag:LOGO_BACKGROUND_TAG] removeFromSuperview];
                         [[self.view viewWithTag:LOGO_BACKGROUND_AMINATION_TAG] removeFromSuperview];
                     }];
    
    [self.welcomeViewTimer invalidate];
}

- (void)appear:(BOOL)logged
{
    self.welcomeView.frame = self.view.frame;
    if(logged)
        self.welcomeViewTimer = [NSTimer scheduledTimerWithTimeInterval:WELCOME_DURATION_LONG target:self selector:@selector(checkAnimation:) userInfo:nil repeats:YES];
    else
        self.welcomeViewTimer = [NSTimer scheduledTimerWithTimeInterval:WELCOME_DURATION_SHORT target:self selector:@selector(checkAnimation:) userInfo:nil repeats:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self loadUserInfo];
    [self unpackUserInfo];
    
    self.emailTxt.dx = 10;
    self.emailTxt.delegate = self;
    NSString *emailAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
    if (emailAddress) self.emailTxt.text = emailAddress;
    
    self.pwdTxt.dx = 10;
    self.pwdTxt.delegate = self;
    self.welcomeViewBackground = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    self.welcomeViewBackground.image = [UIImage imageNamed:@"logo_bg.png"];
    self.welcomeViewBackground.tag = LOGO_BACKGROUND_TAG;
    [self.view addSubview:self.welcomeViewBackground];
    self.loginBtn.titleLabel.font = [UIFont fontWithName:@"Kaiti-Bold" size:15];
    
    [UIViewCustomAnimation heartbeatAnimationForView:self.loginBtn repeat:0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logged = [defaults boolForKey:@"logged"];
    [self appear:logged];
    
    [self displayTutorial];
    
    NSError *error = nil;
    NSString *biuPath = [[NSBundle mainBundle] pathForResource:@"pew-pew-lei" ofType:@"caf"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:biuPath] error:&error];
    [player prepareToPlay];
}

- (void)connectForURL
{
    NSURL *url = [NSURL URLWithString:@"http://slidea-guess-direct.elasticbeanstalk.com/game_info.php"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response         = [request responseString];        
        SBJsonParser *parser       = [[SBJsonParser alloc] init];
        NSDictionary *responseDict = [parser objectWithString:response];
        NSString *state            = [responseDict objectForKey:@"s"];
        
        
        if([state isEqualToString:[NSString stringWithFormat:@"%d", DIR_SERVER_TO_NEW_URL]]) {
            NSString *serverAddress = [responseDict objectForKey:@"server"];
            NSString *bucketName    = [responseDict objectForKey:@"bucket"];
            NSString *accessID      = [responseDict objectForKey:@"id"];
            NSString *accessKey     = [responseDict objectForKey:@"key"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:serverAddress forKey:@"serverAddress"];
            [defaults setObject:bucketName forKey:@"bucketName"];
            [defaults setObject:accessID forKey:@"accessID"];
            [defaults setObject:accessKey forKey:@"accessKey"];
        } else if([state isEqualToString:[NSString stringWithFormat:@"%d", DIR_SERVER_PROBLEM]]) {
            [UIViewCustomAnimation showAlert:@"服务器维护中，请稍后再试"];
        } else {
            // normal
        }
        
        NSLog(@"%@",state);
        
    } else {
       NSLog(@"error"); 
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self connectForURL];
    
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.view addSubview:self.shade];
    
    self.spinner = [self.spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    self.spinner.tag = 12;
    [self.view addSubview:self.spinner];
    
    self.editableItems = [self.editableItems init];
    [self.editableItems removeAllObjects];
    [self.editableItems addObject:self.emailTxt];
    [self.editableItems addObject:self.pwdTxt];
    [self.editableItems addObject:self.loginBtn];
    
    self.swipeDown = [self.swipeDown initWithTarget:self
                                             action:@selector(handleSwipeDown:)];
    self.swipeDown.delegate = self;
    [self.swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:self.swipeDown];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL logged = [defaults boolForKey:@"logged"];
    //[self appear:logged];
    
    self.center = self.view.center;
    
    if (logged) [self autoLogin];
}

- (void)autoLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *email = [defaults objectForKey:@"userEmail"];
    NSData *pwd = [defaults objectForKey:@"userPwd"];
    if (!email || !pwd)
    {
        [UIViewCustomAnimation showAlert:@"无法自动登陆，请重新输入"];
        return;
    }
    
    self.emailTxt.text = email;
    self.passwordEncrypted = pwd;
    [self sentForLoginAnimated:NO];
    //[self loginPressed:nil];
}

- (void)displayTutorial
{   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"isFirstLaunch"]) return;
    
    self.tutorialView = [[TutorialView alloc] initWithFrame:self.view.frame];
    self.tutorialView.delegate = self;
    [self.tutorialView initialize];
    [defaults setObject:[NSDate date] forKey:@"isFirstLaunch"];
    [defaults synchronize];
    
    [self.view addSubview:self.tutorialView];
}

- (void)closeTutorial
{
    [self.tutorialView removeFromSuperview];
    [self setTutorialView:nil];
}

- (void)loggedIn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"logged"];
    [defaults setObject:self.emailTxt.text forKey:@"userEmail"];
    [defaults setObject:self.passwordEncrypted forKey:@"userPwd"];
    [defaults synchronize];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self setShade:nil];
    
    [self.editableItems removeAllObjects];
    [self.welcomeViewTimer invalidate];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    
    [UIView animateWithDuration:1
                     animations:^() {
                         [self.welcomeViewBackground setAlpha:0];
                         self.welcomeView.alpha = 0;
                         [self setWelcomeView:nil];
                         [self setWelcomeViewBackground:nil];
                     }
                     completion:^(BOOL finished) {
                         [[self.view viewWithTag:LOGO_BACKGROUND_TAG] removeFromSuperview];
                         [[self.view viewWithTag:LOGO_BACKGROUND_AMINATION_TAG] removeFromSuperview];
                     }];
    
    [self setWelcomeViewTimer:nil];
    self.pwdTxt.text = @"";
}

- (void)viewDidUnload
{
    [self setEmailTxt:nil];
    [self setPwdTxt:nil];
    [self setLoginBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setWelcomeView:nil];
    [self setWelcomeViewBackground:nil];
    [self setSpinner:nil];
    [self setUser:nil];
    [self setEditableItems:nil];
    [self setShade:nil];
    [self setPasswordEncrypted:nil];
    [self setTutorialView:nil];
    [self setWelcomeViewTimer:nil];
    [self setSpinnerTimer:nil];
}

- (BOOL)shouldAutorotate {

    /*
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation==UIInterfaceOrientationPortrait) {
        // do some sth
        
    }
    */
    
    return NO;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 
                          delay:0.1 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.view.center = CGPointMake(self.center.x, 80);
                     } 
                     completion:^(BOOL finished){}];
    
    [self.view setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 
                          delay:0.1 
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         self.view.center = self.center;
                     } 
                     completion:^(BOOL finished){}];
    
    [self.view setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (void)spinnerTimeout
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    //[UIViewCustomAnimation showAlert:@"连接超时"];
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self.emailTxt resignFirstResponder];
    [self.pwdTxt resignFirstResponder];
}

- (BOOL)checkEmail:(NSString *)candidate
{
    if ([candidate isEqualToString:@""])
    {
        [UIViewCustomAnimation showAlert:@"请输入邮箱"];
        return NO;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailText evaluateWithObject:candidate] != 1)
    {
        [UIViewCustomAnimation showAlert:@"邮箱地址格式不正确"];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkPassword:(NSString *)candidate
{
    if ([candidate isEqualToString:@""])
    {
        [UIViewCustomAnimation showAlert:@"请输入游戏密码"];

        return NO;
    }
    
    if (candidate.length > 15 || candidate.length < 4) {
        [UIViewCustomAnimation showAlert:@"密码长度必需在4-15个字符内"];
        return NO;
    }
    
    return YES;
}

- (IBAction)loginPressed:(UIButton *)sender
{
    // Check email format
    if (![self checkEmail:self.emailTxt.text])
        return;
    
    // Check password correctness
    if (![self checkPassword:self.pwdTxt.text])
        return;
    
    NSData *plain = [self.pwdTxt.text dataUsingEncoding:NSUTF8StringEncoding];
    self.passwordEncrypted = [plain AES256Encrypt];
    [self sentForLoginAnimated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue 
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"menuSeg"])
    {
        //[segue.destinationViewController loadWithResponse:self.serverResponse];
        [segue.destinationViewController loadWithRegisteredUser:self.user userInfo:self.userInfo usingPopIndex:0];
    }
    else if ([segue.identifier isEqualToString:@"registerSeg"])
    {
        [segue.destinationViewController loadWithResponse:self.serverResponse userInfo:self.userInfo];
    }
}

- (void)sentForLoginAnimated:(BOOL)animated
{
    self.user = [self.user initWithEmail:self.emailTxt.text andNickname:nil andPassword:self.passwordEncrypted andSex:NO];
    self.user.delegate = self;
    if (animated) {
        [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
        self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                             target:self
                                                           selector:@selector(spinnerTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
    }
    
    //self.user.deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
    
    /*
	NSString *secret = @"abcde1234567890edfds";
    
	NSData *plain = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@\n", [plain description]);
	NSData *cipher = [plain AES256Encrypt];
    
    NSLog(@"%@\n", [cipher description]);
    //NSString *cipherDesc = [cipher description];
    //cipher = [cipherDesc dataUsingEncoding:NSUTF8StringEncoding];
    NSString *cipherStr = [[NSString alloc] initWithData:cipher encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", cipherStr);
    
	plain = [cipher AES256Decrypt];
	NSLog(@"%@\n", [plain description]);
	NSLog(@"%@\n", [[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding]);
    */
    
    [self.user requestLogin];
}

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    if (!success)
    {
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        return;
    }
    
    NSString *state;
    self.serverResponse = serverResponse;
    switch (type) {
            
        case REQUEST_TYPE_LOGIN:
            state = [serverResponse objectForKey:@"s"];
            if([state isEqualToString:[NSString stringWithFormat: @"%d",LOGIN_STATUS_WRONG_PASSWORD]])
            {
                [UIViewCustomAnimation showAlert:@"密码不正确"];
                return;
            }
            else if([state isEqualToString:[NSString stringWithFormat: @"%d",LOGIN_STATUS_SUCCESS]] )
            {
                self.user = [self.user initWithDictionary:serverResponse];
                self.user.delegate = self;
                [self.user reloadGamesWithResponse:serverResponse type:type];
                [self loggedIn];
                [self performSegueWithIdentifier:@"menuSeg" sender:self];
            }
            else if ([state isEqualToString:[NSString stringWithFormat: @"%d",LOGIN_STATUS_NEW_ACCOUNT]]) {
                [self loggedIn];
                [self performSegueWithIdentifier:@"registerSeg" sender:NULL];
            }
            else
            {
                [UIViewCustomAnimation showAlert:@"服务器错误，请稍后再试"];
                return;
            }
            
            break;
            
            
        default:
            break;
    }
}

@end
