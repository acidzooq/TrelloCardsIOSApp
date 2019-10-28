# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'cardsApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!


# pod 'OAuthSwiftAlamofire'
# pod 'SDWebImage', '~> 4.0'
pod 'Alamofire', '< 5.0'
pod 'SwiftyJSON'
#pod 'Starscream', '<= 3.0.5'
#pod 'AlamofireOAuth1'
  target 'cardsAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'  # required by simple_permission
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
