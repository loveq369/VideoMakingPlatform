//
//  GPUImageTwoVideoTest.m
//  VideoTestingGPUImage
//
//  Created by Jake Gundersen on 10/3/12.
//  Copyright (c) 2012 Jake Gundersen. All rights reserved.
//

#import "GPUImageTwoVideoTest.h"

NSString *const kGPUImageTwoVideoFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float amount;
 
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     vec4 color1 = texture2D(inputImageTexture, textureCoordinate);
     vec4 color2 = texture2D(inputImageTexture2, textureCoordinate);
     
     float lum = dot(color2.rgb, luminanceWeighting);
     float lum2 = dot(color1.rgb, luminanceWeighting);
     
     vec3 greyScaleColor = vec3(lum2);
     
     
     vec3 color;
     if (lum > amount) {
         color = color1.rgb;
     } else {
         color = color2.rgb;
     }
     
     
     gl_FragColor = vec4(color.rgb, 1.0);
     
 }
 );


@implementation GPUImageTwoVideoTest

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageTwoVideoFragmentShaderString]))
    {
		return nil;
    }
    
    amountUniform = [filterProgram uniformIndex:@"amount"];
    
    [self setAmount:0.5];
    
    return self;
}

-(void)setAmount:(float)amount {
    _amount = amount;
    [self setFloat:_amount forUniformName:@"amount"];
}

@end
