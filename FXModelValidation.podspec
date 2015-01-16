Pod::Spec.new do |s|
  s.name          = "FXModelValidation"
  s.version       = "1.0.4"
  s.summary       = "FXModelValidation is an Objective-C library that allows to validate data/model/forms easily. Suits for any NSObject."  
  s.homepage      = "http://github.com/plandem/FXModelValidation"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "Andrey Gayvoronsky" => "plandem@gmail.com" }
  s.source        = { :git => "https://github.com/plandem/FXModelValidation.git", :tag => s.version.to_s }

  s.framework     = 'Foundation', 'CoreGraphics'
  s.requires_arc  = true
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.prefix_header_contents = '#define FXMODELVALIDATION_FXFORMS 1'
  s.source_files = 'FXModelValidation/*.{h,m}', 'FXModelValidation/validators/*.{h,m}', 'FXModelValidation/validators/filters/*.{h,m}'
end
