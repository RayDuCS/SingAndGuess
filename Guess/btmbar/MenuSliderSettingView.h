//
//  MenuSliderSettingsView.h
//  Guess
//
//  Created by Rui Du on 6/28/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Player;
@protocol MenuSliderSettingsViewDelegate <NSObject>
@required
- (void)unbanWithOppNickname:(NSString *)oppNickname;
- (void)updateInfoWithOldPwd:oldPwd withNewPwd:pwd withNickname:nickname withPortrait:(UIImage *)portrait;
- (Player *)getUser;
@end

@interface MenuSliderSettingView : NSObject<UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>


@property (strong, nonatomic) UIView *view;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) Player *user;

- (MenuSliderSettingView *)initWithSender:(UIButton *)sender
                       withRootController:(UIViewController * )root
                             withDelegate:(id)delegate;

@end
