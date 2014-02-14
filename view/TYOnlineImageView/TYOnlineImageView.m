//
//  TYOnlineImageView.m
//  Makko
//
//  Created by Tek yin Kwee on 5/16/12.
//  Copyright (c) 2012 nucleus302@gmail.com. All rights reserved.
//

#import "TYOnlineImageView.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"

@implementation TYOnlineImageView {
    BOOL isTouchMoved;
    int hAlign;
    int vAlign;
}
@synthesize touchActionDelegate = _touchActionDelegate;
@synthesize touchActionCallback = _touchActionCallback;
@synthesize urlPath = _urlPath;
@synthesize isResizeToFit = _isResizeToFit;
@synthesize originalFrame = _originalFrame;
@synthesize imageLoadedDelegate = _imageLoadedDelegate;
@synthesize imageLoadedCallback = _imageLoadedCallback;
@synthesize vAlign;
@synthesize hAlign;

static ASINetworkQueue *imageQueue;
static NSString *_placeholder;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self reInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self reInit];
    }
    return self;
}

- (void)reInit {
    [self setContentMode:UIViewContentModeScaleAspectFit];

    self.originalFrame = self.frame;
    self.isResizeToFit = NO;

    hAlign = H_ALIGN_RIGHT;
    vAlign = V_ALIGN_TOP;
}

- (void)resizeFrameWithImage:(UIImage *)image {
    const CGFloat fw = self.originalFrame.size.width;
    const CGFloat fh = self.originalFrame.size.height;
    const CGFloat iw = image.size.width;
    const CGFloat ih = image.size.height;
    bool isFitWidth = (fw / fh) < (iw / ih);
//    NSLog(@"\nFrame size: %f,%f \nimage size: %f,%f\nFit type: %@", fw, fh, iw, ih, isFitWidth ? @"width" : @"height");
    int shrinkMode;
    if (fh < ih || fw < iw)
        shrinkMode = -1;
    else // if (ih < fh && iw < fw)
        shrinkMode = 1;
//    else
//        shrinkMode = 0;
    CGFloat w;
    CGFloat h;
    if (shrinkMode != 0) {
        if (isFitWidth) { // FIT WIDTH
            w = fw;
            h = ih * fw / iw;
        } else { // FIT Height
            h = fh;
            w = iw * fh / ih;
        }
    } else {
        w = fw;
        h = fh;
    }
    //NSLog(@"Originial: %f, %f", fw, fh);
    //NSLog(@"sized    : %f, %f", w, h);

    CGFloat locX = self.originalFrame.origin.x;
    CGFloat locY = self.originalFrame.origin.y;

    switch (hAlign) {
        case H_ALIGN_LEFT: {
            locX = locX;
            break;
        }
        default:
        case H_ALIGN_MIDDLE: {
            locX = locX + (fw - w) / 2;
            break;
        }
        case H_ALIGN_RIGHT: {
            locX = locX + (fw - w);
            break;
        }
    }

    switch (vAlign) {
        case V_ALIGN_TOP: {
            locY = locY;
            break;
        }
        default:
        case V_ALIGN_MIDDLE: {
            locY = locY + (fh - h) / 2;
            break;
        }
        case V_ALIGN_BOTTOM: {
            locY = locY + (fh - h);
            break;
        }
    }

    [self setFrame:CGRectMake(locX, locY, w, h)];
}

- (void)loadNewImageFromUrl:(NSString *)imageUrlPath {
    NSString *cacheFilename = [self getFilePath:imageUrlPath];
#ifdef DEBUG
    NSError *error;
    if ([[NSFileManager defaultManager] removeItemAtPath:cacheFilename error:&error]) {
        NSLog(@"Old file deleted '%@'", [imageUrlPath lastPathComponent]);
    } else {
        NSLog(@"Failed to delete file '%@', error:%@", [imageUrlPath lastPathComponent], error.localizedDescription);
    }
#endif
    [self loadImageFromUrl:imageUrlPath];
}

- (void)loadImageFromUrl:(NSString *)imageUrlPath {
//    NSLog(@"Loading url: %@", imageUrlPath);
    self.urlPath = imageUrlPath;
    NSString *cacheFilename = [self getFilePath:imageUrlPath];
    BOOL isFileImage = ([[imageUrlPath lowercaseString] rangeOfString:@"png"].location != NSNotFound) ||
            ([[imageUrlPath lowercaseString] rangeOfString:@"jpg"].location != NSNotFound) ||
            ([[imageUrlPath lowercaseString] rangeOfString:@"jpeg"].location != NSNotFound) ||
            ([[imageUrlPath lowercaseString] rangeOfString:@"gif"].location != NSNotFound);
    if (isFileImage) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilename]) { // Image downloaded and exist, load the image
//            [self setCachePath:cacheFilename];
            UIImage *image = [UIImage imageWithContentsOfFile:cacheFilename];
            if (!image) {
                [self loadPlaceholderImage];
                NSLog(@"Invalid image file.");
                return;
            }

            // Optimizing image to fit the frame with 2x size (retina)
            image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake((int) [self frame].size.width * 2, (int) [self frame].size.height * 2) interpolationQuality:kCGInterpolationHigh];

            // resizing frame to fit
            if (self.isResizeToFit) {
                [self resizeFrameWithImage:image];
            } else {
                self.frame = self.originalFrame;
            }

            [self setImage:[image roundedCornerImage:5 borderSize:0] ];
            [self notifyToDelegate];
        }
        else { // Image is not downloaded, assign download task

            // load placeholder image
            [self loadPlaceholderImage];

            NSURL *url = [NSURL URLWithString:imageUrlPath];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setValidatesSecureCertificate:NO];
            __weak ASIHTTPRequest *wRequest = request;

            [request setCompletionBlock:^{
                UIImage *img = [UIImage imageWithData:wRequest.responseData];
                if (img) {
                    if (![[wRequest responseData] writeToFile:cacheFilename atomically:YES]) {
                        NSLog(@"Failed to write cache");
                    }
                    // make sure that this view still waiting specific image being downloaded, or ignore the placement
                    // this could be happened on UIListView while user scroll too fast
                    if ([wRequest.url.absoluteString isEqualToString:self.urlPath])
                        [self loadImageFromUrl:imageUrlPath];
                }
            }];
            [request setFailedBlock:^{
                [self loadPlaceholderImage];
            }];
            [self addQuickDownloadTask:request];
        }
    } else {
        [self loadPlaceholderImage];
    }
}

- (void)notifyToDelegate {
// notify to parent that image is already loaded
    if (_imageLoadedDelegate && [_imageLoadedDelegate respondsToSelector:_imageLoadedCallback]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_imageLoadedDelegate performSelector:_imageLoadedCallback withObject:self];
#pragma clang diagnostic pop
    }
}

+ (ASINetworkQueue *)imageQueue {
    if (!imageQueue || imageQueue == nil) {
        imageQueue = [ASINetworkQueue queue];
        [imageQueue setMaxConcurrentOperationCount:3];
    }
    return imageQueue;
}

- (void)addQuickDownloadTask:(ASIHTTPRequest *)task {
    [[TYOnlineImageView imageQueue] addOperation:task];
    [[TYOnlineImageView imageQueue] go];
}

- (NSString *)getFilePath:(NSString *)imageUrlPath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cacheDirectory = [documentsDirectory stringByAppendingPathComponent:@"cache"];
    [self createFolder:cacheDirectory];
    NSString *filename = [[[NSURL URLWithString:imageUrlPath] pathComponents] lastObject];
    NSString *cacheFilename = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.%@", [imageUrlPath hash], [filename pathExtension]]];
    return cacheFilename;
}

- (void)setTouchActionWithDelegate:(id)delegate selector:(SEL)callback {
    [self setUserInteractionEnabled:YES];
    [self setTouchActionDelegate:delegate];
    [self setTouchActionCallback:callback];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!isTouchMoved) {
        if (_touchActionDelegate && [_touchActionDelegate respondsToSelector:_touchActionCallback]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_touchActionDelegate performSelector:_touchActionCallback withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    isTouchMoved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    isTouchMoved = YES;
}


- (void)setImageLoadedCallback:(SEL)selector delegate:(id)delegate {
    [self setImageLoadedDelegate:delegate];
    [self setImageLoadedCallback:selector];
}

- (void)tryReloadImage {
    [self loadImageFromUrl:self.urlPath];
}

- (void)loadPlaceholderImage {
    [self setImage:[UIImage imageNamed:_placeholder]];
}

+ (void)setPlaceholderImage:(NSString *)placeholder {
    _placeholder = placeholder;
}

- (BOOL)createFolder:(NSString *)folderPath {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Error while creating folder: %@", [error localizedDescription]);
            return NO;
        }
    }
    return YES;
}
@end
