//
//  ViewController.h
//  ARTeeView
//
//  Created by Alex Watt on 3/29/17.
//  Copyright © 2017 teespring. All rights reserved.
//
#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#endif”
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <CvVideoCameraDelegate>

@property CvVideoCamera *camera;
@property int count;
@property UIImageView* _img;

@end

