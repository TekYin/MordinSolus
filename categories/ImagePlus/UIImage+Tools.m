//
// Created by Tek Yin Kwee on 2/12/14.
// Copyright (c) 2014 laac. All rights reserved.
//

#import "UIImage+Tools.h"


@implementation UIImage (Tools)

- (NSUInteger)getImageSize {
    NSData *imgData = UIImageJPEGRepresentation(self, 1.0);
    return [imgData length];
}
@end