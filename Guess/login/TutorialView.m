//
//  TutorialView.m
//  Guess
//
//  Created by Rui Du on 11/25/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "TutorialView.h"
@interface TutorialView()
@property (nonatomic) int maxPage;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

#define TUTORIAL_IMAGE_PREFIX @"tutorial_"

@implementation TutorialView
@synthesize delegate = _delegate;
@synthesize maxPage = _maxPage;
@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initialize
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    self.maxPage = 8;
    self.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    NSInteger numberOfViews = self.maxPage;
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.frame.size.width, self.frame.size.height)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d.png", TUTORIAL_IMAGE_PREFIX, i+1]];
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * numberOfViews, self.frame.size.height);
    [self addSubview:self.scrollView];
    
    self.scrollView.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^() {
                         self.scrollView.alpha = 1;
                     }];
}

- (void)uninitialize
{
    [UIView animateWithDuration:0.5
                     animations:^() {
                         self.scrollView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self setScrollView:nil];
                         self.alpha = 0;
                         [self.delegate closeTutorial];
                     }];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"%f", self.scrollView.contentOffset.x/self.frame.size.width);
    if (self.scrollView.contentOffset.x/self.frame.size.width < self.maxPage-1) return;
    
    
    [self uninitialize];
}

@end
