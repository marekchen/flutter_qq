#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_qq'
  s.version          = '0.0.5'
  s.summary          = 'Flutter plugin for QQ.'
  s.static_framework = true
  s.description      = <<-DESC
Flutter plugin for QQ.
                       DESC
  s.homepage         = 'https://github.com/marekchen/flutter_qq'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'marekchen' => 'c491843272@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'QQSDK'
  
  s.ios.deployment_target = '8.0'
end

