//
//  ReplayGameViewController.m
//  Guess
//
//  Created by Rui Du on 11/24/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "ReplayGameViewController.h"
#import "UserView.h"
#import "OppView.h"
#import "Player.h"
#import "GuessGame.h"
#import "Inventory.h"
#import "UICustomColor.h"
#import "UICustomFont.h"

@interface ReplayGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *guess1Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess2Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess3Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess4Btn;
@property (weak, nonatomic) IBOutlet UIButton *guess5Btn;
@property (weak, nonatomic) IBOutlet UILabel *turnValueLabel;

@property (strong, nonatomic) NSTimer *returnTimer;

@property (weak, nonatomic) Player *user;
@property (weak, nonatomic) GuessGame *game;
@property (weak, nonatomic) UserView *userView;
@property (weak, nonatomic) OppView *oppView;
@property (weak, nonatomic) NSDictionary *userInfo;
@property (nonatomic) int popIndex;
@property (strong, nonatomic) NSTimer *spinnerTimer;

@end

@implementation ReplayGameViewController
@synthesize user = _user;
@synthesize game = _game;
@synthesize userView = _userView;
@synthesize oppView = _oppView;
@synthesize popIndex = _popIndex;

@synthesize tipLabel = _tipLabel;
@synthesize guess1Btn = _guess1Btn;
@synthesize guess2Btn = _guess2Btn;
@synthesize guess3Btn = _guess3Btn;
@synthesize guess4Btn = _guess4Btn;
@synthesize guess5Btn = _guess5Btn;
@synthesize turnValueLabel = _turnValueLabel;
@synthesize returnTimer = _returnTimer;
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

- (void)loadWithPlayer:(Player *)user
                inGame:(GuessGame *)game
              userInfo:(NSDictionary *)userInfo
           usePopIndex:(int)index
{
    [super loadWithPlayer:user inGame:game
                 userInfo:(NSDictionary *)userInfo
              usePopIndex:index];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userView.view.alpha = 0;
    self.oppView.view.alpha = 0;
    self.turnValueLabel.alpha =0;
    [self setUserView:nil];
    [self setOppView:nil];
    [self setTurnValueLabel:nil];
    
    UIColor *btnColor = [UICustomColor colorWithType:UI_CUSTOM_COLOR_STEEL_BLUE_2];
    
    [self.guess1Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess1Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess2Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess2Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess3Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess3Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess4Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess4Btn setTitleColor: btnColor forState:UIControlStateSelected];
    [self.guess5Btn setTitleColor: btnColor forState:UIControlStateNormal];
    [self.guess5Btn setTitleColor: btnColor forState:UIControlStateSelected];
    
    self.guess1Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess2Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess3Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess4Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    self.guess5Btn.titleLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:27];
    [self.guess1Btn setTitle:[self.game.answerCN objectAtIndex:0] forState:UIControlStateNormal];
    [self.guess2Btn setTitle:[self.game.answerCN objectAtIndex:1] forState:UIControlStateNormal];
    [self.guess3Btn setTitle:[self.game.answerCN objectAtIndex:2] forState:UIControlStateNormal];
    [self.guess4Btn setTitle:[self.game.answerCN objectAtIndex:3] forState:UIControlStateNormal];
    [self.guess5Btn setTitle:[self.game.answerCN objectAtIndex:4] forState:UIControlStateNormal];
    [self.guess1Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.guess2Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.guess3Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.guess4Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.guess5Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [super configureOptionBtn:self.guess1Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess2Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess3Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess4Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    [super configureOptionBtn:self.guess5Btn cracked:NO menuVCType:MENU_VIEW_CONTROLLER_TYPE_GUESS];
    
    self.turnValueLabel.font = [UICustomFont fontWithFontType:FONT_HUAKANG size:16];
    self.turnValueLabel.text = [super getTurnString:self.game.round];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateGuess];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setTipLabel:nil];
    [self setGuess1Btn:nil];
    [self setGuess2Btn:nil];
    [self setGuess3Btn:nil];
    [self setGuess4Btn:nil];
    [self setGuess5Btn:nil];
    [self setGuess1Btn:nil];
    [self setGuess2Btn:nil];
    [self setGuess3Btn:nil];
    [self setGuess4Btn:nil];
    [self setGuess5Btn:nil];
    [self setTurnValueLabel:nil];
    [super viewDidUnload];
}

- (void)btnPressed:(UIButton *)sender
{
    [self returnToPreviousVCDelayed:NO];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self returnToPreviousVCDelayed:NO];
}

- (void)returnToPreviousVC
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)returnToPreviousVCDelayed:(BOOL)delayed
{
    if (!delayed) {
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
        return;
    }
    
    self.returnTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(returnToPreviousVC)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (BOOL)checkChoiceIsGuess:(NSString *)choiceID
{
    if ([choiceID isEqualToString:self.game.guess]) return TRUE;
    
    return FALSE;
}

- (BOOL)checkChoiceIsAnswer:(NSString *)choiceID
{
    if ([choiceID isEqualToString:self.game.answer]) return TRUE;
    
    return FALSE;
}

- (void)animateGuess
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    if (![self checkChoiceIsGuess:[self.game.answerID objectAtIndex:0]]) [mutableArray addObject:self.guess1Btn];
    if (![self checkChoiceIsGuess:[self.game.answerID objectAtIndex:1]]) [mutableArray addObject:self.guess2Btn];
    if (![self checkChoiceIsGuess:[self.game.answerID objectAtIndex:2]]) [mutableArray addObject:self.guess3Btn];
    if (![self checkChoiceIsGuess:[self.game.answerID objectAtIndex:3]]) [mutableArray addObject:self.guess4Btn];
    if (![self checkChoiceIsGuess:[self.game.answerID objectAtIndex:4]]) [mutableArray addObject:self.guess5Btn];
    
    [UIView animateWithDuration:1
                          delay:0.5
                        options:UIViewAnimationCurveLinear
                     animations:^() {
                         for (UIButton *btn in mutableArray) {
                             btn.alpha = 0.5;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (self.game.reward == 0) {
                             [self animateAnswer];
                         } else {
                             //[self returnToPreviousVCDelayed:YES];
                         }
                     }];
}

- (void)animteButton:(UIButton *)button
{
    button.alpha = 1;
    CGRect originFrame = button.frame;
    float delta_x = 2;
    float delta_y = delta_x * originFrame.size.height / originFrame.size.width;
    [UIView animateWithDuration:1
                          delay:0.01
                        options:UIViewAnimationCurveLinear
                     animations:^() {
                         button.frame = CGRectMake(originFrame.origin.x-delta_x, originFrame.origin.y-delta_y, originFrame.size.width+2*delta_x, originFrame.size.height+2*delta_y);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:0.01
                                             options:UIViewAnimationCurveLinear
                                          animations:^() {
                                              button.frame = originFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              //[self returnToPreviousVCDelayed:YES];
                                          }];
                     }];
    
}

- (void)animateAnswer
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    if ([self checkChoiceIsAnswer:[self.game.answerID objectAtIndex:0]]) [mutableArray addObject:self.guess1Btn];
    if ([self checkChoiceIsAnswer:[self.game.answerID objectAtIndex:1]]) [mutableArray addObject:self.guess2Btn];
    if ([self checkChoiceIsAnswer:[self.game.answerID objectAtIndex:2]]) [mutableArray addObject:self.guess3Btn];
    if ([self checkChoiceIsAnswer:[self.game.answerID objectAtIndex:3]]) [mutableArray addObject:self.guess4Btn];
    if ([self checkChoiceIsAnswer:[self.game.answerID objectAtIndex:4]]) [mutableArray addObject:self.guess5Btn];
    
    for (UIButton *btn in mutableArray) {
        [self animteButton:btn];
    }
}

@end
