//
//  RegisterViewController.h
//  Guess
//
//  Created by Rui Du on 7/2/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface RegisterViewController : UIViewController<UITextFieldDelegate, PlayerSpinnerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)loadWithResponse:(NSDictionary *)response
                userInfo:(NSDictionary *)userInfo;

@end
