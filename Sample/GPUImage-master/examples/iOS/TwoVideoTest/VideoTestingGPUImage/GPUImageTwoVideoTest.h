//
//  GPUImageTwoVideoTest.h
//  VideoTestingGPUImage
//
//  Created by Jake Gundersen on 10/3/12.
//  Copyright (c) 2012 Jake Gundersen. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface GPUImageTwoVideoTest : GPUImageTwoInputFilter {
    GLint amountUniform;
}

@property (nonatomic, readwrite) float amount;

@end
