//
//  main.m
//  Guess
//
//  Created by Rui Du on 6/11/12.
//  Copyright (c) 2012 Slidea Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GuessAppDelegate.h"
#import "HttpConn.h"
#import "UIViewCustomAnimation.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [HttpConn init];
        [UIViewCustomAnimation init];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GuessAppDelegate class]));
    }
}
