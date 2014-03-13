//
//  ImageManager.m
//  VideoMakingPlatform
//
//  Created by chicpark7 on 2014. 3. 5..
//  Copyright (c) 2014년 Chicpark. All rights reserved.
//

#import "ImageManager.h"

#define RADIAN(x) x * (3.14159 / 180 )

@implementation ImageManager

+ (UIImage*)makeScene1WithSize:(CGSize)size
{
	UIImage* retImg = nil;
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(context, 255.0f/255.0f, 235.0f/255.0f, 150.0f/255.0f, 1.0f);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	
	NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
	textStyle.lineBreakMode = NSLineBreakByWordWrapping;
	textStyle.alignment = NSTextAlignmentCenter;
	
	UIFont *textFont = [UIFont fontWithName:@"Baskerville-Italic" size:30];
	[@"You are\n      my angel" drawAtPoint:CGPointMake(250, 50) withAttributes:@{NSFontAttributeName:textFont,
																				  NSParagraphStyleAttributeName:textStyle}];
	
	UIImage* img1 = [self makeFrameImage:[UIImage imageNamed:@"1.JPG"] maxSize:CGSizeMake(170, 170)];
	
	CGContextRotateCTM (context, RADIAN(350));
	
	[img1 drawInRect:CGRectMake(50, 50, img1.size.width, img1.size.height)];
	
	UIImage* img2 = [self makeFrameImage:[UIImage imageNamed:@"7.JPG"] maxSize:CGSizeMake(170, 170)];
	
	CGContextRotateCTM (context, RADIAN(15));
	
	[img2 drawInRect:CGRectMake(300, 100, img2.size.width, img2.size.height)];
	
	UIImage* img3 = [self makeFrameImage:[UIImage imageNamed:@"3.JPG"] maxSize:CGSizeMake(170, 170)];
	
	CGContextRotateCTM (context, RADIAN(5));
	
	[img3 drawInRect:CGRectMake(100, 140, img3.size.width, img3.size.height)];
	
	retImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return retImg;
}

+ (UIImage*)makeScene2WithSize:(CGSize)size
{
	UIImage* retImg = nil;
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(context, 255.0f/255.0f, 235.0f/255.0f, 150.0f/255.0f, 1.0f);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	
	NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
	textStyle.lineBreakMode = NSLineBreakByWordWrapping;
	textStyle.alignment = NSTextAlignmentCenter;
	
	UIFont *textFont = [UIFont fontWithName:@"Baskerville-Italic" size:30];
	[@"Memory..." drawAtPoint:CGPointMake(60, 50) withAttributes:@{NSFontAttributeName:textFont,
																		   NSParagraphStyleAttributeName:textStyle}];
	
	UIImage* img1 = [self makeFrameImage:[UIImage imageNamed:@"5.JPG"] maxSize:CGSizeMake(170, 170)];

	CGContextRotateCTM (context, RADIAN(10));

	[img1 drawInRect:CGRectMake(270, -30, img1.size.width, img1.size.height)];

	UIImage* img2 = [self makeFrameImage:[UIImage imageNamed:@"7.JPG"] maxSize:CGSizeMake(170, 170)];
	
	UIImage* img3 = [self makeFrameImage:[UIImage imageNamed:@"4.JPG"] maxSize:CGSizeMake(170, 170)];
	
	CGContextRotateCTM (context, RADIAN(-15));
	
	[img3 drawInRect:CGRectMake(270, 200, img3.size.width, img3.size.height)];
	
	CGContextRotateCTM (context, RADIAN(-10));
	
	[img2 drawInRect:CGRectMake(20, 150, img2.size.width, img2.size.height)];
	

	
	retImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return retImg;
}

+ (UIImage *)makeFrameImage:(UIImage *)image maxSize:(CGSize)maxSize
{
	CGSize imgSize = [self getFitSizeWithOrientSize:image.size maxSize:maxSize];
	
	UIGraphicsBeginImageContext(imgSize);
	int frameOffset = 0;
	NSString* frameName = nil;
	if (image.size.width < image.size.height) {
		frameName = @"frame2.png";
		frameOffset = imgSize.width / 8.0f;
	}
	else {
		static int i = 0;
		if (i % 2) {
			frameName = @"frame3.png";
			frameOffset = imgSize.width / 16.0f;
		}
		else {
			frameName = @"frame7.png";
			frameOffset = imgSize.width / 8.0f;
		}

		i++;
	}
	
	[image drawInRect:CGRectMake(frameOffset, frameOffset, imgSize.width - frameOffset * 2, imgSize.height - frameOffset * 2)];
	[[UIImage imageNamed:frameName] drawInRect:CGRectMake(0.0, 0.0, imgSize.width, imgSize.height)];
	UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

+ (UIImage *)makeMultipleFrameImage:(NSArray*)images maxSize:(CGSize)maxSize
{
	UIImage* frameImage = [UIImage imageNamed:@"frame4.png"];
	
	CGSize imgSize = [self getFitSizeWithOrientSize:frameImage.size maxSize:maxSize];
	UIGraphicsBeginImageContext(imgSize);
	
	CGRect rects[3];
	rects[0] = CGRectMake(imgSize.width / 20, imgSize.height / 15, imgSize.width / 2.5, imgSize.height / 2.5);
	rects[1] = CGRectMake(imgSize.width / 1.8, imgSize.height / 15, imgSize.width / 2.5, imgSize.height / 2.5);
	rects[2] = CGRectMake(imgSize.width / 4.2, imgSize.height / 1.9, imgSize.width / 2.5, imgSize.height / 2.5);
	
	for (int i = 0; i < images.count; i++) {
		UIImage* image = (UIImage*)[images objectAtIndex:i];
		
		[image drawInRect:rects[i]];
	}
	[frameImage drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
	UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return newImage;
}

+ (CGSize)getFitSizeWithOrientSize:(CGSize)originSize maxSize:(CGSize)maxSize
{
	CGSize retSize = CGSizeZero;
	
	if (originSize.width > originSize.height) {
		retSize.width = maxSize.width;
		retSize.height = originSize.height * maxSize.width / originSize.width;
	}
	else {
		retSize.height = maxSize.height;
		retSize.width = originSize.width * maxSize.height / originSize.height;
	}
	
	return retSize;
}

@end
