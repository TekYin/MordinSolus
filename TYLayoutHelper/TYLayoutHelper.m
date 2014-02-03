//
//  TYLayoutHelper.m
//  UI Layout Helper
//
//  Created by Tek yin Kwee on 4/23/12.
//  Copyright (c) 2012 nucleus302@gmail.com. All rights reserved.
//

#import "TYLayoutHelper.h"
#import "TYLayoutItem.h"

@implementation TYLayoutHelper {
}
@synthesize container;
@synthesize orientation;
@synthesize member;
@synthesize padding;


@synthesize isSorted;

- (TYLayoutHelper *)initWithParent:(UIView *)aContainer padding:(CGBorder)aPadding orientation:(TYLayoutOrientation)anOrientation {
    self = [super init];
    if (self) {
        isSorted = NO;
        container = aContainer;
        padding = aPadding;
        orientation = anOrientation;
        member = [[NSMutableArray alloc] init];
    }
    return self;
}

- (TYLayoutHelper *)initWithParent:(UIView *)aContainer orientation:(TYLayoutOrientation)anOrientation {
    return [self initWithParent:aContainer padding:CGBorderMake(0, 0, 0, 0) orientation:anOrientation];
}

- (TYLayoutHelper *)initWithParent:(UIView *)aContainer {
    return [self initWithParent:aContainer padding:CGBorderMake(0, 0, 0, 0) orientation:TYLayoutOrientationVertical];
}

- (TYLayoutHelper *)addMemberWithView:(UIView *)aView align:(TYLayoutAlign)anAlign margin:(CGBorder)aMargin {
    TYLayoutItem *item = [[TYLayoutItem alloc] initWithView:aView margin:aMargin align:anAlign];
    [member addObject:item];
    return self;
}

- (TYLayoutHelper *)addMemberWithView:(UIView *)aView {
    TYLayoutItem *item = [[TYLayoutItem alloc] initWithView:aView margin:CGBorderMake(0, 0, 0, 0) align:TYLayoutAlignLeftOrTop];
    [member addObject:item];
    return self;
}

- (NSInteger)getMemberCount {
    return [member count];
}

- (TYLayoutHelper *)clearMember {
    [member removeAllObjects];
    return self;
}

- (CGSize)getContentBounds {
    NSAssert(isSorted, @"Member not been sorted. call doReLayout first.");
    CGFloat width = 0;
    CGFloat height = 0;
    switch (orientation) {
        case TYLayoutOrientationHorizontal:
            for (TYLayoutItem *item in member) {
                width += [item getCalculatedWidth];
                if (height < item.getCalculatedHeight)
                    height = item.getCalculatedHeight + padding.top + padding.bottom;
            }
            width += padding.left + padding.right;
            break;
        case TYLayoutOrientationVertical:
            for (TYLayoutItem *item in member) {
                height += [item getCalculatedHeight];
                if (width < item.getCalculatedWidth)
                    width = item.getCalculatedWidth + padding.left + padding.right;
            }
            height += padding.top + padding.bottom;
            break;
    }
    return CGSizeMake(width, height);
}


- (TYLayoutHelper *)doReLayout {
    return [self doReLayoutWithAnimation:false duration:0];
}


- (TYLayoutHelper *)doReLayoutWithAnimation:(BOOL)useAnimation duration:(float)duration {
    CGRect rect = [container bounds];

    for (int i = 0; i < [member count]; i++) {
        TYLayoutItem *item = [member objectAtIndex:i];
        CGRect frame = item.view.frame;

        CGFloat newX = frame.origin.x;
        CGFloat newY = frame.origin.y;
        if (orientation == TYLayoutOrientationVertical) {
            switch (item.align) {
                case TYLayoutAlignLeftOrTop:
                    newX = rect.origin.x + padding.left + item.margin.left;
                    break;
                case TYLayoutAlignCenter:
                    newX = rect.origin.x + padding.left + (rect.size.width - padding.left - padding.right) / 2 - (item.getWidth + item.getHorizontalMargin) / 2;
                    break;
                case TYLayoutAlignRightOrTop:
                    newX = rect.origin.x + rect.size.width - padding.right - item.getHorizontalMargin - item.getWidth;
                    break;
            }
            if (i == 0) {
                newY = padding.top + item.margin.top;
            }
            else {
                TYLayoutItem *last = [member objectAtIndex:i - 1];
                CGRect rect = [[last view] frame];
                newY = rect.origin.y + rect.size.height + last.margin.bottom + item.margin.top;
            }
        } else {
            switch (item.align) {
                case TYLayoutAlignLeftOrTop:
                    newY = rect.origin.y + padding.top + item.margin.top;
                    break;
                case TYLayoutAlignCenter:
                    newY = rect.origin.y + padding.top + (rect.size.height - padding.top - padding.bottom) / 2 - (item.getHeight + item.getVerticalMargin) / 2;
                    break;
                case TYLayoutAlignRightOrTop:
                    newY = rect.origin.y + rect.size.height - padding.bottom - item.getVerticalMargin - item.getHeight;
                    break;
            }
            if (i == 0) {
                newX = padding.left + item.margin.left;
            }
            else {
                TYLayoutItem *last = [member objectAtIndex:i - 1];
                CGRect rect = [[last view] frame];
                newX = rect.origin.x + rect.size.width + last.margin.right + item.margin.left;
            }
        }
        frame.origin.x = newX;
        frame.origin.y = newY;
        if (useAnimation) {
            [UIView animateWithDuration:duration
                             animations:^{
                                 item.view.frame = frame;
                             }];
        } else {
            item.view.frame = frame;
        }
    }

    isSorted = YES;
    return self;
}

- (TYLayoutHelper *)randomizeMember {
    NSUInteger count = [member count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [member exchangeObjectAtIndex:i withObjectAtIndex:(NSUInteger) n];
    }
    isSorted = NO;
    return self;
}
@end
