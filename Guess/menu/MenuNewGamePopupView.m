//
//  MenuNewGamePopupView.m
//  Guess
//
//  Created by Rui Du on 6/29/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "MenuNewGamePopupView.h"
#import "RDMTPopupWindow.h"
#import "Player.h"
#import "GuessGame.h"
#import "UICustomTextField.h"
#import "UIViewCustomAnimation.h"
#import "UICustomFont.h"

@interface MenuNewGamePopupView()

@property (strong, nonatomic) UICustomTextField *userInputTxtField;
@property SearchOppType searchOppType;
@property (strong, nonatomic) RDMTPopupWindow *popup;
@property (weak, nonatomic) UIView *sview;
@property (weak, nonatomic) Player *user;
@property (strong, nonatomic) UILabel *messageLabel;
@property (nonatomic) CGPoint originalCenter;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *editableItems;
@property (strong, nonatomic) UIView *shade;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation MenuNewGamePopupView

@synthesize sview = _sview;
@synthesize user = _user;
@synthesize delegate = _delegate;
@synthesize popup = _popup;
@synthesize userInputTxtField = _userInputTxtField;
@synthesize searchOppType = _searchOppType;
@synthesize originalCenter = _originalCenter;
@synthesize messageLabel = _messageLabel;
@synthesize spinner = _spinner;
@synthesize editableItems = _editableItems;
@synthesize shade = _shade;
@synthesize spinnerTimer = _spinnerTimer;

- (UILabel *)messageLabel
{
    if (_messageLabel)
        return _messageLabel;
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.font = [UICustomFont fontWithFontType:FONT_JIANCULIANG size:17];
    _messageLabel.textColor = [UIColor whiteColor];
    return _messageLabel;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.originalCenter = self.sview.center;
    self.sview.center = CGPointMake(self.originalCenter.x, 210);
    [self.sview setNeedsDisplay];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.sview.center = self.originalCenter;
    [self.sview setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 10);
}

- (MenuNewGamePopupView *)initWithSuperView:(UIView *)sview
                               andUser:(Player *)user
{
    self = [super init];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(62, 106, 197, 250)];
    contentView.backgroundColor = [UIColor clearColor];
    self.sview = sview;
    self.user = user;
    
    UIImageView *titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_xunzhaowanban.png"]];
    titleImgView.frame = CGRectMake(15, 11, 144, 41);
    titleImgView.backgroundColor = [UIColor clearColor];
    
    /*
     
     UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 7, 131, 49)];
     titleLabel.text = @"新建游戏";
     titleLabel.font = [UIFont systemFontOfSize:30];
     titleLabel.backgroundColor = [UIColor clearColor];
     
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 52, 175, 44)];
    subtitleLabel.text = @"您想怎样找到您的对手?";
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.backgroundColor = [UIColor clearColor];
     */
    
    UIButton *idBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    idBtn.frame = CGRectMake(12, 70, 155, 37);
    [idBtn setTitle:@"游戏帐户" forState:UIControlStateNormal];
    [idBtn addTarget:self action:@selector(findOppByNickname) forControlEvents:UIControlEventTouchUpInside];
    [idBtn setImage:[UIImage imageNamed:@"popup_find_btn1_1.png"] forState:UIControlStateNormal];
    idBtn.backgroundColor = [UIColor clearColor];
    
    UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    emailBtn.frame = CGRectMake(12, 130, 155, 37);
    [emailBtn setTitle:@"邮箱" forState:UIControlStateNormal];
    [emailBtn addTarget:self action:@selector(findOppByEmail) forControlEvents:UIControlEventTouchUpInside];
    [emailBtn setImage:[UIImage imageNamed:@"popup_find_btn2_1.png"] forState:UIControlStateNormal];
    emailBtn.backgroundColor = [UIColor clearColor];
    
    UIButton *randomBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    randomBtn.frame = CGRectMake(12, 190, 155, 37);
    [randomBtn setTitle:@"随机" forState:UIControlStateNormal];
    [randomBtn addTarget:self action:@selector(findOppByRandom) forControlEvents:UIControlEventTouchUpInside];
    [randomBtn setImage:[UIImage imageNamed:@"popup_find_btn3_1.png"] forState:UIControlStateNormal];
    randomBtn.backgroundColor = [UIColor clearColor];
    
    [contentView addSubview:titleImgView];
    //[contentView addSubview:subtitleLabel];
    [contentView addSubview:idBtn];
    [contentView addSubview:emailBtn];
    [contentView addSubview:randomBtn];
    
    self.popup = [[RDMTPopupWindow alloc] initInSuperView:self.sview
                                          withContentView:contentView
                                                withFrame:contentView.frame];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeDown:)];
    recognizer.delegate = self;
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.sview addGestureRecognizer:recognizer];
    
    self.shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.shade.backgroundColor = [UIColor blackColor];
    self.shade.alpha = 0;
    [self.sview addSubview:self.shade];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(160, 240);
    [self.sview addSubview:self.spinner];
    
    NSMutableArray *editableItemsArray = [[NSMutableArray alloc] init];
    [editableItemsArray addObject:idBtn];
    [editableItemsArray addObject:emailBtn];
    [editableItemsArray addObject:randomBtn];
    self.editableItems = [editableItemsArray mutableCopy];
    
    return self;
}

- (void)spinnerTimeout
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    //[UIViewCustomAnimation showAlert:@"连接超时"];
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self.userInputTxtField resignFirstResponder];
}

- (void)findOppByNickname
{
    [self findOppWithOption:SEARTH_OPP_WITH_NICKNAME];
}

- (void)findOppByEmail
{
    [self findOppWithOption:SEARTH_OPP_WITH_EMAIL];
}
- (void)findOppByRandom
{
    //[self findOppWithOption:SEARTH_OPP_WITH_RANDOM];
    self.searchOppType = SEARTH_OPP_WITH_RANDOM;
    self.user.delegate = self;
    [UIViewCustomAnimation startSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    self.spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:E_TIMEOUT
                                                         target:self
                                                       selector:@selector(spinnerTimeout)
                                                       userInfo:nil
                                                        repeats:NO];
    [self.user searchOppWithInput:NULL WithOption:SEARTH_OPP_WITH_RANDOM];
    
}

- (void)findOppWithOption:(SearchOppType)option
{
    [self.popup closeWindow];
    //NSString *question = @"请输入对方的帐户";
    NSString *placeholder = @"请输入对方昵称";
    self.searchOppType = option;
    if (option == SEARTH_OPP_WITH_EMAIL)
    {
        //question = @"请输入对手的邮箱";
        placeholder = @"请输入对方账号";
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(62, 106, 197, 230)];
    
    UIImageView *titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"art_xunzhaowanban.png"]];
    titleImgView.frame = CGRectMake(15, 11, 144, 41);
    titleImgView.backgroundColor = [UIColor clearColor];
    /*
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, 7, 131, 49)];
    titleLabel.text = @"新建游戏";
    titleLabel.font = [UIFont systemFontOfSize:30];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 52, 175, 44)];
    subtitleLabel.text = question;
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.backgroundColor = [UIColor clearColor];
     */
    
    self.userInputTxtField = [[UICustomTextField alloc] initWithFrame:CGRectMake(17, 72, 150, 28)];
    self.userInputTxtField.placeholder = placeholder;
    self.userInputTxtField.dx = 10;
    self.userInputTxtField.dy = 3;
    self.userInputTxtField.delegate = self;
    self.userInputTxtField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userInputTxtField.background = [UIImage imageNamed:@"popup_txtfield.png"];
    self.userInputTxtField.backgroundColor = [UIColor clearColor];
    self.userInputTxtField.borderStyle = UITextBorderStyleNone;
    self.userInputTxtField.returnKeyType = UIReturnKeyDone;
    
    UIButton *idBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    idBtn.frame = CGRectMake(35, 117, 110, 50);
    [idBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [idBtn addTarget:self action:@selector(searchOpp) forControlEvents:UIControlEventTouchUpInside];
    [idBtn setImage:[UIImage imageNamed:@"popup_find_btn4_1.png"] forState:UIControlStateNormal];
    idBtn.backgroundColor = [UIColor clearColor];
    
    [contentView addSubview:titleImgView];
    //[contentView addSubview:titleLabel];
    //[contentView addSubview:subtitleLabel];
    [contentView addSubview:self.userInputTxtField];
    [contentView addSubview:idBtn];
    
    self.popup = [[RDMTPopupWindow alloc] initInSuperView:self.sview
                                          withContentView:contentView
                                                withFrame:CGRectMake(62, 106, 197, 230)];
}

- (void)searchOpp
{
    NSString *inputText = self.userInputTxtField.text;
    inputText = [inputText lowercaseString];
    NSLog(@"search %@ by %d", inputText, self.searchOppType);
    [self textFieldShouldReturn:self.userInputTxtField];
    
    CGRect popupWindowFrame = self.popup.frame;
    self.messageLabel.frame = CGRectMake(5+popupWindowFrame.origin.x, popupWindowFrame.size.height - 40 + popupWindowFrame.origin.y, popupWindowFrame.size.width - 10, 30);
    self.messageLabel.textAlignment = UITextAlignmentCenter;
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.text = @"搜索中";
    [self.popup.bigPanelView addSubview:self.messageLabel];
    
    if (self.searchOppType == SEARTH_OPP_WITH_EMAIL)
    {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if ([emailText evaluateWithObject:inputText] != 1)
        {
            self.messageLabel.text = @"请输入合法的邮箱地址";
            [self.popup.bigPanelView setNeedsDisplay];
            return;
        }
    }
    
    if (([inputText isEqualToString:self.user.nickname] &&
         self.searchOppType == SEARTH_OPP_WITH_NICKNAME) ||
        ([inputText isEqualToString:self.user.email] && self.searchOppType == SEARTH_OPP_WITH_EMAIL))
    {
        // NOT YOURSELF
        self.messageLabel.text = @"您无法与自己配对游戏";
        [self.popup.bigPanelView setNeedsDisplay];
    }
    else {
        self.user.delegate = self;
        [self.user searchOppWithInput:inputText WithOption:self.searchOppType];
        //[self.httpConn searchOppWithOption:self.searchOppType withPostfix:inputText withUserID:self.user.ID];
    }

    // Do search here

}

- (void)handleSearch:(SearchStatus)status
            response:(NSDictionary *)serverResponse
{
    Player *player2;
    GuessGame *game;
    UIActionSheet *mymenu;
    
    switch (status) {
        case SEARCH_SUCCESS:
            // Found
            player2 = [[Player alloc] initWithDictionary:serverResponse];
            //self.user.gamesArray;
            
            game = [self.user.gamesDict objectForKey:player2.ID];
            if(game != NULL) {
                NSLog(@"already there");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[NSString stringWithFormat:@"你又随机到%@,有缘啊", player2.nickname]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                [self.popup closeWindow];
            }
            else
            {
                [self.user createGameWithPlayer:player2];
                [self.delegate reloadDataForPlayer:self.user];
                [self.popup closeWindow];
            }

            break;
        case SEARCH_BE_BANNED:
            self.messageLabel.text = @"已被该玩家屏蔽";
            [self.popup.bigPanelView setNeedsDisplay];
            break;
        case SEARCH_IN_BAN:
            self.messageLabel.text = @"该玩家已被屏蔽";
            [self.popup.bigPanelView setNeedsDisplay];
            mymenu = [[UIActionSheet alloc] initWithTitle:@"将该玩家解除屏蔽？"
                                                 delegate:self
                                        cancelButtonTitle:nil
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:nil];
            
            [mymenu addButtonWithTitle:@"确定"];
            mymenu.cancelButtonIndex = [mymenu addButtonWithTitle: @"取消"];
            [mymenu showInView:self.sview];
            break;
        case SEARCH_CONFLICT:
            self.messageLabel.text = @"与该玩家游戏已存在";
            [self.popup.bigPanelView setNeedsDisplay];
            break;
        case SEARCH_CONFLICT_SELF_REMOVED:
            self.messageLabel.text = @"该玩家未删除与你的游戏";
            [self.popup.bigPanelView setNeedsDisplay];
            break;
        case SEARCH_NOT_FOUND:
            // Not Found
            self.messageLabel.text = @"找不到该玩家";
            [self.popup.bigPanelView setNeedsDisplay];
            break;
        case SEARCH_RANDOM_NOT_AVAILABLE:
            [UIViewCustomAnimation showAlert:@"没有可用玩家，请稍后再试"];
            [self.popup.bigPanelView setNeedsDisplay];
            break;
    }
}

- (BOOL)checkServerResponse:(int)code
{
    if (code == E_BAD_DATA) {
        [UIViewCustomAnimation showAlert:@"服务器故障，请重新操作"];
        return FALSE;
    }
    else if (code == E_WRONG_SESSION) {
        [UIViewCustomAnimation showAlert:@"服务器故障，请重新登陆"];
        return FALSE;
    }
    
    return TRUE;
}

- (void)requestDidFinish:(BOOL)success withResponse:(NSDictionary *)serverResponse withType:(RequestType)type
{
    [UIViewCustomAnimation stopSpinAnimationUsingSpinner:self.spinner andEditableItems:self.editableItems andShadingView:self.shade];
    [self.spinnerTimer invalidate];
    [self setSpinnerTimer:nil];
    if (!success) {
        [UIViewCustomAnimation showAlert:@"请连接网络"];
        return;
    }
    
    NSString *state = [serverResponse objectForKey:@"s"];
    if (![self checkServerResponse:[state intValue]])
        return;
    
    SearchStatus searchStatus;
    switch (type) {
        case REQUEST_TYPE_SEARCH_OPP:
            //state= [serverResponse objectForKey:@"s"];
            searchStatus = [state intValue];
            [self handleSearch:searchStatus response:serverResponse];
            break;
            
        case REQUEST_TYPE_UNBAN_PLAYER:
            [UIViewCustomAnimation showAlert:@"解除屏蔽成功！"];
            self.messageLabel.text = @"再搜一次！";
            break;
            
            
        default:
            break;
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"确定"])
    {
        switch (self.searchOppType) {
            case SEARTH_OPP_WITH_EMAIL:
                [self.user unbanOppPlayerUsingEmail:self.userInputTxtField.text];
                break;
                
            case SEARTH_OPP_WITH_NICKNAME:
                [self.user unbanOppPlayer:self.userInputTxtField.text];
                break;
                
            case SEARTH_OPP_WITH_RANDOM:
                NSLog(@"get a random one");
                break;
        }
    }
}

@end
