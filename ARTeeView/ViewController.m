//
//  ViewController.m
//  ARTeeView
//
//  Created by Alex Watt on 3/29/17.
//  Copyright © 2017 teespring. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

#import "ViewController.h"

using namespace cv;
using namespace std;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Mat image = imread("man.png", CV_LOAD_IMAGE_COLOR);
    
    UIImage *manImage = [UIImage imageNamed:@"man"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:manImage];
    [self.view addSubview:imageView];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [imageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
