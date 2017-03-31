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
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

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

    self.teeView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"she_persisted"]];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.teeView.hidden = YES;
    });

    UIImage *logoImage = [UIImage imageNamed:@"TeeViewLogo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.contentMode = UIViewContentModeCenter;

    CGFloat screenWidth = self.view.frame.size.width;
    self.topBarView = logoImageView;
    self.topBarView.frame = CGRectMake(0, 0, screenWidth, 60.0);
    self.topBarView.backgroundColor = [UIColor whiteColor];
}

- (IBAction)cameraButtonPressed:(id)sender {
    [self captureImage];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.camera start];

    [self.view insertSubview:self.teeView belowSubview:self.cameraButton];
    self.teeView.frame = CGRectMake(200.0, 210.0, 200.0, 200.0);
    self.teeView.userInteractionEnabled = NO;
    
    [self.view insertSubview:self.topBarView belowSubview:self.cameraButton];
    self.topBarView.layer.zPosition = 1;
    
    [self.view insertSubview:self.cameraButton atIndex:self.view.subviews.count - 1];
    self.cameraButton.layer.zPosition = 1;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self captureImage];
//    NSLog(@"Screen was touched");
    self.shirtIndex += 1;
    [self updateShirt];
}

- (void)updateShirt {
    NSArray *shirts = @[@"she_persisted", @"rubicks", @"hackathon", @"first", @"coffee"];
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

    cvtColor(frame, frame_gray, CV_BGR2GRAY);
    equalizeHist(frame_gray, frame_gray);

    //-- Detect faces
    face_cascade.detectMultiScale(frame_gray, faces, 1.1, 5, 0|CV_HAAR_FIND_BIGGEST_OBJECT, cv::Size(30, 30));
    dispatch_async(dispatch_get_main_queue(), ^{

        if (faces.empty()) {
            self.teeView.hidden = YES;
            return;
        } else {
            self.teeView.hidden = NO;
        }

        cv::Rect faceRect = faces[0];

        int estimatedShirtX = faces[0].x + faces[0].width * 0.5;
        int estimatedShirtY = faces[0].y + faces[0].height * 0.5;

        cv::Point center(estimatedShirtX, estimatedShirtY);

        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenBounds.size.width;
        CGFloat screenHeight = screenBounds.size.height;

        CGFloat desiredWidth = screenWidth * 3.15 * faceRect.width / 480.0;
        CGFloat desiredHeight = screenHeight * 3.6 * faceRect.height / 640.0;

        CGFloat faceX = screenWidth * center.x / 480.0 - desiredWidth * 0.5;
        CGFloat faceY = screenHeight * center.y / 640.0 - desiredHeight * 0.5;

        CGFloat chinY = faceY + faceRect.height * 0.5 + desiredHeight * 0.5;

        self.teeView.frame = CGRectMake(faceX, chinY, desiredWidth, desiredHeight);
        [self.view bringSubviewToFront:self.teeView];
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

- (void)captureImage
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGSize imageSize = rect.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, [self.view.layer affineTransform]);
    
    if ([self.view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) { // iOS 7+
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    } else { // iOS 6
        [self.view.layer renderInContext:ctx];
    }
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(ctx);
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(screengrab, nil, nil, nil);
}

- (AVCaptureDevice *)backCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"clays a butt");
    CGImageRef cgImage = [self imageFromSampleBuffer:sampleBuffer];
    self.capturedImage = [UIImage imageWithCGImage: cgImage ];
    
    CGImageRelease( cgImage );
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"];
    NSData* data = UIImagePNGRepresentation(self.capturedImage);
    [data writeToFile:filePath atomically:YES];
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return newImage;
}

@end
