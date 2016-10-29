//
//  ViewController.swift
//  EYImageSliderDemo
//
//  Created by Enix Yu on 29/10/2016.
//  Copyright © 2016 RobotBros. All rights reserved.
//

import UIKit
import EYImageSlider

class EYImageSliderStoryboard: EYImageSliderBase {

    @IBOutlet weak var imageSlider: EYImageSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set slider data source & delegate
        imageSlider.dataSource = self
        imageSlider.delegate = self
        
        // Slider show time interval
        imageSlider.slideShowTimeInterval = 3
        
        // Set image caption
        imageSlider.captionTextColor = UIColor.whiteColor()
    }
}

