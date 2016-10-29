 //
 //  EYImageSlider.swift
 //  EYImageSlider
 //
 //  Created by Enix Yu on 16/8/16.
 //  Copyright © 2016 RobotBros. All rights reserved.
 //
 
 import UIKit
 
 @objc public protocol EYImageSliderDataSource {
    func arrayWithImages(slider: EYImageSlider) -> [NSURL]
    func contentModeForImage(imageIndex: Int, inSlider: EYImageSlider) -> UIViewContentMode
    
    optional func placeHoderImageForImageSlider(slider: EYImageSlider) -> UIImage
    optional func captionForImageAtIndex(imageIndex: Int, inSlider: EYImageSlider) -> String
    optional func contentModeForPlaceHolder(slider: EYImageSlider) -> UIViewContentMode
 }
 
 @objc public protocol EYImageSliderDelegate {
    optional func imageSlider(slider: EYImageSlider, didSrollToIndex index: Int)
    optional func imageSlider(slider: EYImageSlider, didSelectImageAtIndex index: Int)
 }
 
 @objc public protocol EYImageSliderImageDataSource {
    func sliderLoadImageView(imageView: UIImageView, withURL url: NSURL)
 }
 
 @objc internal class EYImageDefaultDataSource: NSObject, EYImageSliderImageDataSource {
    
    func sliderLoadImageView(imageView: UIImageView, withURL url: NSURL) {
        let actInd = UIActivityIndicatorView()
        actInd.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2)
        actInd.activityIndicatorViewStyle = .White
        imageView.addSubview(actInd)
        actInd.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            if let imageData = NSData(contentsOfURL: url) {
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    let img = UIImage(data: imageData)
                    imageView.image = img
                    actInd.removeFromSuperview()
                })
            }
        }
    }
 }
 
 public class EYImageSlider: UIView, UIScrollViewDelegate {
    
    /// Delegates
    public var dataSource: EYImageSliderDataSource!
    public var delegate: EYImageSliderDelegate?
    public var imageSource: EYImageSliderImageDataSource?
    
    /// Property
    public var scrollView: UIScrollView!
    public var pageControl: UIPageControl!
    public var currentPage: Int {
        get {
            return pageControl.currentPage
        }
        set {
            
        }
    }
    
    public var indicatorDisabled = false {
        didSet(newValue) {
            if newValue {
                pageControl.removeFromSuperview()
            } else {
                self.addSubview(pageControl)
            }
        }
    }
    
    public var bounces = false {
        didSet(newValue) {
            self.scrollView.bounces = newValue
        }
    }
    
    public var imageCounterDisabled = false {
        didSet(newValue) {
            if newValue {
                self.imageCounterBackground.removeFromSuperview()
            } else {
                self.addSubview(self.imageCounterBackground)
            }
        }
    }
    
    public var hidePageControlForSinglePages = true {
        didSet {
            self.updatePageControl()
        }
    }
    
    /// Constant
    let pageControlHeight:CGFloat = 30.0
    let overlayWith:CGFloat = 50.0
    let overlayHeight:CGFloat = 15.0
    
    /// Slide show
    public var slideShowTimeInterval: NSTimeInterval = 0.0 {
        didSet {
            if let timer = slidershowTimer {
                if timer.valid {
                    timer.invalidate()
                }
            }
            
            self.checkWetherToggleSlidershowTimer()
        }
    }
    
    public var slideShowShouldCallScrollToDelegate = true
    
    /// Caption label
    public var captionTextColor: UIColor = UIColor.blackColor() {
        didSet {
            captionLabel.textColor = captionTextColor
        }
    }
    
    public var captionBackgroundColor = UIColor.clearColor() {
        didSet {
            captionLabel.backgroundColor = captionBackgroundColor
        }
    }
    
    public var captionFont = UIFont.systemFontOfSize(12) {
        didSet {
            captionLabel.font = captionFont
        }
    }
    
    
    /// Internal used
    //internal static let defaultImageDataSource = EYImageDefaultDataSource()
    internal var imageCounterBackground: UIView!
    internal var countLabel: UILabel!
    internal var captionLabel: UILabel!
    internal var slidershowTimer: NSTimer?
    internal var imageViews = [[String: AnyObject]]()
    
    
    // MARK - Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        initialize()
        loadData()
    }
    
    internal func initialize() {
        self.initializeScrollView()
        self.initializePageControl()
        self.initializeImageCounter()
        self.initializeCaption()
        
        if self.imageSource == nil {
            self.imageSource = EYImageDefaultDataSource() //self.defaultImageDataSource
        }
    }
    
    func randomColor() -> UIColor {
        return UIColor(red: (CGFloat)(arc4random() % 256) / 256.0, green: (CGFloat)(arc4random() % 256) / 256.0, blue: (CGFloat)(arc4random() % 256) / 256.0, alpha: 1.0)
    }
    
    func initializeImageCounter() {
        imageCounterBackground = UIView(frame: CGRectMake(CGRectGetWidth(self.scrollView.frame) - self.overlayWith + 4, CGRectGetHeight(self.scrollView.frame) - self.overlayHeight, overlayWith, overlayHeight))
        imageCounterBackground.alpha = 0.7
        imageCounterBackground.layer.cornerRadius = 5.0
        
        let icon = UIImageView(frame: CGRectMake(0, 0, 18, 18))
        icon.image = UIImage(named: "EYCam")
        icon.center = CGPointMake(imageCounterBackground.frame.size.width - 18, imageCounterBackground.frame.size.height/2)
        imageCounterBackground.addSubview(icon)
        
        countLabel = UILabel(frame: CGRectMake(0, 0, 48, 24))
        countLabel.textAlignment = NSTextAlignment.Center
        countLabel.backgroundColor = UIColor.clearColor()
        countLabel.textColor = UIColor.blackColor()
        countLabel.font = UIFont.systemFontOfSize(11.0)
        countLabel.center = CGPointMake(15, imageCounterBackground.frame.size.height/2)
    }
    
    func initializeCaption() {
        captionLabel = UILabel(frame: CGRectMake(10, scrollView.frame.size.height - 50, scrollView.frame.size.width - 10, 20))
        captionLabel.backgroundColor = captionBackgroundColor
        captionLabel.textColor = captionTextColor
        captionLabel.font = captionFont
        captionLabel.alpha = 0.7
        captionLabel.layer.cornerRadius = 5.0
        
        self.addSubview(captionLabel)
    }
    
    func initializeScrollView() {
        scrollView = UIScrollView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.bounces = bounces
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = self.autoresizingMask
        
        self.addSubview(scrollView)
    }
    
    internal func loadData() {
        if dataSource == nil {
            print("ERROR: EYImageSlider dataSource not set")
            return
        }
        
        let aImageUrls = dataSource.arrayWithImages(self)
        
        updateCaptionLabelForImageAtIndex(0)
        
        if aImageUrls.count > 0 {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (CGFloat)(aImageUrls.count), scrollView.frame.size.height)
            
            imageViews.removeAll()
            for i in 0..<aImageUrls.count {
                let width = scrollView.frame.size.width * CGFloat(i)
                let imageFrame = CGRectMake(width, 0, scrollView.frame.size.width, scrollView.frame.size.height)
                let imageView = UIImageView(frame: imageFrame)
                imageView.backgroundColor = UIColor.clearColor()
                imageView.contentMode = dataSource.contentModeForImage(i, inSlider: self)
                imageView.tag = i
                imageView.clipsToBounds = true
                
                if let img = dataSource.placeHoderImageForImageSlider?(self) {
                    imageView.image = img
                }
                
                if let mode = dataSource.contentModeForPlaceHolder?(self) {
                    imageView.contentMode = mode
                }
                
                if i == 0 {
                    // Only load the first image, others will be load when need to display
                    imageSource?.sliderLoadImageView(imageView, withURL: aImageUrls[currentPage])
                    var imageViewMeta = [String: AnyObject]()
                    imageViewMeta["imageView"] = imageView
                    imageViewMeta["loaded"] = true
                    imageViews.append(imageViewMeta)
                } else {
                    var imageViewMeta = [String: AnyObject]()
                    imageViewMeta["imageView"] = imageView
                    imageViewMeta["loaded"] = false
                    imageViews.append(imageViewMeta)
                }
                
                let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(EYImageSlider.imageTapped(_:)))
                singleTapGesture.numberOfTapsRequired = 1
                imageView.addGestureRecognizer(singleTapGesture)
                imageView.userInteractionEnabled = true
                
                scrollView.addSubview(imageView)
            }
            
            countLabel.text = "\(dataSource.arrayWithImages(self).count)"
            pageControl.numberOfPages = dataSource.arrayWithImages(self).count
        } else {
            
            let blankImage = UIImageView(frame: scrollView.frame)
            if let placeholder = dataSource.placeHoderImageForImageSlider?(self) {
                blankImage.image = placeholder
            }
            
            if let mode = dataSource.contentModeForPlaceHolder?(self) {
                blankImage.contentMode = mode
            }
            
            self.updatePageControl()
        }
    }
    
    internal func updatePageControl() {
        if hidePageControlForSinglePages {
            if self.dataSource.arrayWithImages(self).count < 2 {
                pageControl.hidden = true
                return
            }
        }
        pageControl.hidden = false
    }
    
    internal func imageTapped(gesture: UIGestureRecognizer){
        let index = gesture.view!.tag
        delegate?.imageSlider?(self, didSelectImageAtIndex: index)
    }
    
    internal func initializePageControl(){
        if !self.indicatorDisabled {
            let frame = CGRectMake(0, 0, scrollView.frame.size.width, self.pageControlHeight)
            pageControl = UIPageControl(frame: frame)
            pageControl.center = CGPointMake(scrollView.frame.size.width/2, scrollView.frame.size.height - 12.0)
            pageControl.userInteractionEnabled = false
            pageControl.currentPage = 0
            addSubview(pageControl)
        }
    }
    
    // MARK - UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let timer = slidershowTimer where slidershowTimer!.valid {
            timer.invalidate()
        }
        
        self.checkWetherToggleSlidershowTimer()
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = lroundf(Float((scrollView.contentOffset.x) / scrollView.frame.size.width))
        pageControl.currentPage = currentPage
        
        self.loadCurrentPageImage() // image lazy loading
        self.updateCaptionLabelForImageAtIndex(currentPage)
        self.fireDidScrollToIndexDelegateForPage(currentPage)
    }
    
    internal func loadCurrentPageImage() {
        let imageViewMeta = imageViews[currentPage]
        let imageView = imageViewMeta["imageView"] as! UIImageView
        let loaded = imageViewMeta["loaded"] as! Bool
        let aImageUrls = dataSource.arrayWithImages(self)
        
        if !loaded {
            imageSource?.sliderLoadImageView(imageView, withURL: aImageUrls[currentPage])
            imageViews[currentPage]["loaded"] = true
        }
    }
    
    internal func updateCaptionLabelForImageAtIndex(idx: Int) {
        if let caption = dataSource.captionForImageAtIndex?(idx, inSlider: self) {
            if caption.characters.count > 0 {
                captionLabel.hidden = false
                captionLabel.text = caption
                return
            }
        }
        captionLabel.hidden = true
    }
    
    internal func fireDidScrollToIndexDelegateForPage(page: Int) {
        delegate?.imageSlider?(self, didSrollToIndex: page)
    }
    
    // MARK - Slidershow
    
    internal func slidershowTick(timer: NSTimer) {
        var nextPage = 0
        if pageControl.currentPage < dataSource.arrayWithImages(self).count - 1 {
            nextPage = pageControl.currentPage + 1
        }
        
        //scrollView .scrollRectToVisible(CGRectMake(self.frame.size.width * CGFloat(nextPage), 0, self.frame.size.width, self.frame.size.width), animated: true)
        pageControl.currentPage = nextPage
        scrollToPage(nextPage, animated: true)
        
        self.loadCurrentPageImage() // image lazy loading
        
        if slideShowShouldCallScrollToDelegate {
            fireDidScrollToIndexDelegateForPage(nextPage)
        }
    }
    
    internal func checkWetherToggleSlidershowTimer() {
        if self.slideShowTimeInterval > 0 {
            if dataSource.arrayWithImages(self).count > 1{
                if let timer = slidershowTimer {
                    timer.invalidate()
                }
                slidershowTimer = NSTimer.scheduledTimerWithTimeInterval(self.slideShowTimeInterval, target: self, selector: #selector(EYImageSlider.slidershowTick(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    internal func scrollToPage(page: Int, animated: Bool) {
        let visibleFrame = CGRectMake(scrollView.frame.size.width * CGFloat(page), 0, scrollView.frame.size.width, scrollView.frame.size.height)
        scrollView .scrollRectToVisible(visibleFrame, animated: animated)
    }
    
    /// MARK - Public methods
    public func reloadData() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        self.loadData()
        self.checkWetherToggleSlidershowTimer()
    }
    
    public func setCurrentPage(currentPage: Int, animated: Bool) {
        assert(currentPage < dataSource.arrayWithImages(self).count, "currentPage must not exceed the maximum number of images")
        pageControl.currentPage = currentPage
        scrollToPage(currentPage, animated: true)
    }
 }
