//
//  ViewController.m
//  ARTeeView
//
//  Created by Alex Watt on 3/29/17.
//  Copyright © 2017 teespring. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/videoio/cap_ios.h>
#include <opencv2/imgproc/imgproc_c.h>
#include <iostream>
#include <AVFoundation/AVFoundation.h>

#import "ViewController.h"

using namespace cv;
using namespace std;

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *_imageView;
    
    self.camera = [[CvVideoCamera alloc] initWithParentView: self.view];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 30;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    Mat image = imread("man.png", CV_LOAD_IMAGE_COLOR);

    UIImage *manImage = [UIImage imageNamed:@"man"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:manImage];
    [self.view addSubview:_imageView];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [_imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;\
 
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.camera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processImage:(Mat&)image {
    const char* str = [@"Toptal" cStringUsingEncoding: NSUTF8StringEncoding];
    unsigned char* dataMat = image.data;
    CvArr *something = (CvArr *)dataMat;
    CvFont *font = new CvFont;
    cvInitFont(new CvFont, CV_FONT_HERSHEY_PLAIN, 1.0, 8.0);
    cvPutText(something, str, CvPoint(100,100), font, CvScalar(0,0,255));
}


@end
