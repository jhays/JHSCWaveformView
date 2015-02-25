//
//  SCWaveformView.m
//  SCWaveformView
//
//  Created by Simon CORSIN on 24/01/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import "SCWaveformView.h"
#import "SCWaveformCache.h"

#define absX(x) (x < 0 ? 0 - x : x)
#define minMaxX(x, mn, mx) (x <= mn ? mn : (x >= mx ? mx : x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude) / 32767.0))

@interface SCWaveformView() {
    UIImageView *_normalImageView;
    UIImageView *_progressImageView;
    UIView *_cropNormalView;
    UIView *_cropProgressView;
    BOOL _normalColorDirty;
    BOOL _progressColorDirty;
    SCWaveformCache *_cache;
}

@end

@implementation SCWaveformView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _normalImageView = [[UIImageView alloc] init];
    _progressImageView = [[UIImageView alloc] init];
    _cropNormalView = [[UIView alloc] init];
    _cropProgressView = [[UIView alloc] init];
    
    _cropNormalView.clipsToBounds = YES;
    _cropProgressView.clipsToBounds = YES;
    
    [_cropNormalView addSubview:_normalImageView];
    [_cropProgressView addSubview:_progressImageView];
    
    [self addSubview:_cropNormalView];
    [self addSubview:_cropProgressView];
    
    self.normalColor = [UIColor blueColor];
    self.progressColor = [UIColor redColor];
    _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    
    _normalColorDirty = NO;
    _progressColorDirty = NO;
    _cache = [SCWaveformCache new];
}

void SCRenderPixelWaveformInContext(CGContextRef context, float halfGraphHeight, float sample, float x) {
    float pixelHeight = halfGraphHeight * (1 - sample / noiseFloor);
    
    if (pixelHeight < 0) {
        pixelHeight = 0;
    }
    
    CGContextMoveToPoint(context, x, halfGraphHeight - pixelHeight);
    CGContextAddLineToPoint(context, x, halfGraphHeight + pixelHeight);
    CGContextStrokePath(context);
}

- (BOOL)renderWaveformInContext:(CGContextRef)context size:(CGSize)size {
    CGFloat pixelRatio = size.width / CGContextConvertSizeToUserSpace(context, size).width;
    
    float halfGraphHeight = (size.height / 2 * pixelRatio);
    
    NSError *error = nil;
    
    CGContextSetAllowsAntialiasing(context, _antialiasingEnabled);
    CGContextSetLineWidth(context, 1.0);
    
    CGContextSetStrokeColorWithColor(context, _normalColor.CGColor);
    CGContextSetFillColorWithColor(context, _normalColor.CGColor);
    __block BOOL reachedProgressPoint = NO;
    
    return [_cache readTimeRange:_timeRange width:size.width * pixelRatio error:&error handler:^(CGFloat x, float sample, CMTime time) {
        if (!reachedProgressPoint && CMTIME_COMPARE_INLINE(time, >=, self.progressTime)) {
            reachedProgressPoint = YES;
            CGContextSetStrokeColorWithColor(context, _progressColor.CGColor);
            CGContextSetFillColorWithColor(context, _progressColor.CGColor);
        }
        
        SCRenderPixelWaveformInContext(context, halfGraphHeight / pixelRatio, sample, x / pixelRatio);
    }];
}

- (UIImage *)generateWaveformImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 1);
    
    [self renderWaveformInContext:UIGraphicsGetCurrentContext() size:size];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)recolorizeImage:(UIImage*)image withColor:(UIColor*)color {
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, imageRect, image.CGImage);
    [color set];
    UIRectFillUsingBlendMode(imageRect, kCGBlendModeSourceAtop);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)generateWaveforms {
    CGRect rect = self.bounds;
    
    if (self.generatedNormalImage == nil && self.asset) {
        self.generatedNormalImage = [self generateWaveformImageWithSize:CGSizeMake(rect.size.width * [UIScreen mainScreen].scale , rect.size.height * [UIScreen mainScreen].scale)];
        _normalColorDirty = NO;
    }
    
    if (self.generatedNormalImage != nil) {
        if (_normalColorDirty) {
            self.generatedNormalImage = [SCWaveformView recolorizeImage:self.generatedNormalImage withColor:self.normalColor];
            _normalColorDirty = NO;
        }
        
        if (_progressColorDirty || self.generatedProgressImage == nil) {
            self.generatedProgressImage = [SCWaveformView recolorizeImage:self.generatedNormalImage withColor:self.progressColor];
            _progressColorDirty = NO;
        }
    }
}

- (void)drawRect:(CGRect)rect {
//    [self generateWaveforms];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
    [self renderWaveformInContext:ctx size:rect.size];
    
    [super drawRect:rect];
}

- (void)applyProgressToSubviews {
    CGRect bs = self.bounds;
    
    CGFloat progress = 0;
    
    if (CMTIME_IS_VALID(_progressTime) && CMTIME_IS_VALID(self.asset.duration)) {
        progress = CMTimeGetSeconds(CMTimeSubtract(_progressTime, _timeRange.start)) / CMTimeGetSeconds(self.asset.duration);
    }
    
    if (progress < 0) {
        progress = 0;
    } else if (progress > 1) {
        progress = 1;
    }
    
    CGFloat progressWidth = bs.size.width * progress;
    _cropProgressView.frame = CGRectMake(0, 0, progressWidth, bs.size.height);
    _cropNormalView.frame = CGRectMake(progressWidth, 0, bs.size.width - progressWidth, bs.size.height);
    _normalImageView.frame = CGRectMake(-progressWidth, 0, bs.size.width, bs.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bs = self.bounds;
    _normalImageView.frame = bs;
    _progressImageView.frame = bs;
    
    // If the size is now bigger than the generated images
    if (bs.size.width > self.generatedNormalImage.size.width) {
        self.generatedNormalImage = nil;
        self.generatedProgressImage = nil;
    }
    
    [self applyProgressToSubviews];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    _normalColorDirty = YES;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    _progressColorDirty = YES;
    [self setNeedsDisplay];
}

- (AVAsset *)asset {
    return _cache.asset;
}

- (void)setAsset:(AVAsset *)asset {
    [self willChangeValueForKey:@"asset"];
    
    _cache.asset = asset;
    self.generatedProgressImage = nil;
    self.generatedNormalImage = nil;
    [self setNeedsDisplay];
    
    [self didChangeValueForKey:@"asset"];
}

- (void)setProgressTime:(CMTime)progressTime {
    _progressTime = progressTime;
    [self applyProgressToSubviews];
}

- (UIImage*)generatedNormalImage {
    return _normalImageView.image;
}

- (void)setGeneratedNormalImage:(UIImage *)generatedNormalImage {
    _normalImageView.image = generatedNormalImage;
}

- (UIImage*)generatedProgressImage {
    return _progressImageView.image;
}

- (void)setGeneratedProgressImage:(UIImage *)generatedProgressImage {
    _progressImageView.image = generatedProgressImage;
}

- (void)setAntialiasingEnabled:(BOOL)antialiasingEnabled {
    if (_antialiasingEnabled != antialiasingEnabled) {
        _antialiasingEnabled = antialiasingEnabled;
        self.generatedProgressImage = nil;
        self.generatedNormalImage = nil;
        [self setNeedsDisplay];        
    }
}

- (void)setTimeRange:(CMTimeRange)timeRange {
    [self willChangeValueForKey:@"timeRange"];
    
    _timeRange = timeRange;
    self.generatedProgressImage = nil;
    self.generatedNormalImage = nil;
    [self setNeedsDisplay];
    
    [self didChangeValueForKey:@"timeRange"];
}

@end