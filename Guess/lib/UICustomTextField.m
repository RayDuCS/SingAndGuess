//
//  UICustomTextField.m
//  Guess
//
//  Created by Rui Du on 7/9/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import "UICustomTextField.h"

@implementation UICustomTextField
@synthesize dx = _dx;
@synthesize dy = _dy;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    self.dx = 10;
    self.dy = 0;
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.dx, self.dy);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.dx, self.dy);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
