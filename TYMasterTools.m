//
// Created by Tek Yin Kwee on 2/12/14.
// Copyright (c) 2014 laac. All rights reserved.
//

#import "TYMasterTools.h"


@implementation TYMasterTools {

}
+ (NSUInteger)getImageSizeFromImage:(UIImage *)image {
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    return [imgData length];
}

+ (NSUInteger)getImageSizeFromPath:(NSString *)imagePath {
    return [TYMasterTools getImageSizeFromImage:[UIImage imageNamed:imagePath]];
}
@end