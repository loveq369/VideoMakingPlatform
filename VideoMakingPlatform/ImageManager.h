//
//  ImageManager.h
//  VideoMakingPlatform
//
//  Created by chicpark7 on 2014. 3. 5..
//  Copyright (c) 2014년 Chicpark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject

+ (UIImage *)makeFrameImage:(UIImage *)image maxSize:(CGSize)maxSize;
+ (CGSize)getFitSizeWithOrientSize:(CGSize)originSize maxSize:(CGSize)maxSize;
+ (UIImage *)makeMultipleFrameImage:(NSArray*)images maxSize:(CGSize)maxSize;
+ (UIImage*)makeScene1WithSize:(CGSize)size;
+ (UIImage*)makeScene2WithSize:(CGSize)size;

@end
