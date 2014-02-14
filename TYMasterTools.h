//
// Created by Tek Yin Kwee on 2/12/14.
// Copyright (c) 2014 laac. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TYMasterTools : NSObject
+ (NSUInteger)getImageSizeFromImage:(UIImage *)image;

+ (NSUInteger)getImageSizeFromPath:(NSString *)imagePath;
@end