Pod::Spec.new do |spec|
  spec.name = 'PredictionIO'
  spec.version = '1.0.0'
  spec.license = 'Apache 2.0'
  spec.summary = 'The iOS SDK that provides easy-to-use functions to integrate with PredictionIO REST API services'
  spec.homepage = 'https://github.com/minhtule/PredictionIO-Swift-SDK'
  spec.authors = { 'Minh-Tu Le' => 'minhtule05@gmail.com' }
  spec.source = { :git => 'https://github.com/minhtule/PredictionIO-Swift-SDK.git', :tag => spec.version }
  spec.source_files = 'PredictionIO/Source/*.swift'

  # Platform
  spec.platform = :ios
  spec.ios.deployment_target = '10.0'
  spec.osx.deployment_target = '10.10'
  
  # Build settings
  spec.requires_arc = true

end
