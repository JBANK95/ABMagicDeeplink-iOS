Pod::Spec.new do |spec|
  spec.name         = 'ABMagicDeeplink'
  spec.version      = '1.0.6'
  spec.summary      = 'Magic Deeplinking Implementation'
  spec.description  = "Definition of deep linking router and protocols to enforce ViewController adherence to deep linking infrastructure"
  spec.license = { :type => 'Commercial', :text => 'Created and licensed by Albertsons Companies. Copyright Albertsons Companies, LLC. All rights reserved.' }
  spec.homepage     = 'https://github.com/kiransar/ABMagicDeeplink-iOS.git'
  spec.authors      = { 'Jonathan Banks' => 'jbank95@safeway.com',
                        'Kirankumar Sarvaiya' => 'ksarv05@safeway.com' }
  spec.source       = { :git => 'https://github.com/kiransar/ABMagicDeeplink-iOS.git', :tag => "#{spec.version}" }
  spec.source_files = 'ABMagicDeeplink/Classes/*'
  spec.swift_version = "5.3"
  spec.platform      =  :ios, "11.0"
  spec.static_framework = true
end
