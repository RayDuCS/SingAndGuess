//
//  UIViewCustomAnimation.m
//  Guess
//
//  Created by Rui Du on 8/3/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "UIViewCustomAnimation.h"
#import "QuartzCore/QuartzCore.h"

@implementation UIViewCustomAnimation
static UIAlertView *alert;

+ (void)init
{
    alert = [[UIAlertView alloc] init];
}

+ (void)heartbeatAnimationForView:(UIView *)view
                            ratio:(float)ratio
                         duration:(float)duration
                           repeat:(int)repeat
{
    //CGRect frame = view.frame;
    //float sizeOfY = size * frame.size.height / frame.size.width;
    [UIView animateWithDuration:duration
                          delay:0.1
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(ratio, ratio);
                         //view.frame = CGRectMake(frame.origin.x-size, frame.origin.y-sizeOfY, frame.size.width+size*2, frame.size.height+sizeOfY*2);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:duration
                                               delay:0.1
                                             options:UIViewAnimationCurveLinear
                                          animations:^{
                                              //view.frame = frame;
                                              view.transform = CGAffineTransformMakeScale(1, 1);

                                          }
                                          completion:^(BOOL finished){
                                              if (repeat == 1) return;
                                              
                                              if (repeat > 0)
                                                  [UIViewCustomAnimation heartbeatAnimationForView:view ratio:ratio duration:duration repeat:repeat-1];
                                              else
                                                  [UIViewCustomAnimation heartbeatAnimationForView:view ratio:ratio duration:duration repeat:repeat];
                                          }];
                     }];
}

+ (void)heartbeatAnimationForView:(UIView *)view repeat:(int)repeat
{
    [UIViewCustomAnimation heartbeatAnimationForView:view ratio:1.05 duration:0.8 repeat:repeat];
}

+ (void)heartbeatAnimationForView:(UIView *)view duration:(float)duration repeat:(int)repeat
{
    [UIViewCustomAnimation heartbeatAnimationForView:view ratio:1.05 duration:duration repeat:repeat];
}

+ (void)heartbeatAnimationForView:(UIView *)view ratio:(float)ratio repeat:(int)repeat
{
    [UIViewCustomAnimation heartbeatAnimationForView:view ratio:ratio duration:0.8 repeat:repeat];
}

+ (void)startNoEditableItems:(NSMutableArray *)editableItems
{
    for (id item in editableItems)
    {
        if ([item isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)item;
            [btn setEnabled:NO];
        }
        else if ([item isKindOfClass:[UITextField class]])
        {
            UITextField *txtField = (UITextField *)item;
            [txtField setEnabled:NO];
        }
        else if ([item isKindOfClass:[UISlider class]])
        {
            UISlider *slider = (UISlider *)item;
            [slider setEnabled:NO];
        }
        else if ([item isKindOfClass:[UITableView class]])
        {
            UITableView *table = (UITableView *)item;
            [table setUserInteractionEnabled:NO];
            table.allowsSelection = NO;
        }
        else if ([item isKindOfClass:[UIView class]])
        {
            UIView *view = (UIView *)item;
            [view setUserInteractionEnabled:NO];
        }
    }
}

+ (void)startSpinAnimationUsingSpinner:(UIActivityIndicatorView *)spinner
                      andEditableItems:(NSMutableArray *)editableItems
                        andShadingView:(UIView *)shade
{
    [shade.superview bringSubviewToFront:shade];
    [spinner.superview bringSubviewToFront:spinner];
    
    [spinner startAnimating];
    shade.alpha = 0.6;
    
    [UIViewCustomAnimation startNoEditableItems:editableItems];
}

+ (void)stopNoEditableItems:(NSMutableArray *)editableItems
{
    for (id item in editableItems)
    {
        if ([item isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)item;
            [btn setEnabled:YES];
        }
        else if ([item isKindOfClass:[UITextField class]])
        {
            UITextField *txtField = (UITextField *)item;
            [txtField setEnabled:YES];
        }
        else if ([item isKindOfClass:[UISlider class]])
        {
            UISlider *slider = (UISlider *)item;
            [slider setEnabled:YES];
        }
        else if ([item isKindOfClass:[UITableView class]])
        {
            UITableView *table = (UITableView *)item;
            [table setUserInteractionEnabled:YES];
            table.allowsSelection = YES;
        }
        else if ([item isKindOfClass:[UIView class]])
        {
            UIView *view = (UIView *)item;
            [view setUserInteractionEnabled:YES];
        }
    }
}

+ (void)stopSpinAnimationUsingSpinner:(UIActivityIndicatorView *)spinner
                     andEditableItems:(NSMutableArray *)editableItems
                       andShadingView:(UIView *)shade
{
    [spinner stopAnimating];
    shade.alpha = 0;
    
    [UIViewCustomAnimation stopNoEditableItems:editableItems];
}

+ (void)showAlert:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @""
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)moveViewAlongPath:(UIView *)view
                 endPoint:(CGPoint)endPoint
                 duration:(CGFloat)duration
              resizeWidth:(CGFloat)width
{
    view.alpha = 1.0f;
    CGRect imageFrame = view.frame;
    
    CGPoint viewOrigin = view.frame.origin;
    viewOrigin.y = viewOrigin.y + imageFrame.size.height / 2.0f;
    viewOrigin.x = viewOrigin.x + imageFrame.size.width / 2.0f;
    
    view.frame = imageFrame;
    view.layer.position = viewOrigin;
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0]];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Set up scaling
    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(width, imageFrame.size.height * (width / imageFrame.size.width))]];
    resizeAnimation.fillMode = kCAFillModeForwards;
    resizeAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, viewOrigin.y, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, resizeAnimation, nil]];
    group.duration = duration;
    group.delegate = self;
    [group setValue:view forKey:@"imageViewBeingAnimated"];
    
    [view.layer addAnimation:group forKey:@"savingAnimation"];
    
}

+ (AVAudioPlayer *)audioPlayerAtPath:(NSString *)path volumn:(float)volumn;
{
    if (!path) return nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *audioOn = [defaults objectForKey:@"audioSwitch"];
    if (!audioOn) audioOn = @"YES";
    
    BOOL isAudioOn = YES;
    if ([audioOn isEqualToString:@"NO"]) isAudioOn = NO;
    
    if (!isAudioOn) return nil;
    
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    [player prepareToPlay];
    //player.volume = volumn;
    return player;
}

@end
