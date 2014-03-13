//
//  ViewController.m
//  VideoTestingGPUImage
//
//  Created by Jake Gundersen on 10/2/12.
//  Copyright (c) 2012 Jake Gundersen. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"


#import <AssetsLibrary/AssetsLibrary.h>


@interface ViewController () {
   
    GPUImageFilter *filter0;
    
    GPUImageMovieWriter *mw;
    
    BOOL isRecording;
}
@property (strong, nonatomic) IBOutlet GPUImageView *view0;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"FRNK" withExtension:@"mp4"];
    
    GPUImageMovie *gpuIM = [[GPUImageMovie alloc] initWithURL:url];
    
    gpuIM.playAtActualSpeed = YES;
    
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"NAN" withExtension:@"mov"];
    GPUImageMovie *movie2 = [[GPUImageMovie alloc] initWithURL:url2];
    
    movie2.playAtActualSpeed = YES;
    
    filter0 = [[GPUImageColorDodgeBlendFilter alloc] init];
    
    [gpuIM addTarget:filter0];
    [movie2 addTarget:filter0];
    
    [filter0 addTarget:_view0];
    
    [gpuIM startProcessing];
     [movie2 startProcessing];
    
    isRecording = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isRecording) {
        [self stopRecording];
        isRecording = NO;
    } else {
        NSLog(@"Start recording");
        [self recordVideo];
        isRecording = YES;
    }
}

-(void)recordVideo {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"file.mov"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
    
    mw = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(640, 480)];
    [filter0 addTarget:mw];
    [mw startRecording];
}

-(void)stopRecording {
    [mw finishRecording];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"file.mov"];
    
    
    
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    [al writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error);
        } else {
            NSLog(@"Success");
            //NSFileManager *fm = [NSFileManager defaultManager];
            //[fm removeItemAtPath:path error:&error];
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
