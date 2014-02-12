//
//  TYLayoutItem.m
//  UI Layout Helper Item
//
//  Created by Tek yin Kwee on 4/23/12.
//  Copyright (c) 2012 nucleus302@gmail.com. All rights reserved.
//

#import "TYLayoutItem.h"

@implementation TYLayoutItem
@synthesize align;
@synthesize rect;
@synthesize view;
@synthesize margin;


- (id)initWithView:(UIView *)aView margin:(CGBorder)aMargin align:(TYLayoutAlign)anAlign {
    self = [super init];
    if (self) {
        view = aView;
        rect = [aView frame];
        margin = aMargin;
        align = anAlign;
    }

    return self;
}

- (id)initWithRect:(CGRect)aRect margin:(CGBorder)aMargin align:(TYLayoutAlign)anAlign {
    self = [super init];
    if (self) {
        rect = aRect;
        margin = aMargin;
        align = anAlign;
    }

    return self;
}


- (CGFloat)getX {
    return rect.origin.x;
}

- (CGFloat)getY {
    return rect.origin.y;
}

- (CGFloat)getHeight {
    return rect.size.height;
}

- (CGFloat)getWidth {
    return rect.size.width;
}

- (CGFloat)getCalculatedHeight {
    return [self getHeight] + [self getVerticalMargin];
}

- (CGFloat)getCalculatedWidth {
    return [self getWidth] + [self getHorizontalMargin];
}

- (CGFloat)getVerticalMargin {
    return margin.top + margin.bottom;
}

- (CGFloat)getHorizontalMargin {
    return margin.left + margin.right;
}

@end
