//
//  EYImageSliderProgramatic.swift
//  EYImageSliderDemo
//
//  Created by Enix Yu on 29/10/2016.
//  Copyright © 2016 RobotBros. All rights reserved.
//

import UIKit
import EYImageSlider


class EYImageSliderProgramatic: EYImageSliderBase {
    
    var imageSlider: EYImageSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSlider = EYImageSlider()
        imageSlider.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 44)
        
        imageSlider.dataSource = self
        imageSlider.delegate = self
        
        imageSlider.captionTextColor = UIColor.white
        
        view.addSubview(imageSlider)
    }
}
