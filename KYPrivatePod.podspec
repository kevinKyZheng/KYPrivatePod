#
# Be sure to run `pod lib lint KYPrivatePod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KYPrivatePod'
  s.version          = '0.1.1'
  s.summary          = 'Zheng kaiyuan add the new summary'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a description you need to add by Ky
                       DESC

  s.homepage         = 'https://github.com/kevinKYZheng/KYPrivatePod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kevin_zhengky@163.com' => 'zhengkaiyuan@chinawutong.com' }
  s.source           = { :git => 'https://github.com/kevinKYZheng/KYPrivatePod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_versions = '4.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'KYPrivatePod/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KYPrivatePod' => ['KYPrivatePod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
