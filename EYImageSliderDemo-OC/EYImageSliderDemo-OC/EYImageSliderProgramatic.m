//
//  EYImageSliderProgramatic.m
//  EYImageSliderDemo-OC
//
//  Created by Enix Yu on 29/10/2016.
//  Copyright © 2016 RobotBros. All rights reserved.
//

#import "EYImageSliderProgramatic.h"



@interface EYImageSliderProgramatic ()

@property (nonatomic, strong) EYImageSlider *imageSlider;

@end

@implementation EYImageSliderProgramatic

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create an image slider with the same size as the back view
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44);
    _imageSlider = [[EYImageSlider alloc] initWithFrame:rect];
    
    // Set data source, and delegate
    [self.imageSlider setDataSource:self];
    [self.imageSlider setDelegate:self];
    
    // Set text color
    [self.imageSlider setCaptionTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.imageSlider];
}

@end
