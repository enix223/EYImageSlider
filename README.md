# EYImageSlider
A simple image slider written in Swift for iOS8 and up, inspired by KIImagePager

# ScreenShot

![ScreenShot](https://github.com/enix223/EYImageSlider/blob/master/EYImageSliderDemo/DemoGif/image-slider.gif?raw=true)


# Installation

### 1. Pod

include the following line into your podfile

    pod EYImageSlider

and run

    pod install

### 2. Mannual

Simply copy `EYImageSlider/EYImageSlider.swift` to your project

# Usage

You can create an EYImageSlider either from Storyboard or programatically `EYImageSlider()`

### Create with Storyboard

1. Drag a UIView into storyboard, and set the UIView Class to `EYImageSlider`.

2. Set an outlet for the image slider to the view controller.

        @IBOutlet weak var imageSlider: EYImageSlider!

3. Set the image slider data source and delegete

        // Set slider data source & delegate
        imageSlider.dataSource = self
        imageSlider.delegate = self
 
4. Implement the data source protocol:

        images = [
            NSURL(string:"http://ocr68xaax.bkt.clouddn.com/images/product/a0d19e34-e411-4409-b141-5c3eca13c1ed.png")!,
            NSURL(string: "http://ocr68xaax.bkt.clouddn.com/images/product/74069900-23d3-4795-9f03-a4000649e1ed.png")!,
            NSURL(string: "http://ocr68xaax.bkt.clouddn.com/images/operator/6fd532d0-18c4-44ed-b492-d50d8991ec03.png")!,
            NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/c/c5/M101_hires_STScI-PRC2006-10a.jpgppp")!
        ]

        func arrayWithImages(slider: EYImageSlider) -> [NSURL] {
            return images
        }

5. Specify the image content mode

        func contentModeForImage(imageIndex: Int, inSlider: EYImageSlider) -> UIViewContentMode {
            return .ScaleAspectFit
        }

6. Specify the caption for each image  [Optional]

        captions =  [
            "Joystick",
            "SpiderX",
            "Avatar",
            "Not found"
        ]
        
        func captionForImageAtIndex(imageIndex: Int, inSlider: EYImageSlider) -> String {
            return captions[imageIndex]
        }

7. Callback when image is tapped.

        func imageSlider(slider: EYImageSlider, didSelectImageAtIndex index: Int) {
            UIApplication.sharedApplication().openURL(images[index])
        }

For more example, please checkout `EYImageSliderDemo` project for swift, and `EYImageSliderDemo-OC` for Objective-C.

### Programatically

```
imageSlider = EYImageSlider()
imageSlider.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 44)

imageSlider.dataSource = self
imageSlider.delegate = self

imageSlider.captionTextColor = UIColor.whiteColor()

view.addSubview(imageSlider)
```

That is it. Easy? Happy coding...

