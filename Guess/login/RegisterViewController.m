//
//  RegisterViewController.m
//  Guess
//
//  Created by Rui Du on 7/2/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "RegisterViewController.h"
#import "MenuViewController.h"
#import "UIViewCustomAnimation.h"
#import "UICustomTextField.h"
#import "UICustomFont.h"
#import "UICustomColor.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UICustomTextField *nicknameTxtField;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (nonatomic) BOOL protraitUpdated;
@property (weak, nonatomic) IBOutlet UIButton *maleSexBtn;
@property (weak, nonatomic) IBOutlet UIView *maleSexView;
@property (weak, nonatomic) IBOutlet UIView *femaleSexView;
@property (weak, nonatomic) IBOutlet UIButton *femaleSexBtn;
@property (weak, nonatomic) IBOutlet UICustomTextField *emailTxtField;
@property (weak, nonatomic) IBOutlet UILabel *emailValueLabel;
@property (weak, nonatomic) IBOutlet UICustomTextField *referTxtField;
@property (weak, nonatomic) IBOutlet UIButton *referHelpBtn;


@property (nonatomic) CGPoint center;
@property (nonatomic) BOOL sex; // YES: Male, NO: Female

@property (weak, nonatomic) Player *user;

@property (weak, nonatomic) NSDictionary *serverResponse;
@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;

@property (weak, nonatomic) UISwipeGestureRecognizer *swipeDown;
@property (weak, nonatomic) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation RegisterViewController

@synthesize nicknameTxtField = _nicknameTxtField;
@synthesize confirmBtn = _confirmBtn;
@synthesize center = _center;
@synthesize user = _user;
@synthesize serverResponse = _serverResponse;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize sex = _sex;
@synthesize maleSexBtn = _maleSexBtn;
@synthesize femaleSexBtn = _femaleSexBtn;
@synthesize maleSexView = _maleSexView;
@synthesize femaleSexView = _femaleSexView;
@synthesize emailTxtField = _emailTxtField;
@synthesize emailValueLabel = _emailValueLabel;
@synthesize referTxtField = _referTxtField;
@synthesize userInfo = _userInfo;
@synthesize imagePickerController = _imagePickerController;
@synthesize swipeDown = _swipeDown;
@synthesize spinnerTimer = _spinnerTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)unpackUserInfo
{
    self.user = [self.userInfo objectForKey:@"user"];
    
    self.imagePickerController = [self.userInfo objectForKey:@"imagePicker"];
    
    self.spinner = [self.userInfo objectForKey:@"spinner"];
    
    self.editableItems = [self.userInfo objectForKey:@"editableItems"];
    
    self.swipeDown = [self.userInfo objectForKey:@"swipeDown"];
}

- (void)loadWithResponse:(NSDictionary *)response
                userInfo:(NSDictionary *)userInfo
{
    self.userInfo = userInfo;
    [self unpackUserInfo];
    self.user = [self.user initWithDictionary:response];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nicknameTxtField.delegate = self;
    self.nicknameTxtField.dx = 3;
    self.nicknameTxtField.placeholder = self.user.nickname;
    
    self.referTxtField.delegate = self;
    self.referTxtField.dx = 3;
    self.emailValueLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:17];
    self.emailValueLabel.text = self.user.email;
    
    self.confirmBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:25];
    self.logoutBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:25];
    
    self.femaleSexView.userInteractionEnabled = NO;
    self.maleSexView.userInteractionEnabled = NO;
    [self femaleSexPressed:nil];
    
    [self.uploadBtn addTarget:self action:@selector(uploadClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.protraitUpdated = FALSE;
    
    self.swipeDown = [self.swipeDown initWithTarget:self
                                             action:@selector(handleSwipeDown:)];
    self.swipeDown.delegate = self;
    [self.swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:self.swipeDown];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.center = self.view.center;

    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.view addSubview:self.shade];
    
    self.spinner = [self.spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    self.spinner.tag = 12;
    [self.view addSubview:self.spinner];
    
    self.editableItems = [[NSMutableArray alloc] init];
    [self.editableItems removeAllObjects];
    [self.editableItems addObject:self.nicknameTxtField];
    [self.editableItems addObject:self.confirmBtn];
    [self.editableItems addObject:self.logoutBtn];
    [self.editableItems addObject:self.uploadBtn];
    [self.editableItems addObject:self.maleSexBtn];
    [self.editableItems addObject:self.femaleSexBtn];
    [self.editableItems addObject:self.referTxtField];
    [self.editableItems addObject:self.referHelpBtn];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    
    [self setShade:nil];
    [self.editableItems removeAllObjects];
}

- (void)viewDidUnload
{
    [self setNicknameTxtField:nil];
    [self setConfirmBtn:nil];
    [self setLogoutBtn:nil];
    [self setUploadBtn:nil];
    [self setPortraitImageView:nil];
    [self setMaleSexBtn:nil];
    [self setFemaleSexBtn:nil];
    [self setEmailTxtField:nil];
    [self setReferTxtField:nil];
    [self setEmailValueLabel:nil];
    [self setMaleSexView:nil];
    [self setFemaleSexView:nil];
    [self setReferHelpBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setUser:nil];
    [self setSpinner:nil];
    [self setShade:nil];
    [self setEditableItems:nil];
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

- (void)spinnerTimeout
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    //[UIViewCustomAnimation showAlert:@"连接超时"];
}

-(IBAction)uploadClicked:(id)sender
{
    [self.emailTxtField resignFirstResponder];
    [self.referTxtField resignFirstResponder];
    [self.nicknameTxtField resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"本地图库"];
    [actionSheet addButtonWithTitle:@"默认头像"];
    //[actionSheet addButtonWithTitle:@"取消"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"取消"];
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    self.imagePickerController = [self.imagePickerController init];
    self.imagePickerController.delegate = self;
    
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"本地图库"])
    {
        NSLog(@"picking from local");
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePickerController.allowsEditing=YES;
        [self presentModalViewController:self.imagePickerController animated:YES];
    }
    else if ([option isEqualToString:@"默认头像"])
    {
        self.portraitImageView.image = [UIImage imageNamed:@"user.png"];
        //[self saveImage:self.portraitImageView.image ];
        //self.protraitUpdated = TRUE;
        NSLog(@"user default");
    }
    else if ([option isEqualToString:@"不管了，注册！"])
    {
        self.referTxtField.text = @"";
        [self confirmPressed:nil];
    }
    
    actionSheet = nil;
    /*
    switch(buttonIndex)
    {
        case 0:// local
        {
            NSLog(@"picking from local");
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsEditing=YES;
            [self presentModalViewController:picker animated:YES];
            break;
        }
    }*/
}


-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    float width = size.width;
    float height = size.height;
    
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    if(height < width)
        rect.origin.y = height / 3;
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSLog(@"Size of my Image => %f, %f ", [image size].width, [image size].height) ;
    
    // scaling set to 2.0 makes the image 1/2 the size.
    UIImage *scaledImage = [self resizeImage:image toSize:CGSizeMake(60,60)];
    //[UIImage imageWithCGImage:[image CGImage]scale:16.0 orientation:UIImageOrientationUp];
    NSLog(@"Size of my Image => %f, %f ", [scaledImage size].width, [scaledImage size].height) ;
    //[self saveImage:scaledImage ];
    self.portraitImageView.image = scaledImage;
    self.protraitUpdated = TRUE;
    
    //[self saveImage:scaledImage ];
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
                         self.view.center = CGPointMake(self.center.x, 120);
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

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self.emailTxtField resignFirstResponder];
    [self.referTxtField resignFirstResponder];
    [self.nicknameTxtField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"menuAfterRegisterSeg"])
    {
        [segue.destinationViewController loadWithRegisteredUser:self.user userInfo:self.userInfo usingPopIndex:1];
        
    }
}

- (IBAction)referHelpPressed:(UIButton *)sender
{
    NSString *message = @"填写推荐人\n-你会额外获得一把音钥匙；\n-你达到6级时，你的推荐人将获得500金币；\n-累计30个达到6级时，你的推荐人将获得VIP礼包！\n在主界面点击右上的【奖】按钮查询领取推荐人礼品！";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @""
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)maleSexPressed:(UIButton *)sender
{
    self.maleSexBtn.selected = YES;
    self.maleSexView.alpha = 0;
    self.femaleSexBtn.selected = NO;
    self.femaleSexView.alpha = 0.6;
    self.sex = YES;
}

- (IBAction)femaleSexPressed:(UIButton *)sender
{
    self.maleSexBtn.selected = NO;
    self.maleSexView.alpha = 0.6;
    self.femaleSexBtn.selected = YES;
    self.femaleSexView.alpha = 0;
    self.sex = NO;
}

- (void)loggedOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"logged"];
    [defaults synchronize];
}

- (IBAction)logoutPressed:(UIButton *)sender
{
    [self loggedOut];
    [self dismissModalViewControllerAnimated:YES];
}
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

- (void)saveImage:(UIImage*)image {
    
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@/temp/user.png", DOCUMENTS_FOLDER]);
    if(![fileManager createFileAtPath:[NSString stringWithFormat:@"%@/user.png", DOCUMENTS_FOLDER] contents:imageData attributes:nil])
        NSLog(@"Not saved");
    else
        NSLog(@"image saved");
}

- (BOOL)nicknameIsChinese:(NSString *)nickname
{
    for (int i=0; i<nickname.length; ++i)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [nickname substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)validateNickname:(NSString *)nickname
{
    BOOL isChinese = [self nicknameIsChinese:nickname];
    
    if (isChinese) {
        if (nickname.length > 7) return FALSE;
    } else {
        if (nickname.length > 10) return FALSE;
    }
    
    int i = 0;
    for (i=0; i<nickname.length; i++)
    {
        if ([nickname characterAtIndex:i]=='\\' ||
            [nickname characterAtIndex:i]=='\'' ||
            [nickname characterAtIndex:i]=='\"')
            return FALSE;
    }

    return TRUE;
}

- (IBAction)confirmPressed:(UIButton *)sender
{
    [self.nicknameTxtField resignFirstResponder];
    [self.referTxtField resignFirstResponder];
    if (!self.nicknameTxtField.text ||
        [self.nicknameTxtField.text isEqualToString:@""])
        self.user.nickname = self.nicknameTxtField.placeholder;
    else
        self.user.nickname = self.nicknameTxtField.text;
    
    if (![self validateNickname:self.user.nickname]) {
        [UIViewCustomAnimation showAlert:@"昵称输入格式错误\n英文昵称不能超过10个字符\n含中文昵称不能超过7个字符\n不能带有 \\ \' \""];
        return;
    }
    
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    //self.user.nickname = [NSString stringWithUTF8String:self.nicknameTxtField.text]
    self.user.isMale = self.sex;
    self.user.delegate = self;
    self.user.refer = self.referTxtField.text;
    
    self.user.portrait = self.portraitImageView.image;
    [self saveImage:self.portraitImageView.image];
    [self.user registerNewPlayerIsUpdatePortrait:self.protraitUpdated];
    
    
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
    
    switch (type) {
        case REQUEST_TYPE_LOGIN:
            state = [serverResponse objectForKey:@"s"];
            RegisterStatus status = [state intValue];
            if(status == REGISTER_STATUS_SUCCESS)
            {
                
                self.user = [self.user initWithDictionary:serverResponse];
                self.user.delegate = self;
                [self.user upLoadProtrait:self.protraitUpdated forUser:self.user.ID];
                [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
                self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                                     target:self
                                                                   selector:@selector(spinnerTimeout)
                                                                   userInfo:nil
                                                                    repeats:NO];
                
                //[self.user.httpConn isCopyProtrait: self.protraitUpdated  forUser:self.user.ID];
                    
                NSLog(@"registered new user");
                // updated
            } else if (status == REGISTER_STATUS_NICKNAME_EXIST) {
                NSLog(@"nickname not available");
                [UIViewCustomAnimation showAlert:@"该昵称已存在"];
            } else if (status == REGISTER_STATUS_USER_EXIST) {
                [UIViewCustomAnimation showAlert:@"该用户已存在"];
            } else if (status == REGISTER_STATUS_WRONG_REFER) {
                //[UIViewCustomAnimation showAlert:@"此推荐人不存在"];
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"此推荐人不存在"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:nil];
                
                [actionSheet addButtonWithTitle:@"不管了，注册！"];
                actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"重新输入"];
                [actionSheet showInView:self.view];
            } else {
                [UIViewCustomAnimation showAlert:@"服务器错误，请稍后再试"];
            }
            
            break;
            
        case REQUEST_TYPE_S3_UPLOAD_PORTAIT:
            [self performSegueWithIdentifier:@"menuAfterRegisterSeg" sender:NULL];
            break;
        default:
            break;
    }
    
}
@end
