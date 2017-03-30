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
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
    
    for( size_t i = 0; i < faces.size(); i++ )
    {
        cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
        
        Mat faceROI = frame_gray( faces[i] );
        std::vector<cv::Rect> eyes;
        
        //-- In each face, detect eyes
        eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
        
        for( size_t j = 0; j < eyes.size(); j++ )
        {
            cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
            int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
            circle( frame, center, radius, Scalar( 255, 0, 0 ), 4, 8, 0 );
        }
    }
    //-- Show what you got

    self._img.contentMode = UIViewContentModeCenter;
    self._img.image = [ImageUtils UIImageFromCVMat: frame];
    NSLog(@"Hope it works ---------------");
}

- (void)processImage:(Mat&)image {
    self.count += 1;
    if (self.count < 100) {
        //NSLog(@"Count is less than 1000");
    }
    
    CvCapture* capture;
    Mat frame = image;
    
    const char* facePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"].cString;
    
    //-- 1. Load the cascades
    if( !face_cascade.load( facePath ) ){ printf("--(!)Error loading\n"); };
    //if( !eyes_cascade.load(  ) ){ printf("--(!)Error loading\n"); };
    
            //-- 3. Apply the classifier to the frame
            if( !frame.empty() )
            { [self detectAndDisplay: frame]; }
            else
            { printf(" --(!) No captured frame -- Break!"); return; }
                
    /*
    cv::Mat gray;
    cvtColor(image, gray, CV_BGRA2GRAY);
    
    std::vector<std::vector<cv::Point>> msers;
    [[MSERManager sharedInstance] detectRegions: gray intoVector: msers];
    if (msers.size() == 0) { return; };
    
    std::vector<cv::Point> *bestMser = nil;
    double bestPoint = 10.0;
    
    std::for_each(msers.begin(), msers.end(), [&] (std::vector<cv::Point> &mser)
                  {
                      MSERFeature *feature = [[MSERManager sharedInstance] extractFeature: &mser];
                      
                      if(feature != nil)
                      {
                          if([[MLManager sharedInstance] isToptalLogo: feature] )
                          {
                              double tmp = [[MLManager sharedInstance] distance: feature ];
                              if ( bestPoint > tmp ) {
                                  bestPoint = tmp;
                                  bestMser = &mser;
                              }
                          }
                      }
                  });
    
    if (bestMser)
    {
        NSLog(@"minDist: %f", bestPoint);
        
        cv::Rect bound = cv::boundingRect(*bestMser);
        cv::rectangle(image, bound, 201, 3);
    }
    else 
    {
        cv::rectangle(image, cv::Rect(0, 0, W, H), 255, 3);
    }

    
    return;
    const char* str = [@"Toptal" cStringUsingEncoding: NSUTF8StringEncoding];
    cv::putText(image, str, cv::Point(100, 100), CV_FONT_HERSHEY_PLAIN, 2.0, cv::Scalar(0, 0, 255));\
    cvCloneImage((IplImage *)(&image)->data);
    return;
    const char* cascadeFileFace = "haarcascades\\haarcascade_frontalface_alt.xml";	// Path to the Face Detection HaarCascade XML file
    CvHaarClassifierCascade *cascadeFace = (CvHaarClassifierCascade *) cvLoad(cascadeFileFace);
    IplImage *image4 = cvCloneImage((IplImage *)&image);
    CvMat image2 = image;
    IplImage image3 = image;
    CvSize size = cvSize(100, 200);
    IplImage *imageInHSV = cvCreateImage(size, 8, 3);
    cvCvtColor(image4, imageInHSV, CV_BGR2HSV);	// (note that OpenCV stores RGB images in B,G,R order.
    IplImage* imageDisplayHSV = cvCreateImage(cvGetSize(&image), 8, 3);	// Create an empty HSV image
    //cvSet(imageDisplayHSV, cvScalar(0,0,0, 0));	// Clear HSV image to blue.
    int hIn = imageDisplayHSV->height;
    int wIn = imageDisplayHSV->width;
    int rowSizeIn = imageDisplayHSV->widthStep;		// Size of row in bytes, including extra padding
    char *imOfsDisp = imageDisplayHSV->imageData;	// Pointer to the start of the image HSV pixels.
    char *imOfsIn = imageInHSV->imageData;	// Pointer to the start of the input image HSV pixels.
    for (int y=0; y<hIn; y++) {
        for (int x=0; x<wIn; x++) {
            // Get the HSV pixel components
            uchar H = *(uchar*)(imOfsIn + y*rowSizeIn + x*3 + 0);	// Hue
            uchar S = *(uchar*)(imOfsIn + y*rowSizeIn + x*3 + 1);	// Saturation
            uchar V = *(uchar*)(imOfsIn + y*rowSizeIn + x*3 + 2);	// Value (Brightness)
            // Determine what type of color the HSV pixel is.
            int ctype = getPixelColorType(H, S, V);
            //ctype = x / 60;
            // Show the color type on the displayed image, for debugging.
            *(uchar*)(imOfsDisp + (y)*rowSizeIn + (x)*3 + 0) = cCTHue[ctype];	// Hue
            *(uchar*)(imOfsDisp + (y)*rowSizeIn + (x)*3 + 1) = cCTSat[ctype];	// Full Saturation (except for black & white)
            *(uchar*)(imOfsDisp + (y)*rowSizeIn + (x)*3 + 2) = cCTVal[ctype];		// Full Brightness
        }
    }
    // Display the HSV debugging image
    IplImage *imageDisplayHSV_RGB = cvCreateImage(cvGetSize(imageDisplayHSV), 8, 3);
    cvCvtColor(imageDisplayHSV, imageDisplayHSV_RGB, CV_HSV2BGR);	// (note that OpenCV stores RGB images in B,G,R order.
    cvNamedWindow("Colors", 1);
    cvShowImage("Colors", imageDisplayHSV_RGB);
     */
}


@end
