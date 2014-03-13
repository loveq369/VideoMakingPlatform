//
//  ViewController.h
//  VideoMakingPlatform
//
//  Created by chicpark7 on 2014. 3. 4..
//  Copyright (c) 2014년 Chicpark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"


@interface ViewController : UIViewController <GPUImageMovieDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource> {
	NSArray* _imgArray;
}
- (IBAction)onPlay:(id)sender;
- (IBAction)onMake:(id)sender;
- (IBAction)onAdd:(id)sender;
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;

@end
