Pod::Spec.new do |spec|
  spec.name         = 'ABMagicDeeplink'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/kiransar/ABMagicDeeplink-iOS'
  spec.authors      = { 'Kirankumar Sarvaiya' => 'ksarv05@safeway.com' }
  spec.summary      = 'A CocoaPods library written in Swift to implement magic deeplink.'
  spec.source       = { :git => 'https://github.com/kiransar/ABMagicDeeplink-iOS.git', :tag => "#{spec.version}" }
  spec.source_files = 'ABMagicDeeplink/*'
  spec.swift_version = "5.3"
  spec.ios.deployment_target = "9.0"
  spec.requires_arc = true
    spec.framework  = 'Foundation'
end
