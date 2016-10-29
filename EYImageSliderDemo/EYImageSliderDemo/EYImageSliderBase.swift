//
//  EYImageSliderBase.swift
//  EYImageSliderDemo
//
//  Created by Enix Yu on 29/10/2016.
//  Copyright © 2016 RobotBros. All rights reserved.
//

import UIKit
import EYImageSlider


class EYImageSliderBase: UIViewController, EYImageSliderDataSource, EYImageSliderDelegate {
    
    var images: [NSURL]!
    var captions: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = [
            NSURL(string:"http://ocr68xaax.bkt.clouddn.com/images/product/a0d19e34-e411-4409-b141-5c3eca13c1ed.png")!,
            NSURL(string: "http://ocr68xaax.bkt.clouddn.com/images/product/74069900-23d3-4795-9f03-a4000649e1ed.png")!,
            NSURL(string: "http://ocr68xaax.bkt.clouddn.com/images/operator/6fd532d0-18c4-44ed-b492-d50d8991ec03.png")!,
            NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/c/c5/M101_hires_STScI-PRC2006-10a.jpgppp")!
        ]
        
        captions =  [
            "Joystick",
            "SpiderX",
            "Avatar",
            "Not found"
        ]
    }
    
    func arrayWithImages(slider: EYImageSlider) -> [NSURL] {
        return images
    }
    
    func contentModeForImage(imageIndex: Int, inSlider: EYImageSlider) -> UIViewContentMode {
        return .ScaleAspectFit
    }
    
    func imageSlider(slider: EYImageSlider, didSelectImageAtIndex index: Int) {
        UIApplication.sharedApplication().openURL(images[index])
    }
    
    /* Specify the image placeholder if you need it
     func placeHoderImageForImageSlider(slider: EYImageSlider) -> UIImage {
     return UIImage(named: "placeholder")!
     }
     */
    
    func captionForImageAtIndex(imageIndex: Int, inSlider: EYImageSlider) -> String {
        return captions[imageIndex]
    }
    
    func contentModeForPlaceHolder(slider: EYImageSlider) -> UIViewContentMode {
        return .ScaleAspectFit
    }
}