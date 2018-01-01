Pod::Spec.new do |spec|
  spec.name = 'PredictionIOSDK'
  spec.version = '0.2.0'
  spec.license = 'MIT'
  spec.summary = 'The iOS SDK that provides easy-to-use functions to integrate with PredictionIO REST API services'
  spec.homepage = 'https://github.com/minhtule/PredictionIO-iOS-SDK'
  spec.authors = { 'Minh-Tu Le' => 'minhtule05@gmail.com' }
  spec.source = { :git => 'https://github.com/minhtule/PredictionIO-iOS-SDK.git', :tag => spec.version }
  spec.source_files = 'PredictionIOSDK/*.swift'

  # Platform
  spec.platform = :ios
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  
  # Build settings
  spec.requires_arc = true

  # Dependencies
  spec.dependency 'Alamofire', '~> 1.2'
end
