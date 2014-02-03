//
//  TYLayoutHelper.h
//  UI Layouter
//
//  Created by Tek yin Kwee on 4/23/12.
//  Copyright (c) 2012 nucleus302@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGBorder.h"

typedef enum {
    TYLayoutOrientationHorizontal = 0,
    TYLayoutOrientationVertical = 1
} TYLayoutOrientation;

typedef enum {
    TYLayoutAlignLeftOrTop = 0,
    TYLayoutAlignCenter = 1,
    TYLayoutAlignRightOrTop = 2
} TYLayoutAlign;

@class TYLayoutItem;

@interface TYLayoutHelper : NSObject {
    UIView *container;
    CGBorder padding;
    TYLayoutOrientation orientation;
    NSMutableArray *member;
}
@property(nonatomic, strong) UIView *container;
@property(nonatomic, assign) TYLayoutOrientation orientation;
@property(nonatomic, strong) NSMutableArray *member;
@property(nonatomic, assign) CGBorder padding;
@property(nonatomic) bool isSorted;

- (TYLayoutHelper *)initWithParent:(UIView *)aContainer padding:(CGBorder)aPadding orientation:(TYLayoutOrientation)anOrientation;

- (TYLayoutHelper *)initWithParent:(UIView *)aContainer orientation:(TYLayoutOrientation)anOrientation;

- (TYLayoutHelper *)initWithParent:(UIView *)aContainer;

- (TYLayoutHelper *)addMemberWithView:(UIView *)aView align:(TYLayoutAlign)anAlign margin:(CGBorder)aMargin;

- (TYLayoutHelper *)addMemberWithView:(UIView *)aView;

- (NSInteger)getMemberCount;

- (CGSize)getContentBounds;

- (TYLayoutHelper *)clearMember;

- (TYLayoutHelper *)doReLayout;

- (TYLayoutHelper *)doReLayoutWithAnimation:(BOOL)useAnimation duration:(float)duration;

- (TYLayoutHelper *)randomizeMember;
@end
