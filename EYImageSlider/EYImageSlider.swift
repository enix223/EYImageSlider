 //
 //  EYImageSlider.swift
 //  EYImageSlider
 //
 //  Created by Enix Yu on 16/8/16.
 //  Copyright © 2016 RobotBros. All rights reserved.
 //
 
 import UIKit
 
 @objc public protocol EYImageSliderDataSource {
    func arrayWithImages(_ slider: EYImageSlider) -> [URL]
    func contentModeForImage(_ imageIndex: Int, inSlider: EYImageSlider) -> UIViewContentMode
    
    @objc optional func placeHoderImageForImageSlider(_ slider: EYImageSlider) -> UIImage
    @objc optional func captionForImageAtIndex(_ imageIndex: Int, inSlider: EYImageSlider) -> String
    @objc optional func contentModeForPlaceHolder(_ slider: EYImageSlider) -> UIViewContentMode
 }
 
 @objc public protocol EYImageSliderDelegate {
    @objc optional func imageSlider(_ slider: EYImageSlider, didSrollToIndex index: Int)
    @objc optional func imageSlider(_ slider: EYImageSlider, didSelectImageAtIndex index: Int)
 }
 
 @objc public protocol EYImageSliderImageDataSource {
    func sliderLoadImageView(_ imageView: UIImageView, withURL url: URL)
 }
 
 @objc class EYImageDefaultDataSource: NSObject, EYImageSliderImageDataSource {
    
    func sliderLoadImageView(_ imageView: UIImageView, withURL url: URL) {
        let actInd = UIActivityIndicatorView()
        actInd.center = CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2)
        actInd.activityIndicatorViewStyle = .white
        imageView.addSubview(actInd)
        actInd.startAnimating()
        
        DispatchQueue.global(qos: .background).async { () -> Void in
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async(execute: { () -> Void in
                    let img = UIImage(data: imageData)
                    imageView.image = img
                    actInd.removeFromSuperview()
                })
            }
        }
    }
 }
 
 open class EYImageSlider: UIView, UIScrollViewDelegate {
    
    /// Delegates data source to asking for image urls
    open weak var dataSource: EYImageSliderDataSource!
    
    /// Delegate for asking image slider responder
    open weak var delegate: EYImageSliderDelegate?
    
    /// `imageSource` delegate is used to load the image
    open weak var imageSource: EYImageSliderImageDataSource?
    
    /// scroll view for the background
    open var scrollView: UIScrollView!
    
    /// page control for the slider
    open var pageControl: UIPageControl!
    
    /// Get the current page index for the slider
    open var currentPage: Int {
        get {
            return pageControl.currentPage
        }
    }
    
    /// Indicate whether the page control is display or not
    open var indicatorDisabled = false {
        didSet(newValue) {
            if newValue {
                pageControl.removeFromSuperview()
            } else {
                self.addSubview(pageControl)
            }
        }
    }
    
    /// Scroll view bounces property
    open var bounces = false {
        didSet(newValue) {
            self.scrollView.bounces = newValue
        }
    }
    
    /// Indicate whether the image count is displayed or hidden
    open var imageCounterDisabled = false {
        didSet(newValue) {
            if newValue {
                self.imageCounterBackground.removeFromSuperview()
            } else {
                self.addSubview(self.imageCounterBackground)
            }
        }
    }
    
    /// Indicate whether hide the page control when there is only one image
    open var hidePageControlForSinglePages = true {
        didSet {
            self.updatePageControl()
        }
    }
    
    /// Constant
    internal let pageControlHeight:CGFloat = 30.0
    internal let overlayWith:CGFloat = 50.0
    internal let overlayHeight:CGFloat = 15.0
    
    /// A time interval for the slider change animation
    open var slideShowTimeInterval: TimeInterval = 0.0 {
        didSet {
            if let timer = slidershowTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            
            self.checkWetherToggleSlidershowTimer()
        }
    }
    
    /// Indicate whether to call the delegate when slider is in animation mode
    open var slideShowShouldCallScrollToDelegate = true
    
    /// Caption label
    open var captionTextColor: UIColor = UIColor.black {
        didSet {
            captionLabel.textColor = captionTextColor
        }
    }
    
    /// background color for the caption label
    open var captionBackgroundColor = UIColor.clear {
        didSet {
            captionLabel.backgroundColor = captionBackgroundColor
        }
    }
    
    /// Caption font for the caption label
    open var captionFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            captionLabel.font = captionFont
        }
    }
    
    
    /// Internal used
    internal let defaultImageDataSource = EYImageDefaultDataSource()
    internal var imageCounterBackground: UIView!
    internal var countLabel: UILabel!
    internal var captionLabel: UILabel!
    internal var slidershowTimer: Timer?
    internal var imageViews = [[String: AnyObject]]()
    
    
    // MARK: Init methods
    
    /// Initialize a slider with `frame`
    /// - param frame: The frame used to create a slider
    /// - return: `EYImageSlider` new instance
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    /// Initialize a slider with `coder`
    /// - param coder: The coder used to initialize slider
    /// - return: `EYImageSlider` new instance
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    open override func layoutSubviews() {
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
    }
    
    internal func randomColor() -> UIColor {
        return UIColor(red: (CGFloat)(arc4random() % 256) / 256.0, green: (CGFloat)(arc4random() % 256) / 256.0, blue: (CGFloat)(arc4random() % 256) / 256.0, alpha: 1.0)
    }
    
    internal func initializeImageCounter() {
        imageCounterBackground = UIView(frame: CGRect(x: self.scrollView.frame.width - self.overlayWith + 4, y: self.scrollView.frame.height - self.overlayHeight, width: overlayWith, height: overlayHeight))
        imageCounterBackground.alpha = 0.7
        imageCounterBackground.layer.cornerRadius = 5.0
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        icon.image = UIImage(named: "EYCam")
        icon.center = CGPoint(x: imageCounterBackground.frame.size.width - 18, y: imageCounterBackground.frame.size.height/2)
        imageCounterBackground.addSubview(icon)
        
        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 24))
        countLabel.textAlignment = NSTextAlignment.center
        countLabel.backgroundColor = UIColor.clear
        countLabel.textColor = UIColor.black
        countLabel.font = UIFont.systemFont(ofSize: 11.0)
        countLabel.center = CGPoint(x: 15, y: imageCounterBackground.frame.size.height/2)
    }
    
    internal func initializeCaption() {
        captionLabel = UILabel(frame: CGRect(x: 10, y: scrollView.frame.size.height - 50, width: scrollView.frame.size.width - 10, height: 20))
        captionLabel.backgroundColor = captionBackgroundColor
        captionLabel.textColor = captionTextColor
        captionLabel.font = captionFont
        captionLabel.alpha = 0.7
        captionLabel.layer.cornerRadius = 5.0
        
        self.addSubview(captionLabel)
    }
    
    internal func initializeScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
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
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * (CGFloat)(aImageUrls.count), height: scrollView.frame.size.height)
            
            imageViews.removeAll()
            for i in 0..<aImageUrls.count {
                let width = scrollView.frame.size.width * CGFloat(i)
                let imageFrame = CGRect(x: width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
                let imageView = UIImageView(frame: imageFrame)
                imageView.backgroundColor = UIColor.clear
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
                    if imageSource != nil {
                        imageSource?.sliderLoadImageView(imageView, withURL: aImageUrls[currentPage])
                    } else {
                        self.defaultImageDataSource.sliderLoadImageView(imageView, withURL: aImageUrls[currentPage])
                    }
                    var imageViewMeta = [String: AnyObject]()
                    imageViewMeta["imageView"] = imageView
                    imageViewMeta["loaded"] = true as AnyObject?
                    imageViews.append(imageViewMeta)
                } else {
                    var imageViewMeta = [String: AnyObject]()
                    imageViewMeta["imageView"] = imageView
                    imageViewMeta["loaded"] = false as AnyObject?
                    imageViews.append(imageViewMeta)
                }
                
                let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(EYImageSlider.imageTapped(_:)))
                singleTapGesture.numberOfTapsRequired = 1
                imageView.addGestureRecognizer(singleTapGesture)
                imageView.isUserInteractionEnabled = true
                
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
                pageControl.isHidden = true
                return
            }
        }
        pageControl.isHidden = false
    }
    
    internal func imageTapped(_ gesture: UIGestureRecognizer){
        let index = gesture.view!.tag
        delegate?.imageSlider?(self, didSelectImageAtIndex: index)
    }
    
    internal func initializePageControl(){
        if !self.indicatorDisabled {
            let frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: self.pageControlHeight)
            pageControl = UIPageControl(frame: frame)
            pageControl.center = CGPoint(x: scrollView.frame.size.width/2, y: scrollView.frame.size.height - 12.0)
            pageControl.isUserInteractionEnabled = false
            pageControl.currentPage = 0
            addSubview(pageControl)
        }
    }
    
    // MARK - UIScrollViewDelegate
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let timer = slidershowTimer, slidershowTimer!.isValid {
            timer.invalidate()
        }
        
        self.checkWetherToggleSlidershowTimer()
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
            if imageSource != nil {
                imageSource?.sliderLoadImageView(imageView, withURL: aImageUrls[currentPage])
            } else {
                self.defaultImageDataSource.sliderLoadImageView(imageView, withURL: aImageUrls[currentPage])
            }
            imageViews[currentPage]["loaded"] = true as AnyObject?
        }
    }
    
    internal func updateCaptionLabelForImageAtIndex(_ idx: Int) {
        if let caption = dataSource.captionForImageAtIndex?(idx, inSlider: self) {
            if caption.characters.count > 0 {
                captionLabel.isHidden = false
                captionLabel.text = caption
                return
            }
        }
        captionLabel.isHidden = true
    }
    
    internal func fireDidScrollToIndexDelegateForPage(_ page: Int) {
        delegate?.imageSlider?(self, didSrollToIndex: page)
    }
    
    // MARK - Slidershow
    
    internal func slidershowTick(_ timer: Timer) {
        var nextPage = 0
        if pageControl.currentPage < dataSource.arrayWithImages(self).count - 1 {
            nextPage = pageControl.currentPage + 1
        }
        
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
                slidershowTimer = Timer.scheduledTimer(timeInterval: self.slideShowTimeInterval, target: self, selector: #selector(EYImageSlider.slidershowTick(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    internal func scrollToPage(_ page: Int, animated: Bool) {
        let visibleFrame = CGRect(x: scrollView.frame.size.width * CGFloat(page), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        scrollView .scrollRectToVisible(visibleFrame, animated: animated)
    }
    
    /// MARK - Public methods
    
    /// Ask the image slider to reload explicitly
    open func reloadData() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        self.loadData()
        self.checkWetherToggleSlidershowTimer()
    }
    
    /// Set the current page with sepcific `currentPage` number with animation or not
    /// - param currentPage: The new page number you need to change
    /// - param animated: true to animate to the specific page, false without animation
    /// - return: None
    open func setCurrentPage(_ currentPage: Int, animated: Bool) {
        assert(currentPage < dataSource.arrayWithImages(self).count, "currentPage must not exceed the maximum number of images")
        pageControl.currentPage = currentPage
        scrollToPage(currentPage, animated: true)
    }
 }
