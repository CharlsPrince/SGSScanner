Pod::Spec.new do |s|
  s.name             = 'SGSScanner'
  s.version          = '0.1.2'
  s.summary          = '二维码、条形码工具'

  s.homepage         = 'https://github.com/CharlsPrince/SGSScanner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CharlsPrince' => '961629701@qq.com' }
  s.source           = { :git => 'https://github.com/CharlsPrince/SGSScanner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.requires_arc  = true

  s.public_header_files = 'SGSScanner/**/SGSScanner*.h'
  s.source_files = 'SGSScanner/**/SGSScanner*.{h,m}'

  s.resource_bundles = {
    'SGSScanner' => ['SGSScanner/Assets/*.png']
  }

  s.subspec 'Core' do |ss|
    ss.source_files = 'SGSScanner/Classes/Core/*.{h,m}'
    ss.public_header_files = 'SGSScanner/Classes/Core/*.h'
    ss.frameworks = 'UIKit', 'AVFoundation'
  end

  s.frameworks = 'UIKit', 'AVFoundation'
end
