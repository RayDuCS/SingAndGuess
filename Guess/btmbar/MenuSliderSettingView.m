//
//  MenuSliderSettingsView.m
//  Guess
//
//  Created by Rui Du on 6/28/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "MenuSliderSettingView.h"
#import "UICustomTextField.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"
#import "Player.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface MenuSliderSettingView()

@property (strong, nonatomic) UIButton *userSettingBtn;
@property (strong, nonatomic) UIButton *gameSettingBtn;
@property (strong, nonatomic) UIButton *banSettingBtn;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) UIButton *uploadImgBtn;
@property (strong, nonatomic) UIButton *unbanBtn;
@property (strong, nonatomic) UICustomTextField *pwdChangeTxtField;
@property (strong, nonatomic) UICustomTextField *pwdChangeConfirmTxtField;
@property (strong, nonatomic) UICustomTextField *nicknameChangeTxtField;
@property (strong, nonatomic) UICustomTextField *oldPwdTxtField;
@property (strong, nonatomic) UICustomTextField *unbanTxtField;
@property (strong, nonatomic) UIImageView *portraitImageView;
@property (strong, nonatomic) UIImageView *portraitLabelImgView;
@property (strong, nonatomic) UIImageView *pwdLabelImgView;
@property (strong, nonatomic) UIImageView *pwdConfirmLabelImgView;
@property (strong, nonatomic) UIImageView *nicknameLabelImgView;
@property (strong, nonatomic) UIImageView *oldPwdLabelImgView;
@property (strong, nonatomic) UIImageView *audioLabelImgView;
@property (strong, nonatomic) UISwitch *audioSwitch;
@property (strong, nonatomic) UIView *displayView;
@property (strong, nonatomic) UIViewController * root;
@property (nonatomic) BOOL protraitUpdated;
@property (nonatomic) CGPoint originalCenter;

@end

@implementation MenuSliderSettingView

@synthesize userSettingBtn = _userSettingBtn;
@synthesize gameSettingBtn = _gameSettingBtn;
@synthesize banSettingBtn = _banSettingBtn;
@synthesize confirmBtn = _confirmBtn;
@synthesize uploadImgBtn = _uploadImgBtn;
@synthesize unbanBtn = _unbanBtn;
@synthesize pwdChangeTxtField = _pwdChangeTxtField;
@synthesize pwdChangeConfirmTxtField = _pwdChangeConfirmTxtField;
@synthesize nicknameChangeTxtField = _nicknameChangeTxtField;
@synthesize oldPwdTxtField = _oldPwdTxtField;
@synthesize portraitImageView = _portraitImageView;
@synthesize displayView = _displayView;
@synthesize view = _view;
@synthesize originalCenter = _originalCenter;
@synthesize delegate = _delegate;
@synthesize portraitLabelImgView = _portraitLabelImgView;
@synthesize pwdLabelImgView = _pwdLabelImgView;
@synthesize pwdConfirmLabelImgView = _pwdConfirmLabelImgView;
@synthesize nicknameLabelImgView = _nicknameLabelImgView;
@synthesize oldPwdLabelImgView = _oldPwdLabelImgView;
@synthesize audioLabelImgView = _audioLabelImgView;
@synthesize audioSwitch = _audioSwitch;
@synthesize root = _root;
@synthesize protraitUpdated = _protraitUpdated;
@synthesize user = _user;

- (Player *)user
{
    _user = [self.delegate getUser];
    return _user;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.originalCenter = self.view.superview.center;
    self.view.superview.center = CGPointMake(self.originalCenter.x, 110);
    [self.view.superview setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.superview.center = self.originalCenter;
    [self.view.superview setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

- (MenuSliderSettingView *)initWithSender:(UIButton *)sender
                       withRootController:(UIViewController *)root
                             withDelegate:(id)delegate
{
    self = [super init];
    
    [self setView:nil];
    self.view = [[UIView alloc] initWithFrame:CGRectMake(20, 80, 280, 348)];
    
    self.root = root;
    self.delegate = delegate;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"userID"];
    
    UIImageView *titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_shezhi.png"]];
    titleImgView.frame = CGRectMake(89.7, 5, 93.57, 35);
    
    self.userSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.userSettingBtn setTitle:@"个人设置" forState:UIControlStateNormal];
    [self.userSettingBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
    self.userSettingBtn.frame = CGRectMake(2, 50, 85, 37);
    [self.userSettingBtn addTarget:self action:@selector(userSettingPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.userSettingBtn setImage:[UIImage imageNamed:@"popup_settings_btn2_1"] forState:UIControlStateNormal];
    [self.userSettingBtn setImage:[UIImage imageNamed:@"popup_settings_btn2_2"] forState:UIControlStateSelected];
    self.userSettingBtn.backgroundColor = [UIColor clearColor];
    
    self.gameSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.gameSettingBtn setTitle:@"游戏设置" forState:UIControlStateNormal];
    [self.gameSettingBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
    self.gameSettingBtn.frame = CGRectMake(88, 50, 85, 37);
    [self.gameSettingBtn addTarget:self action:@selector(gameSettingPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.gameSettingBtn setImage:[UIImage imageNamed:@"popup_settings_btn3_1"] forState:UIControlStateNormal];
    [self.gameSettingBtn setImage:[UIImage imageNamed:@"popup_settings_btn3_2"] forState:UIControlStateSelected];
    self.gameSettingBtn.backgroundColor = [UIColor clearColor];
    
    self.banSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.banSettingBtn setTitle:@"黑名单" forState:UIControlStateNormal];
    [self.banSettingBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
    self.banSettingBtn.frame = CGRectMake(174, 50, 85, 37);
    [self.banSettingBtn addTarget:self action:@selector(banSettingPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.banSettingBtn setImage:[UIImage imageNamed:@"popup_settings_btn5_1"] forState:UIControlStateNormal];
    [self.banSettingBtn setImage:[UIImage imageNamed:@"popup_settings_btn5_2"] forState:UIControlStateSelected];
    self.banSettingBtn.backgroundColor = [UIColor clearColor];
    
    [self setDisplayView:nil];
    self.displayView = [[UIView alloc] initWithFrame:CGRectMake(17, 95, 228, 239)];
    self.displayView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:titleImgView];
    [self.view addSubview:self.userSettingBtn];
    [self.view addSubview:self.gameSettingBtn];
    [self.view addSubview:self.banSettingBtn];
    [self.view addSubview:self.displayView];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeDown:)];
    recognizer.delegate = self;
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];
    
    [self configureUserSettingView];
    [self configureGameSettingView];
    [self configureBanSettingView];
    
    [self userSettingPressed:sender];
    
    NSLog(@"Loading settings for %@", userID);
    
    return self;
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self.pwdChangeTxtField resignFirstResponder];
    [self.pwdChangeConfirmTxtField resignFirstResponder];
    [self.nicknameChangeTxtField resignFirstResponder];
    [self.oldPwdTxtField resignFirstResponder];
    [self.unbanTxtField resignFirstResponder];
}

- (void)configureUserSettingView
{
    [self setPwdLabelImgView:nil];
    [self setPwdConfirmLabelImgView:nil];
    [self setPortraitLabelImgView:nil];
    [self setNicknameLabelImgView:nil];
    [self setOldPwdLabelImgView:nil];
    [self setPwdChangeConfirmTxtField:nil];
    [self setPwdChangeTxtField:nil];
    [self setConfirmBtn:nil];
    [self setNicknameChangeTxtField:nil];
    [self setOldPwdTxtField:nil];
    [self setPortraitImageView:nil];
    [self setUploadImgBtn:nil];
    
    self.pwdLabelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_xinmima.png"]];
    self.pwdLabelImgView.frame = CGRectMake(20, 84, 51, 21);
    
    self.pwdConfirmLabelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_querenmima.png"]];
    self.pwdConfirmLabelImgView.frame = CGRectMake(3, 118, 68, 21);
    
    self.portraitLabelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_xintouxiang.png"]];
    self.portraitLabelImgView.frame = CGRectMake(20, 9, 51, 21);
    
    self.nicknameLabelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_xinnicheng.png"]];
    self.nicknameLabelImgView.frame = CGRectMake(20, 50, 51, 21);
    
    self.oldPwdLabelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_jiumima.png"]];
    self.oldPwdLabelImgView.frame = CGRectMake(20, 152, 51, 21);
    
    self.pwdChangeConfirmTxtField = [[UICustomTextField alloc] initWithFrame:CGRectMake(81, 113, 135, 31)];
    self.pwdChangeConfirmTxtField.background = [UIImage imageNamed:@"login_textfield.png"];
    self.pwdChangeConfirmTxtField.backgroundColor = [UIColor clearColor];
    self.pwdChangeConfirmTxtField.dy = 5;
    self.pwdChangeConfirmTxtField.delegate = self;
    self.pwdChangeConfirmTxtField.secureTextEntry = YES;
    self.pwdChangeConfirmTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.pwdChangeConfirmTxtField.borderStyle = UITextBorderStyleNone;
    self.pwdChangeConfirmTxtField.returnKeyType = UIReturnKeyDone;
    
    self.pwdChangeTxtField = [[UICustomTextField alloc] initWithFrame:CGRectMake(81, 79, 135, 31)];
    self.pwdChangeTxtField.background = [UIImage imageNamed:@"login_textfield.png"];
    self.pwdChangeTxtField.backgroundColor = [UIColor clearColor];
    self.pwdChangeTxtField.dy = 5;
    self.pwdChangeTxtField.delegate = self;
    self.pwdChangeTxtField.secureTextEntry = YES;
    self.pwdChangeTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.pwdChangeTxtField.borderStyle = UITextBorderStyleNone;
    self.pwdChangeTxtField.returnKeyType = UIReturnKeyDone;
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmBtn.frame = CGRectMake(64, 186, 108, 37);
    [self.confirmBtn setTitle:@"确认修改" forState:UIControlStateNormal];
    self.confirmBtn.backgroundColor = [UIColor clearColor];
    [self.confirmBtn setImage:[UIImage imageNamed:@"popup_settings_btn1_1.png"] forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(confirmChangePwdPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nicknameChangeTxtField = [[UICustomTextField alloc] initWithFrame:CGRectMake(81, 45, 135, 31)];
    self.nicknameChangeTxtField.background = [UIImage imageNamed:@"login_textfield.png"];
    self.nicknameChangeTxtField.backgroundColor = [UIColor clearColor];
    self.nicknameChangeTxtField.dy = 5;
    self.nicknameChangeTxtField.delegate = self;
    self.nicknameChangeTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nicknameChangeTxtField.borderStyle = UITextBorderStyleNone;
    self.nicknameChangeTxtField.returnKeyType = UIReturnKeyDone;
    
    self.oldPwdTxtField = [[UICustomTextField alloc] initWithFrame:CGRectMake(81, 147, 135, 31)];
    self.oldPwdTxtField.background = [UIImage imageNamed:@"login_textfield.png"];
    self.oldPwdTxtField.backgroundColor = [UIColor clearColor];
    self.oldPwdTxtField.dy = 5;
    self.oldPwdTxtField.delegate = self;
    self.oldPwdTxtField.secureTextEntry = YES;
    self.oldPwdTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.oldPwdTxtField.borderStyle = UITextBorderStyleNone;
    self.oldPwdTxtField.returnKeyType = UIReturnKeyDone;
    
    NSString *portraitPath = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@/user.png", self.user.ID];
    self.portraitImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:portraitPath]];
    self.portraitImageView.frame = CGRectMake(81, 1, 40, 40);
    
    self.uploadImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.uploadImgBtn.frame = CGRectMake(130, 7, 86, 30);
    [self.uploadImgBtn setImage:[UIImage imageNamed:@"popup_settings_btn4_1.png"] forState:UIControlStateNormal];
    [self.uploadImgBtn setTitle:@"上传头像" forState:UIControlStateNormal];
    self.uploadImgBtn.backgroundColor = [UIColor clearColor];
    [self.uploadImgBtn addTarget:self action:@selector(uploadClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)uploadClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"本地图库"];
    [actionSheet addButtonWithTitle:@"默认头像"];
    //[actionSheet addButtonWithTitle:@"取消"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle: @"取消"];
    actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
    [actionSheet showInView: self.displayView];
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"本地图库"])
    {
        NSLog(@"picking from local");
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing=YES;
        [self.root presentModalViewController:picker animated:YES];
    }
    else if ([option isEqualToString:@"默认头像"])
    {
        self.portraitImageView.image = [UIImage imageNamed:@"user.png"];
        self.protraitUpdated = TRUE;
        NSLog(@"user default");
    }
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
    [self.root dismissModalViewControllerAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSLog(@"Size of my Image => %f, %f ", [image size].width, [image size].height) ;
    
    // scaling set to 2.0 makes the image 1/2 the size.
    UIImage *scaledImage = [self resizeImage:image toSize:CGSizeMake(60,60)];
    //[UIImage imageWithCGImage:[image CGImage]scale:16.0 orientation:UIImageOrientationUp];
    NSLog(@"Size of my Image => %f, %f ", [scaledImage size].width, [scaledImage size].height) ;
    //[self saveImage:scaledImage ];
    self.portraitImageView.image = scaledImage;
    self.protraitUpdated = TRUE;

}


- (void)userSettingPressed:(UIButton *)sender
{
    self.gameSettingBtn.selected = NO;
    self.userSettingBtn.selected = YES;
    self.banSettingBtn.selected = NO;
    
    for (UIView *sview in self.displayView.subviews) {
        [sview removeFromSuperview];
    }
    
    // Should use latest portrait image
    NSString *imagePath = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@/user.png", self.user.ID];
    [self.portraitImageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    
    [self.displayView addSubview:self.pwdLabelImgView];
    [self.displayView addSubview:self.pwdChangeConfirmTxtField];
    [self.displayView addSubview:self.pwdConfirmLabelImgView];
    [self.displayView addSubview:self.pwdChangeTxtField];
    [self.displayView addSubview:self.confirmBtn];
    
    [self.displayView addSubview:self.nicknameLabelImgView];
    [self.displayView addSubview:self.nicknameChangeTxtField];
    [self.displayView addSubview:self.portraitImageView];
    [self.displayView addSubview:self.uploadImgBtn];
    [self.displayView addSubview:self.portraitLabelImgView];
    [self.displayView addSubview:self.oldPwdLabelImgView];
    [self.displayView addSubview:self.oldPwdTxtField];
    
    [self.displayView setNeedsDisplay];
}

- (BOOL)isEmptyInput:(UITextField *)textfield
{
    if (!textfield.text) return YES;
    
    if ([textfield.text isEqualToString:@""]) return YES;
    
    return NO;
}

- (BOOL)comparePasswords
{
    if ([self isEmptyInput:self.pwdChangeConfirmTxtField] &&
        [self isEmptyInput:self.pwdChangeTxtField])
        return TRUE;
    
    if ([self.pwdChangeTxtField.text isEqualToString:self.pwdChangeConfirmTxtField.text])
        return TRUE;
    
    return FALSE;
}

- (void)saveImage:(UIImage*)image {
    //[self.portraitImageView setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/user.png", DOCUMENTS_FOLDER, player.ID]]];
    
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@/user.png", DOCUMENTS_FOLDER]);
    [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/user.png", DOCUMENTS_FOLDER] contents:imageData attributes:nil]; //finally save the path (image)
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

- (BOOL)checkSettingsInputLength
{
    if (![self isEmptyInput:self.oldPwdTxtField]) {
        if (self.oldPwdTxtField.text.length > 15 ||
            self.oldPwdTxtField.text.length < 4) {
            [UIViewCustomAnimation showAlert:@"密码长度必需在4-15个字符内"];
            return NO;
        }
    }
    
    if (![self isEmptyInput:self.pwdChangeConfirmTxtField]) {
        if (self.pwdChangeConfirmTxtField.text.length > 15 ||
            self.pwdChangeConfirmTxtField.text.length < 4) {
            [UIViewCustomAnimation showAlert:@"密码长度必需在4-15个字符内"];
            return NO;
        }
    }
    
    if (![self isEmptyInput:self.pwdChangeTxtField]) {
        if (self.pwdChangeTxtField.text.length > 15 ||
            self.pwdChangeTxtField.text.length < 4) {
            [UIViewCustomAnimation showAlert:@"密码长度必需在4-15个字符内"];
            return NO;
        }
    }
    
    if (![self isEmptyInput:self.nicknameChangeTxtField]) {
        
        BOOL isChinese = [self nicknameIsChinese:self.nicknameChangeTxtField.text];
        BOOL pass = YES;
        
        if (isChinese) {
            if (self.nicknameChangeTxtField.text.length > 7) pass = NO;
        } else {
            if (self.nicknameChangeTxtField.text.length > 10) pass = NO;
        }
        
        int i = 0;
        for (i=0; i<self.nicknameChangeTxtField.text.length; i++)
        {
            if ([self.nicknameChangeTxtField.text characterAtIndex:i]=='\\' ||
                [self.nicknameChangeTxtField.text characterAtIndex:i]=='\'' ||
                [self.nicknameChangeTxtField.text characterAtIndex:i]=='\"')
                pass = NO;
        }
        
        if (!pass) {
            [UIViewCustomAnimation showAlert:@"昵称输入格式错误\n英文昵称不能超过10个字符\n含中文昵称不能超过7个字符\n不能带有 \\ \' \""];
            return NO;
        }
    }
    
    return YES;
}

- (void)confirmChangePwdPressed:(UIButton *)sender
{
    if ([self isEmptyInput:self.oldPwdTxtField] &&
        [self isEmptyInput:self.nicknameChangeTxtField] &&
        [self isEmptyInput:self.pwdChangeConfirmTxtField] &&
        [self isEmptyInput:self.pwdChangeTxtField] &&
        !self.protraitUpdated)
    {
        // no changes taken.
        return;
    }
    
    if ([self isEmptyInput:self.oldPwdTxtField])
    {
        [UIViewCustomAnimation showAlert:@"请输入旧密码"];
        return;
    }
    
    if (![self checkSettingsInputLength]) return;
    
    if (![self comparePasswords])
    {
        [UIViewCustomAnimation showAlert:@"新密码和确认密码不一致"];
        return;
    }
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //int userID = [defaults integerForKey:@"userID"];
    NSString *oldPwd = nil;
    NSString *pwd = nil;
    NSString *nickname = nil;
    
    if (![self isEmptyInput:self.oldPwdTxtField])
        oldPwd = self.oldPwdTxtField.text;
    if (![self isEmptyInput:self.pwdChangeTxtField])
        pwd = self.pwdChangeTxtField.text;
    if (![self isEmptyInput:self.nicknameChangeTxtField])
        nickname = self.nicknameChangeTxtField.text;
    
    if ([[nickname lowercaseString] isEqualToString:[self.user.nickname lowercaseString]])
    {
        nickname = nil;
    }
    
    if ([self.oldPwdTxtField.text isEqualToString:self.pwdChangeTxtField.text])
    {
        pwd = nil;
    }
    
    NSLog(@"%@", nickname);
    if(self.protraitUpdated)
    {
        [self saveImage:self.portraitImageView.image];
        [self.delegate updateInfoWithOldPwd:oldPwd withNewPwd:pwd withNickname:nickname withPortrait:self.portraitImageView.image];
    }
    else
        [self.delegate updateInfoWithOldPwd:oldPwd withNewPwd:pwd withNickname:nickname withPortrait:nil];
    
    self.oldPwdTxtField.text = @"";
    [self.oldPwdTxtField resignFirstResponder];
    [self.nicknameChangeTxtField resignFirstResponder];
    [self.pwdChangeTxtField resignFirstResponder];
    [self.pwdChangeConfirmTxtField resignFirstResponder];
}

- (void)configureGameSettingView
{
    [self setAudioLabelImgView:nil];
    [self setAudioSwitch:nil];
    
    self.audioLabelImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_yinxiao.png"]];
    self.audioLabelImgView.frame = CGRectMake(30, 65, 46, 21);
    
    self.audioSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(101, 62, 79, 27)];
    [self.audioSwitch setOn:YES];
    self.audioSwitch.backgroundColor = [UIColor clearColor];
    [self.audioSwitch addTarget:self action:@selector(audioSwitchFliped:) forControlEvents:UIControlEventValueChanged];
}

- (void)gameSettingPressed:(UIButton *)sender
{
    self.gameSettingBtn.selected = YES;
    self.userSettingBtn.selected = NO;
    self.banSettingBtn.selected = NO;
    
    for (UIView *sview in self.displayView.subviews) {
        [sview removeFromSuperview];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSString *audioOn = [defaults objectForKey:@"audioSwitch"];
    if (!audioOn) audioOn = @"YES";
    
    BOOL isAudioOn = YES;
    if ([audioOn isEqualToString:@"NO"]) isAudioOn = NO;
    
    [self.audioSwitch setOn:isAudioOn];
    
    [self.displayView addSubview:self.audioLabelImgView];
    [self.displayView addSubview:self.audioSwitch];
    [self.displayView setNeedsDisplay];
}

- (void)configureBanSettingView
{
    [self setUnbanBtn:nil];
    [self setUnbanTxtField:nil];
    
    self.unbanTxtField = [[UICustomTextField alloc] initWithFrame:CGRectMake(30, 60, 170, 31)];
    self.unbanTxtField.background = [UIImage imageNamed:@"login_textfield.png"];
    self.unbanTxtField.backgroundColor = [UIColor clearColor];
    self.unbanTxtField.dy = 5;
    self.unbanTxtField.delegate = self;
    self.unbanTxtField.secureTextEntry = NO;
    self.unbanTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.unbanTxtField.borderStyle = UITextBorderStyleNone;
    self.unbanTxtField.returnKeyType = UIReturnKeyDone;
    self.unbanTxtField.placeholder = @"请输入对方昵称";
    
    self.unbanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.unbanBtn setBackgroundImage:[UIImage imageNamed:@"icon_bg_blue_1.png"] forState:UIControlStateNormal];
    [self.unbanBtn setTitle:@"解除屏蔽" forState:UIControlStateNormal];
    self.unbanBtn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:22];
    self.unbanBtn.titleLabel.textColor = [UIColor whiteColor];
    self.unbanBtn.backgroundColor = [UIColor clearColor];
    self.unbanBtn.frame = CGRectMake(60, 120, 108, 37);
    [self.unbanBtn addTarget:self action:@selector(unbanPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)banSettingPressed:(id)sender
{
    self.gameSettingBtn.selected = NO;
    self.userSettingBtn.selected = NO;
    self.banSettingBtn.selected = YES;
    
    for (UIView *sview in self.displayView.subviews) {
        [sview removeFromSuperview];
    }
    
    [self.displayView addSubview:self.unbanBtn];
    [self.displayView addSubview:self.unbanTxtField];
    [self.displayView setNeedsDisplay];
}

- (IBAction)unbanPressed:(id)sender
{
    if ([self isEmptyInput:self.unbanTxtField])
    {
        [UIViewCustomAnimation showAlert:@"请输入对方的昵称"];
        return;
    }
    
    NSString *unbanID = [NSString stringWithFormat:@"%@", self.unbanTxtField.text];
    self.unbanTxtField.text = @"";
    [self.unbanTxtField resignFirstResponder];
    if (!self.delegate) {
        [UIViewCustomAnimation showAlert:@"未知错误，请稍后再试"];
        return;
    }
    
    [self.delegate unbanWithOppNickname:unbanID];
}

- (void)musicSwitchFliped:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = @"YES";
    if (!sender.on)
        value = @"NO";
    
    [defaults setObject:value forKey:@"musicSwitch"];
    [defaults synchronize];
}

- (void)audioSwitchFliped:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = @"YES";
    if (!sender.on)
        value = @"NO";
    
    [defaults setObject:value forKey:@"audioSwitch"];
    [defaults synchronize];
}

@end
