//
//  TutorialView.h
//  Guess
//
//  Created by Rui Du on 11/25/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TutorialViewDelegate <NSObject>

@required
- (void)closeTutorial;

@end

@interface TutorialView : UIView<UIGestureRecognizerDelegate>
@property (weak, nonatomic) id delegate;

- (void)initialize;
- (void)uninitialize;

@end
