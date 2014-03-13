//
//  ViewController.m
//  VideoTestingGPUImage
//
//  Created by Jake Gundersen on 10/2/12.
//  Copyright (c) 2012 Jake Gundersen. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "ImageManager.h"
#import "VideoMaker.h"
#import "SimpleEditor.h"

#import <AssetsLibrary/AssetsLibrary.h>

#define TRANSITION_LEEWAY_MULTIPLIER 2.01

@interface ViewController () {
	
    GPUImageFilter *filter0;
    GPUImageMovieWriter *mw;
	SimpleEditor* _editor;

    float _transitionDuration;
	
    BOOL isRecording;
	BOOL _exporting;
	BOOL _showSavedVideoToAssestsLibrary;
	BOOL _transitionsEnabled;

}
@property (strong, nonatomic) IBOutlet GPUImageView *view0;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_transitionDuration = 1.0;
	_editor = [[SimpleEditor alloc] init];
	
	AVAsset* asset1 = [AVAsset assetWithURL:[VideoMaker createVideoWithImage:[ImageManager makeScene1WithSize:CGSizeMake(480, 320)]]];
	AVAsset* asset2 = [AVAsset assetWithURL:[VideoMaker createVideoWithImage:[ImageManager makeScene2WithSize:CGSizeMake(480, 320)]]];
	NSArray* imgArray1 = [NSArray arrayWithObjects:
						 [UIImage imageNamed:@"1.JPG"],
						 [UIImage imageNamed:@"2.JPG"],
						 [UIImage imageNamed:@"3.JPG"], nil];
	UIImage* img1 = [ImageManager makeMultipleFrameImage:imgArray1 maxSize:CGSizeMake(480, 320)];
	
	AVURLAsset* asset3 = [AVAsset assetWithURL:[VideoMaker createVideoWithImage:img1]];

	AVAsset* asset4 = [AVAsset assetWithURL:[VideoMaker createVideoWithImage:[ImageManager makeScene1WithSize:CGSizeMake(480, 320)]]];
	AVAsset* asset5 = [AVAsset assetWithURL:[VideoMaker createVideoWithImage:[ImageManager makeScene2WithSize:CGSizeMake(480, 320)]]];
	NSArray* imgArray2 = [NSArray arrayWithObjects:
						 [UIImage imageNamed:@"1.JPG"],
						 [UIImage imageNamed:@"2.JPG"],
						 [UIImage imageNamed:@"3.JPG"], nil];
	UIImage* img2 = [ImageManager makeMultipleFrameImage:imgArray2 maxSize:CGSizeMake(480, 320)];
	
	AVURLAsset* asset6 = [AVAsset assetWithURL:[VideoMaker createVideoWithImage:img2]];

	
	_editor.clips = [NSArray arrayWithObjects:asset1, asset2, asset3, asset4, asset5, asset6, nil];

	NSMutableArray* array = [NSMutableArray arrayWithCapacity:6];
	
	for (AVURLAsset* asset in _editor.clips) {
		CMTimeRange timeRange = kCMTimeRangeZero;
		timeRange.duration = asset.duration;
		NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
		[array addObject:timeRangeValue];
	}
	_editor.clipTimeRanges = [NSArray arrayWithArray:array];
	
}

- (void)beginExport
{
	[self synchronizeWithEditor];
	_exporting = YES;
	_showSavedVideoToAssestsLibrary = NO;

	[_editor buildCompositionObjectsForPlayback:NO];
	AVAssetExportSession *session = [_editor assetExportSessionWithPreset:AVAssetExportPresetHighestQuality];
	
	NSString *filePath = nil;
	NSUInteger count = 0;
	do {
		filePath = NSTemporaryDirectory();
		
		NSString *numberString = count > 0 ? [NSString stringWithFormat:@"-%lu", (unsigned long)count] : @"";
		filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"Output-%@.mov", numberString]];
		count++;
	} while([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
	
	session.outputURL = [NSURL fileURLWithPath:filePath];
	session.outputFileType = AVFileTypeQuickTimeMovie;
	
	[session exportAsynchronouslyWithCompletionHandler:^
	 {
		 dispatch_async(dispatch_get_main_queue(), ^{
			 [self exportDidFinish:session];
		 });
	 }];
	
}

- (void)synchronizeWithEditor
{
	_editor.commentary = nil;
//	_editor.commentary = _commentaryEnabled ? self.commentary : nil;
//	CMTime commentaryStartTime = (_commentaryEnabled && self.commentary) ? CMTimeMakeWithSeconds(_commentaryStartTime, 600) : kCMTimeInvalid;
//	_editor.commentaryStartTime = commentaryStartTime;
	
	// Transitions
	CMTime transitionDuration = CMTimeMakeWithSeconds(_transitionDuration, 600);
	_editor.transitionDuration = transitionDuration;
	_editor.transitionType = (SimpleEditorTransitionType*)malloc(sizeof(int) * 3);
	
	_editor.transitionType[0] = SimpleEditorTransitionTypePush;
	_editor.transitionType[1] = SimpleEditorTransitionTypeCrossFade;
//	_editor.transitionType[2] = SimpleEditorTransitionTypeCrossFade;
	// Titles
	_editor.titleText = @" ";
}

- (void)constrainClipTimeRangesBasedOnTransitionDuration
{
	NSMutableArray* timeRanges = [NSMutableArray arrayWithArray:_editor.clipTimeRanges];
	if (_transitionsEnabled) {
		// Constrain self.clipTimeRanges, and tell the clip sections to reload if they are visible.
		NSUInteger idx;
		for (idx = 0; idx < [timeRanges count]; idx++) {
			NSValue *timeRangeValue = [timeRanges objectAtIndex:idx];
			if (! [timeRangeValue isKindOfClass:[NSNull class]]) {
				CMTimeRange timeRange = [timeRangeValue CMTimeRangeValue];
				CMTime minDuration = CMTimeMakeWithSeconds(TRANSITION_LEEWAY_MULTIPLIER*_transitionDuration, 600);
				if ( CMTIME_COMPARE_INLINE(timeRange.duration, <, minDuration) ) {
					timeRange.duration = minDuration;
					CMTime assetDuration = [(AVURLAsset*)[_editor.clips objectAtIndex:idx] duration];
					if ( CMTIME_COMPARE_INLINE(timeRange.duration, >, assetDuration) ) {
						CMTime differenceToMakeUp = CMTimeSubtract(timeRange.duration, assetDuration);
						timeRange.start = CMTimeSubtract(timeRange.start, differenceToMakeUp);
						if ( CMTIME_COMPARE_INLINE(timeRange.start, <, kCMTimeZero) ) {
							timeRange.start = kCMTimeZero;
							timeRange.duration = assetDuration;
						}
					}
				}
				[timeRanges replaceObjectAtIndex:idx withObject:[NSValue valueWithCMTimeRange:timeRange]];
			}
		}
	}
	_editor.clipTimeRanges = [NSArray arrayWithArray:timeRanges];
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
	NSURL *outputURL = session.outputURL;
	
	_exporting = NO;
	
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
		[library writeVideoAtPathToSavedPhotosAlbum:outputURL
									completionBlock:^(NSURL *assetURL, NSError *error){
										dispatch_async(dispatch_get_main_queue(), ^{
											if (error) {
												NSLog(@"writeVideoToAssestsLibrary failed: %@", error);
												UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																									message:[error localizedRecoverySuggestion]
																								   delegate:nil
																						  cancelButtonTitle:@"OK"
																						  otherButtonTitles:nil];
												[alertView show];
												[alertView release];
											}
											else {
												_showSavedVideoToAssestsLibrary = YES;
											}
											NSLog(@"Done");
										});
										
									}];
	}
	[library release];
}


- (void)makeMovie {
	[self beginExport];
//	[_editor buildCompositionObjectsForPlayback:NO];
}

- (void)temp1
{
	UIImage* img1 = [ImageManager makeScene2WithSize:CGSizeMake(480, 320)];
	UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img1.size.width, img1.size.height)];
	[imgView setImage:img1];
	[imgView setBackgroundColor:[UIColor blackColor]];
	[self.view addSubview:imgView];
	[self.view setBackgroundColor:[UIColor greenColor]];

//	UIImage* img1 = [ImageManager makeFrameImage:[UIImage imageNamed:@"1.JPG"] maxSize:CGSizeMake(160, 160) rotation:0.3];
//	UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, img1.size.width, img1.size.height)];
//	[imgView setImage:img1];
//	[imgView setBackgroundColor:[UIColor blackColor]];
//	[self.view addSubview:imgView];
//	[self.view setBackgroundColor:[UIColor greenColor]];
//	
//	NSString  *pngPath1 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test1.png"];
//	
//	[UIImagePNGRepresentation(img1) writeToFile:pngPath1 atomically:YES];
//	
//	UIImage* img2 = [ImageManager makeFrameImage:[UIImage imageNamed:@"7.JPG"] maxSize:CGSizeMake(160, 160) rotation:0];
//	UIImageView* imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, img2.size.width, img2.size.height)];
//	[imgView2 setImage:img2];
//	[imgView2 setBackgroundColor:[UIColor brownColor]];
//	[self.view addSubview:imgView2];
//	
//	
//	NSString  *pngPath2 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test2.png"];
//	
//	[UIImagePNGRepresentation(img2) writeToFile:pngPath2 atomically:YES];
//	
//	NSArray* imgArray = [NSArray arrayWithObjects:
//						 [UIImage imageNamed:@"1.JPG"],
//						 [UIImage imageNamed:@"2.JPG"],
//						 [UIImage imageNamed:@"3.JPG"], nil];
//	UIImage* img3 = [ImageManager makeMultipleFrameImage:imgArray maxSize:CGSizeMake(320, 320)];
//	UIImageView* imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(200, 20, img3.size.width, img3.size.height)];
//	[imgView3 setImage:img3];
//	[imgView3 setBackgroundColor:[UIColor redColor]];
//	[self.view addSubview:imgView3];
//	
//	
//	NSString  *pngPath3 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test2.png"];
//	
//	[UIImagePNGRepresentation(img3) writeToFile:pngPath3 atomically:YES];
}

- (void)startProcessing1
{
	NSString* document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	CGRect videoFrame = CGRectMake(0, 0, 480, 320);
	NSString *path = [document stringByAppendingPathComponent:@"Movie.m4v"];
	unlink([path UTF8String]);
    NSURL *targetURL = [NSURL fileURLWithPath:path];

	filter0 = [[GPUImageBrightnessFilter alloc] init];
	[((GPUImageBrightnessFilter*)filter0) setBrightness:0.1];
	
	mw = [[GPUImageMovieWriter alloc] initWithMovieURL:targetURL size:videoFrame.size];
	
//	[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(test) userInfo:Nil repeats:YES];
	
	_view0 = [[GPUImageView alloc] initWithFrame:videoFrame];
	[self.view addSubview:_view0];

    [filter0 addTarget:_view0];
	[filter0 addTarget:mw];
	
	GPUImagePicture* picture = [[GPUImagePicture alloc] initWithImage:[ImageManager makeScene1WithSize:CGSizeMake(480, 320)]];
	[picture processImage];
	[picture addTarget:filter0];

	[mw startRecording];
	
    [mw setCompletionBlock:^{
		[filter0 removeTarget:mw];
        [self stopRecording];
		NSLog(@"Done");
    }];
	
}

- (void)startProcessing
{
	CGRect videoFrame = CGRectMake(0, 0, 480, 320);
	
	_view0 = [[GPUImageView alloc] initWithFrame:videoFrame];
	[self.view addSubview:_view0];
	
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp4"];
    
    GPUImageMovie *gpuIM = [[GPUImageMovie alloc] initWithURL:url];
    
	//    gpuIM.playAtActualSpeed = YES;
    
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"];
    GPUImageMovie *inHAHAHA = [[GPUImageMovie alloc] initWithURL:url2];
    
	//    inHAHAHA.playAtActualSpeed = YES;
    
	//  filter0 = [[GPUImageTwoInputCrossTextureSamplingFilter alloc] init];
	//	filter0 = [[GPUImageFilter alloc] init];
	//	filter0 = [[GPUImageDissolveBlendFilter alloc] init];
	
	filter0 = [[GPUImageBrightnessFilter alloc] init];
	[((GPUImageBrightnessFilter*)filter0) setBrightness:0.1];
	
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(test) userInfo:Nil repeats:YES];
	
    [gpuIM addTarget:filter0];
    [inHAHAHA addTarget:filter0];
	//    [inHAHAHA addTarget:filter1];
    
    [filter0 addTarget:_view0];
	//	[filter1 addTarget:_view0];
    
	NSString* document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	
    NSString *path = [document stringByAppendingPathComponent:@"Movie.m4v"];
	unlink([path UTF8String]);
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    
    mw = [[GPUImageMovieWriter alloc] initWithMovieURL:targetURL size:videoFrame.size];
    [filter0 addTarget:mw];
	
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    mw.shouldPassthroughAudio = YES;
    gpuIM.audioEncodingTarget = mw;
	[gpuIM readNextVideoFrameFromOutput:[inHAHAHA.assetReader.outputs objectAtIndex:0]];
    [gpuIM enableSynchronizedEncodingUsingMovieWriter:mw];
	//    inHAHAHA.audioEncodingTarget = mw;
	//    [inHAHAHA enableSynchronizedEncodingUsingMovieWriter:mw];
    
    [mw startRecording];
//    [gpuIM startProcessing];
	//	[inHAHAHA startProcessing];
    
	GPUImagePicture* picture = [[GPUImagePicture alloc] initWithImage:[ImageManager makeScene1WithSize:CGSizeMake(480, 320)]];
	[picture processImage];
	[picture addTarget:filter0];
	
    [mw setCompletionBlock:^{
		[filter0 removeTarget:mw];
        [self stopRecording];
		NSLog(@"Done");
    }];
}


- (void)test {
	
	float opacity = ((GPUImageBrightnessFilter*)filter0).brightness + 0.01;
	NSLog(@"%f", opacity);
	[(GPUImageBrightnessFilter*)filter0 setBrightness:MAX(opacity, 0)];

	
}

- (void)didCompletePlayingMovie
{
	NSLog(@"Done");

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self makeMovie];
	return;
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
	NSString* document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	
    NSString *path = [document stringByAppendingPathComponent:@"Movie.m4v"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
    
    mw = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(640, 480)];
    [filter0 addTarget:mw];
    [mw startRecording];
}

-(void)stopRecording {
    [mw finishRecording];
	NSString* document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:@"Movie.m4v"];
    
    
    
    ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
    [al writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error) {

        if (error) {
            NSLog(@"Error %@", error);
        } else {
            NSLog(@"Success");
			NSLog(@"%@", [assetURL path]);
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


- (IBAction)onPlay:(id)sender {
}

- (IBAction)onMake:(id)sender {
	[self makeMovie];
}

- (IBAction)onAdd:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 3;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
	[cell addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]]];
    return cell;
}

- (void)dealloc {
	[_collectionView release];
	[super dealloc];
}
@end
