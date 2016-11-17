Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.ios.deployment_target = '8.0'
  s.name         = "EYImageSlider"
  s.version      = "0.0.2"
  s.summary      = "EYImageSlider is an widget for you to show a series images like in a slider."
  s.description  = "EYImageSlider is a fully customizable widget created for iOS platform to show images in a slider way, it is also support lazy image loading. Developer could also specify the image loading behaviour, eg, using SDWebImage to pull image from remote server."

  s.homepage     = "https://github.com/enix223/EYImageSlider"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Enix Yu" => "enix223@163.com" }
  # s.social_media_url   = "http://twitter.com/enix223"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/enix223/EYImageSlider.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "EYImageSlider/**/*.{h,m,swift}"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.framework  = "UIKit"

end
