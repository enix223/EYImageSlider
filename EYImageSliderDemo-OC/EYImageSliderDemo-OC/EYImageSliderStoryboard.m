//
//  EYImageSliderStoryboard.m
//  EYImageSliderDemo-OC
//
//  Created by Enix Yu on 29/10/2016.
//  Copyright © 2016 RobotBros. All rights reserved.
//

#import "EYImageSliderStoryboard.h"

@interface EYImageSliderStoryboard ()

@property (weak, nonatomic) IBOutlet EYImageSlider *imageSlider;

@end

@implementation EYImageSliderStoryboard


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageSlider setDataSource:self];
    [self.imageSlider setDelegate:self];
    
    [self.imageSlider setSlideShowTimeInterval:2.0];
    [self.imageSlider setCaptionTextColor:[UIColor whiteColor]];
}

@end
