//
//  RDMTPopupWindow.h
//
//  Created by Marin Todorov on 7/1/11.
//  Copyright 2011 Marin Todorov. MIT license
//  http://www.opensource.org/licenses/mit-license.php
//  
//  Modified by Rui Du on 6/7/2012 to adapt to ios 5.

#import <Foundation/Foundation.h>

@interface RDMTPopupWindow : NSObject

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *bigPanelView;
@property (nonatomic) CGRect frame;

-(RDMTPopupWindow *)initInSuperView:(UIView *)sview
                    withContentView:(UIView *)cview
                          withFrame:(CGRect) frame;
-(void)closeWindow;

@end
