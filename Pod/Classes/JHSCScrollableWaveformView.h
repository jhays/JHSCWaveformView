//
//  SCScrollableWaveformView.h
//  SCWaveformView
//
//  Created by Simon CORSIN on 24/02/15.
//  Copyright (c) 2015 Simon CORSIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHSCWaveformView.h"

@class JHSCWaveformView;

@interface JHSCScrollableWaveformView : UIScrollView

/**
 The managed waveformView.
 */
@property (readonly, nonatomic) JHSCWaveformView *waveformView;

@end
