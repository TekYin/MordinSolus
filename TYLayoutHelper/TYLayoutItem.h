//
//  TYLayoutItem.h
//  UI Layouter
//
//  Created by Tek yin Kwee on 4/23/12.
//  Copyright (c) 2012 nucleus302@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGBorder.h"
#import "TYLayoutHelper.h"

@interface TYLayoutItem : NSObject {
    UIView *view;
    CGRect rect;
    CGBorder margin;
    TYLayoutAlign align;
}
@property(nonatomic, assign) TYLayoutAlign align;
@property(nonatomic, assign) CGRect rect;
@property(nonatomic, strong) UIView *view;
@property(nonatomic, assign) CGBorder margin;


- (id)initWithView:(UIView *)aView margin:(CGBorder)aMargin align:(TYLayoutAlign)anAlign;

- (id)initWithRect:(CGRect)aRect margin:(CGBorder)aMargin align:(TYLayoutAlign)anAlign;

- (CGFloat)getY;

- (CGFloat)getX;

- (CGFloat)getHeight;

- (CGFloat)getWidth;

- (CGFloat)getCalculatedHeight;

- (CGFloat)getCalculatedWidth;

- (CGFloat)getVerticalMargin;

- (CGFloat)getHorizontalMargin;

@end
