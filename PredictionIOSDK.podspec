Pod::Spec.new do |spec|
  spec.name = 'PredictionIOSDK'
  spec.version = '0.1.0'
  spec.license = 'MIT'
  spec.summary = ''
  spec.homepage = 'https://github.com/minhtule/PredictionIO-iOS-SDK'
  spec.authors = { 'Minh-Tu Le' => 'minhtule05@gmail.com' }
  spec.source = { :git => 'https://github.com/minhtule/PredictionIO-iOS-SDK.git', :tag => spec.version }
  spec.source_files = 'PredictionIOSDK/*.swift'

  # Platform
  spec.platform = :ios
  spec.ios.deployment_target = '8.0'
  
  # Build settings
  spec.requires_arc = true

  # Dependencies
  # spec.dependency 'Alamofire', '~> 1.1'
  
end
