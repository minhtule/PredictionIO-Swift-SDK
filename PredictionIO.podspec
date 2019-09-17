Pod::Spec.new do |spec|
  spec.name = 'PredictionIO'
  spec.version = '2.1.0'
  spec.license = 'Apache 2.0'
  spec.summary = 'The iOS SDK that provides easy-to-use functions to integrate with PredictionIO REST API services'
  spec.homepage = 'https://github.com/minhtule/PredictionIO-Swift-SDK'
  spec.authors = { 'Minh-Tu Le' => 'minhtule05@gmail.com' }
  spec.source = { :git => 'https://github.com/minhtule/PredictionIO-Swift-SDK.git', :tag => spec.version }
  spec.source_files = 'PredictionIO/Source/*.swift'
  spec.swift_versions = ['5.0', '5.1']

  # Platform
  spec.platform = :ios
  spec.ios.deployment_target = '10.0'
  spec.osx.deployment_target = '10.10'

  # Build settings
  spec.requires_arc = true

end
