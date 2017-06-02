#
# Be sure to run `pod lib lint AWSWrapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AWSWrapper'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AWSWrapper.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/lyc2345/AWSWrapper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lyc2345' => 'lyc2345@gmail.com' }
  s.source           = { :git => 'https://github.com/lyc2345/AWSWrapper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.ios.resource_bundles    = {
  'Resources' => ['AWSWrapper/**/*.{png,storyboard,lproj}']
  }

  s.source_files = 'AWSWrapper/Classes/**/*'

  s.ios.dependency 'AWSCognito', '~> 2.5.7'
  s.ios.dependency 'AWSCognitoIdentityProvider', '~> 2.5.7'
  s.ios.dependency 'AWSDynamoDB', '~> 2.5.7'
  s.ios.dependency 'AWSCore', '~> 2.5.7'
  s.ios.dependency 'AWSS3'


  s.ios.vendored_frameworks = 'AWSWrapper/*.{framework}'



end
