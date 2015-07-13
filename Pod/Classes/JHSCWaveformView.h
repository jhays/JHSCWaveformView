//
//  SCWaveformView.h
//  SCWaveformView
//
//  Created by Simon CORSIN on 24/01/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "JHSCWaveformCache.h"
#import "JHSCScrollableWaveformView.h" // For convenience

@interface JHSCWaveformView : UIView

/**
 The asset to render.
 */
@property (strong, nonatomic) AVAsset *asset;

/**
 Bool to determine if waveform layers should have rounded edges
 NOTE: This only works when precision/lineWidthRatio result in lines with a width > 2
 */

@property (assign, nonatomic) BOOL roundedCorners;

/**
 The color that will be used for every bands that are after
 the progressTime.
 */
@property (strong, nonatomic) UIColor *normalColor;

/**
 Array of colors that will be used for every bands that are after
 the progressTime. If set (array count > 0), gradientNormalColor will override normalColor
 */
@property (strong, nonatomic) NSArray *gradientNormalColors;

/**
 The color that will be used for every bands that are before
 the progressTime.
 */
@property (strong, nonatomic) UIColor *progressColor;

/**
 Array of colors that will be used for every bands that are before
 the progressTime. If set (array count > 0), gradientProgressColor will override progressColor
 */
@property (strong, nonatomic) NSArray *gradientProgressColors;

/**
 The progress time. Each bands that are before this time will be
 displayed using the progressColor.
 */
@property (assign, nonatomic) CMTime progressTime;

/**
 The precision ratio. This defines the number of pixels
 used per band. Using a value of 0.5 means that 2 pixels
 will be used per band.
 
 Default is 1.
 */
@property (assign, nonatomic) CGFloat precision;

/**
 A ratio applied on the width of each waveform band.
 Default is 1.
 */
@property (assign, nonatomic) CGFloat lineWidthRatio;

/**
 The padding in point between each channels.
 Default is 0.
 */
@property (assign, nonatomic) CGFloat channelsPadding;

/**
 The timeRange to use for rendering the waveform.
 If you want to render a portion of the waveform, you can
 reduce the duration.
 
 Default is kCMTimeZero, kCMTimePositiveInfinity
 */
@property (assign, nonatomic) CMTimeRange timeRange;

/**
 The first audio channel index to render.
 Default is 0
 */
@property (assign, nonatomic) NSUInteger channelStartIndex;

/**
 The last audio channel index to render. You can set that to 1
 to render a stereo waveform.
 Default is 0.
 */
@property (assign, nonatomic) NSUInteger channelEndIndex;

/**
 The underyling waveform size for rendering the complete waveform.
 */
@property (readonly, nonatomic) CGSize waveformSize;

/**
 The asset duration based on what was actually read from the asset.
 */
@property (readonly, nonatomic) CMTime actualAssetDuration;

@end
