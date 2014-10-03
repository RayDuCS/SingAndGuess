//
//  UIViewCustomAnimation.h
//  Guess
//
//  Created by Rui Du on 8/3/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface UIViewCustomAnimation : NSObject

+ (void)init;

+ (void)heartbeatAnimationForView:(UIView *)view
                            ratio:(float)ratio    // default 1.05, size of enlarge points
                         duration:(float)duration // default 0.8, duration of enlarging
                           repeat:(int)repeat;

+ (void)heartbeatAnimationForView:(UIView *)view
                             ratio:(float)ratio
                           repeat:(int)repeat;

+ (void)heartbeatAnimationForView:(UIView *)view
                         duration:(float)duration
                           repeat:(int)repeat;

+ (void)heartbeatAnimationForView:(UIView *)view
                           repeat:(int)repeat; // 0 for infiniti

+ (void)startSpinAnimationUsingSpinner:(UIActivityIndicatorView *)spinner
                      andEditableItems:(NSMutableArray *)editableItems
                        andShadingView:(UIView *)shade;
+ (void)stopSpinAnimationUsingSpinner:(UIActivityIndicatorView *)spinner
                     andEditableItems:(NSMutableArray *)editableItems
                       andShadingView:(UIView *)shade;
+ (void)startNoEditableItems:(NSArray *)editableItems;
+ (void)stopNoEditableItems:(NSArray *)editableItems;

+ (void)showAlert:(NSString *)message;

+ (void)moveViewAlongPath:(UIView *)view
                 endPoint:(CGPoint)endPoint
                 duration:(CGFloat)duration
              resizeWidth:(CGFloat)width;

//[[NSBundle mainBundle] pathForResource:@"guess_hammer" ofType:@"wav"]
+ (AVAudioPlayer *)audioPlayerAtPath:(NSString *)path
                              volumn:(float)volumn;
@end
