//
//  ViewController.m
//  ARTeeView
//
//  Created by Alex Watt on 3/29/17.
//  Copyright © 2017 teespring. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#import <opencv2/highgui/cap_ios.h>
#include <opencv2/imgproc/imgproc_c.h>
#include <opencv2/objdetect/objdetect.hpp>
#include <iostream>
#include <AVFoundation/AVFoundation.h>

#import "ViewController.h"
#import "ImageUtils.h"

using namespace cv;
using namespace std;

String face_cascade_name = "haarcascade_frontalface_alt.xml";
String eyes_cascade_name = "haarcascade_eye_tree_eyeglasses.xml";
CascadeClassifier face_cascade;
CascadeClassifier eyes_cascade;
string window_name = "Capture - Face detection";
RNG rng(12345);

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self._img = [UIImageView new];
    
    self.camera = [[CvVideoCamera alloc] initWithParentView: self.view];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 30;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self;
    
    
    self.teeView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"tee"]];
    [self.view addSubview:self.teeView];
    self.teeView.frame = CGRectMake(200.0, 210.0, 200.0, 200.0);

}

- (void)viewDidAppear:(BOOL)animated {
    [self.camera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) detectAndDisplay:(Mat)frame {
    std::vector<cv::Rect> faces;
    Mat frame_gray;
    
    cvtColor( frame, frame_gray, CV_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );
    
    //-- Detect faces
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 5, 0|CV_HAAR_FIND_BIGGEST_OBJECT, cv::Size(30, 30) );
    

    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NULL);
    dispatch_async(backgroundQueue, ^{
        for( size_t i = 0; i < faces.size(); i++ )
        {
            if (i > 0) { return; }
            cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height + faces[i].height*1.2 );
           // ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
            
            
            CGFloat imageHeight = self.teeView.image.size.height;
            CGFloat faceHeight = faces[i].height;
            CGFloat desiredImageHeight = faceHeight * 2.8
            ;
            CGFloat scaleFactor = imageHeight / desiredImageHeight;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"it executed");
                CGFloat scaledImageWidth = self.teeView.image.size.width / scaleFactor;
                CGFloat scaledImageHeight = self.teeView.image.size.height / scaleFactor;
                CGFloat leftX = faces[i].x - faces[i].width*0.5 - scaledImageWidth * 0.45;
                CGFloat topY = faces[i].y + faces[i].height * 0.45;
                NSLog(@"%f", scaledImageHeight);
                NSLog(@"%f", scaledImageWidth);
                NSLog(@"%f", leftX);
                NSLog(@"%f", topY);
                self.teeView.frame = CGRectMake(leftX, topY, scaledImageWidth, scaledImageHeight);
                [self.view bringSubviewToFront:self.teeView];
            });
        }

    });
}

- (void)processImage:(Mat&)image {
    self.count += 1;
    if (self.count % 2 != 0) {
        return;
    }
    
    Mat frame = image;
    
    const char* facePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"].cString;
    
    //-- 1. Load the cascades
    if( !face_cascade.load( facePath ) ){ printf("--(!)Error loading\n"); };
    
    //-- 3. Apply the classifier to the frame
    if( !frame.empty() )
    { [self detectAndDisplay: frame]; }
    else
    { printf(" --(!) No captured frame -- Break!"); return; }
}


@end
