#
# Be sure to run `pod lib lint SGSScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SGSScanner'
  s.version          = '0.1.1'
  s.summary          = '二维码、条形码工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
集成二维码、条形码扫描，二维码、条形码生成工具
                       DESC

  s.homepage         = 'https://github.com/CharlsPrince/SGSScanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CharlsPrince' => '961629701@qq.com' }
  s.source           = { :git => 'https://github.com/CharlsPrince/SGSScanner.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.public_header_files = 'SGSScanner/Classes/*.h', 'SGSScanner/Classes/Core/*.h'
  s.source_files = 'SGSScanner/Classes/**/*'

  s.resource_bundles = {
    'SGSScanner' => ['SGSScanner/Assets/*.png']
  }

  s.frameworks = 'UIKit', 'AVFoundation'
  


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
