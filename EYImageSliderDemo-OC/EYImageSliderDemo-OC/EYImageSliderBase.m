//
//  EYImageSliderBase.m
//  EYImageSliderDemo-OC
//
//  Created by Enix Yu on 29/10/2016.
//  Copyright © 2016 RobotBros. All rights reserved.
//

#import "EYImageSliderBase.h"

@interface EYImageSliderBase ()

@property (nonatomic, strong) NSArray<NSURL *> *images;
@property (nonatomic, strong) NSArray<NSString *> *captions;

@end


@implementation EYImageSliderBase

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _images = @[
               [NSURL URLWithString:@"http://ocr68xaax.bkt.clouddn.com/images/product/a0d19e34-e411-4409-b141-5c3eca13c1ed.png"],
               [NSURL URLWithString:@"http://ocr68xaax.bkt.clouddn.com/images/product/74069900-23d3-4795-9f03-a4000649e1ed.png"],
               [NSURL URLWithString:@"http://ocr68xaax.bkt.clouddn.com/images/operator/6fd532d0-18c4-44ed-b492-d50d8991ec03.png"],
               [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/c/c5/M101_hires_STScI-PRC2006-10a.jpgppp"]
               ];
    _captions = @[@"Joystick", @"Spider-X", @"Avatar", @"Image not found"];
}

- (void)imageSlider:(EYImageSlider *)slider didSrollToIndex:(NSInteger)index {
    NSLog(@"Scroll to image %ld", (long)index);
}

- (NSArray<NSURL *> *)arrayWithImages:(EYImageSlider *)slider {
    return _images;
}

- (NSString *)captionForImageAtIndex:(NSInteger)imageIndex inSlider:(EYImageSlider *)inSlider {
    return [_captions objectAtIndex:imageIndex];
}

- (void)imageSlider:(EYImageSlider *)slider didSelectImageAtIndex:(NSInteger)index {
    NSURL *url = [_images objectAtIndex:index];
    [[UIApplication sharedApplication] openURL:url];
}

- (UIViewContentMode)contentModeForImage:(NSInteger)imageIndex inSlider:(EYImageSlider *)inSlider {
    return UIViewContentModeScaleAspectFit;
}

/* Customize your placeholder
 *
- (UIImage *)placeHoderImageForImageSlider:(EYImageSlider *)slider {
    return [UIImage imageNamed:@"placeholder"];
}
 
- (UIViewContentMode)contentModeForPlaceHolder:(EYImageSlider *)slider {
 return UIViewContentModeScaleAspectFit;
}

*/



@end
