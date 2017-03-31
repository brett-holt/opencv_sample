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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Screen was touched");
    self.shirtIndex += 1;
    NSArray *shirts = @[@"tee", @"rubiks", @"hackathon", @"first", @"coffee"];
    NSString *currentShirt = shirts[self.shirtIndex % [shirts count]];
    self.teeView.image = [UIImage imageNamed:currentShirt];
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
    
    for( size_t i = 0; i < faces.size(); i++ )
    {
        if (i > 0) { return; }
        
        int estimatedNeckLength = faces[i].height * 1.2;
        int estimatedShirtX = faces[i].x + faces[i].width*0.5;
        int estimatedShirtY = faces[i].y + faces[i].height + estimatedNeckLength;
        
        cv::Point center(estimatedShirtX, estimatedShirtY);
        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NULL);
    dispatch_async(backgroundQueue, ^{
        if (self.teeView.image == NULL) {
            return;
        }
            CGFloat numberOfFacesPerShirt = 2.8;
            
            CGFloat imageHeight = self.teeView.image.size.height;
            CGFloat faceHeight = faces[i].height;
            CGFloat desiredImageHeight = faceHeight * numberOfFacesPerShirt;
        CGFloat desiredImageWidth = faces[i].width * 2.2;
            CGFloat scaleFactorH = imageHeight / desiredImageHeight;
        CGFloat scaleFactorW = self.teeView.image.size.width / desiredImageWidth;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat scaledImageWidth = self.teeView.image.size.width / scaleFactorW;
                CGFloat scaledImageHeight = self.teeView.image.size.height / scaleFactorH;
                
                CGFloat shirtX = faces[i].x - faces[i].width*0.5 - scaledImageWidth * 0.45;
                CGFloat shirtY = faces[i].y + faceHeight * 0.45;
                self.teeView.frame = CGRectMake(shirtX, shirtY, scaledImageWidth, scaledImageHeight);
                [self.view bringSubviewToFront:self.teeView];
            
            });
    });
    }
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
