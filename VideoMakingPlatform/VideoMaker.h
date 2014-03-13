//
//  VideoMaker.h
//  VideoMakingPlatform
//
//  Created by chicpark7 on 2014. 3. 6..
//  Copyright (c) 2014년 Chicpark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface VideoMaker : NSObject

+ (NSURL*)createVideoWithImage:(UIImage*)image;

@end
