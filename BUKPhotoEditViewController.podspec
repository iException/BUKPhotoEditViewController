Pod::Spec.new do |s|
  s.name     = 'BUKPhotoEditViewController'
  s.version  = '0.0.5'
  s.license  = 'MIT'
  s.summary  = 'An photo editing controller enable you to rotate, mosaic and clip a photo.'
  s.homepage = 'https://github.com/iException/BUKPhotoEditViewController'
  s.author   = { 'Lazy Clutch' => 'lr_5146@163.com' }
  s.source   = { :git => 'https://github.com/iException/BUKPhotoEditViewController.git', :tag => '0.0.5' }
  s.platform = :ios, '6.0'
  s.source_files = 'BUKPhotoEditViewController/**/*.{h,m}'
  s.resource     = 'BUKPhotoEditViewController/Assets/**/*.png'
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
end
