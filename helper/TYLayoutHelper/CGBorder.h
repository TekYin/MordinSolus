//
//  Created by nucleus302 on 4/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

struct CGBorder {
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
};
typedef struct CGBorder CGBorder;

CG_INLINE CGBorder
CGBorderMake(CGFloat left, CGFloat right, CGFloat top, CGFloat bottom) {
    CGBorder rect;
    rect.left = left;
    rect.right = right;
    rect.top = top;
    rect.bottom = bottom;
    return rect;
}