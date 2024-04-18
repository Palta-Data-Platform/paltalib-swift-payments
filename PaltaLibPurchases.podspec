Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibPurchases'
  spec.version               = '3.3.1'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Purchases'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-swift-payments.git', :tag => "#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '13.0'
  spec.swift_versions        = '5.3'

  spec.source_files = 'Sources/**/*.swift'

  spec.dependency 'PaltaCore', '>= 3.2.2'
  spec.dependency 'RevenueCat', '~> 4.7.0'
end

