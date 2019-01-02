#
# Be sure to run `pod lib lint LNSideMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LNSideMenu'
  s.version          = '3.4.4'
  s.summary          = 'A side menu control for iOS in Swift with custom layer and scrolling effect. Right and Left sides. iOS 8+.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Based on the side menu libraries that have already published on github, this side menu have a little bit custom the layer and scrolling effect.
                          DESC

  s.homepage         = 'https://github.com/luannguyenkhoa/LNSideMenu'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luan Nguyen' => 'luan.nguyenkhoa@asnet.com.vn' }
  s.source           = { :git => 'https://github.com/luannguyenkhoa/LNSideMenu.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source_files = 'LNSideMenu/Classes/**/*'

  # s.resource_bundles = {
  #   'LNSideMenu' => ['LNSideMenu/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
end
