//
//  TYOnlineImageView.h
//  Makko
//
//  Created by Tek yin Kwee on 5/16/12.
//  Copyright (c) 2012 nucleus302@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASINetworkQueue;

#define H_ALIGN_LEFT 10
#define H_ALIGN_MIDDLE 11
#define H_ALIGN_RIGHT 12

#define V_ALIGN_TOP 20
#define V_ALIGN_MIDDLE 21
#define V_ALIGN_BOTTOM 22

@interface TYOnlineImageView : UIImageView

@property(nonatomic, strong) id touchActionDelegate;

@property(nonatomic, assign) SEL touchActionCallback;

@property(nonatomic, assign) CGRect originalFrame;

@property(nonatomic, assign) BOOL isResizeToFit;

@property(nonatomic, copy) NSString *urlPath;

@property(nonatomic, strong) id imageLoadedDelegate;

@property(nonatomic, assign) SEL imageLoadedCallback;

@property(nonatomic) int vAlign;

@property(nonatomic) int hAlign;

- (void)reInit;

+ (void)setPlaceholderImage:(NSString *)placeholder;

- (void)loadNewImageFromUrl:(NSString *)imageUrlPath;

- (void)loadImageFromUrl:(NSString *)imageUrlPath;

- (void)setTouchActionWithDelegate:(id)delegate selector:(SEL)callback;

- (void)setImageLoadedCallback:(SEL)selector delegate:(id)delegate;

- (void)tryReloadImage;

- (void)loadPlaceholderImage;
@end
