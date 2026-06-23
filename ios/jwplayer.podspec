#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint jwplayer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'jwplayer'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for embedding JWPlayer vertical video.'
  s.description      = <<-DESC
A Flutter plugin that bridges the native JWPlayerKit SDK to display vertical
videos on iOS and Android via a platform view. Supports both CocoaPods and
Swift Package Manager.
                       DESC
  s.homepage         = 'https://github.com/KQED/jwplayer-flutter-plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KQED' => 'mobile@kqed.org' }
  s.source           = { :path => '.' }
  s.source_files = 'jwplayer/Sources/jwplayer/**/*.swift'
  s.dependency 'Flutter'
  # Target the latest JWPlayerKit 4.x line (4.25.x and above)
  s.dependency 'JWPlayerKit', '>= 4.25.0'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
