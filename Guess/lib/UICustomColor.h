//
//  UICustomColor.h
//  Guess
//
//  Created by Rui Du on 10/7/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    UI_CUSTOM_COLOR_WHITE = 1,          // 1-99 for white, 100-199 red, 200-299 orange, 300-399 yellow, 400-499 green, 500-599 blue, 600-699 purple
    UI_CUSTOM_COLOR_PINK1 = 101,
    UI_CUSTOM_COLOR_DARK_ORANGE1 = 200,
    UI_CUSTOM_COLOR_GOLD = 300,
    UI_CUSTOM_COLOR_GOLDENROD = 301,
    UI_CUSTOM_COLOR_YELLOW1 = 302,
    UI_CUSTOM_COLOR_WHEAT2 = 303,
    UI_CUSTOM_COLOR_LIGHT_GOLDENROD = 304,
    UI_CUSTOM_COLOR_DARKSEAGREEN1 = 401,
    UI_CUSTOM_COLOR_SPRINGGREEN = 402,
    UI_CUSTOM_COLOR_STEEL_BLUE = 500,
    UI_CUSTOM_COLOR_STEEL_BLUE_2 = 502,
    UI_CUSTOM_COLOR_CADE_BLUE = 504,
    UI_CUSTOM_COLOR_GRAY81 = 701,
    
}UICustomColorType;

@interface UICustomColor : UIColor

+ (UIColor *)colorWithType:(UICustomColorType)type;

@end
