platform :ios, '11.0'
use_frameworks!

target 'TheBarCode' do
  
  
  pod 'Alamofire', '~> 4.7.3'
  pod 'ObjectMapper', '~> 3.5.1'
  pod 'Gradientable', '~> 0.0.2'
  pod 'Reusable', '~> 4.0.3'
  pod 'UIColor_Hex_Swift', '~> 4.0.2'
  pod 'PureLayout', '~> 3.1.5'
  pod 'GoogleMaps', '~> 3.7.0'
  pod 'StatefulTableView', '~> 0.1.5'
  pod 'TPKeyboardAvoiding', '~> 1.3.2'
  pod 'FSPagerView', '~> 0.7.2'
  pod 'SJSegmentedScrollView', '~> 1.3.9'
  pod 'SwiftyJSON', '~> 4.2.0'
  pod 'KeychainAccess', '~> 3.1.2'
  pod 'CoreStore', '~> 6.3.2'
  pod 'FBSDKLoginKit', '~> 7.1.1'
  pod 'SDWebImage', '~> 4.4.2'
  pod 'HTTPStatusCodes', '~> 3.3.1'
  
  pod 'Firebase/Core', '~> 6.34.0'
  pod 'Firebase/DynamicLinks', '~> 6.34.0'
  pod 'Firebase/Crashlytics', '~> 6.34.0'
  pod 'Firebase/Analytics', '~> 6.34.0'
  
  pod 'OneSignal', '~> 2.13.0'
  pod 'MGSwipeTableCell', '~> 1.6.7'
  pod 'GBDeviceInfo', '~> 5.5.0'
  pod 'BugfenderSDK', '~> 1.7'
  pod 'DTCoreText', '~> 1.6.23'
  
  pod 'KMPlaceholderTextView', '~> 1.4.0'
  
  pod 'AFNetworking', '~> 2.5.4'
  
  pod 'EasyNotificationBadge', '~> 1.2.0'

  pod 'KVNProgress', '~> 2.3.5'

  pod 'MLLabel', '~> 1.10.5'
  
  pod 'RNCryptor', '~> 5.1.0'
  
  pod 'DropDown', '~> 2.3.2'

  pod 'SquareInAppPaymentsSDK', '~> 1.4.0'
  pod 'SquareBuyerVerificationSDK', '~> 1.3.0'

  target 'TheBarCodeTests' do
    inherit! :search_paths
    
  end

  target 'TheBarCodeUITests' do
    inherit! :search_paths
    
  end

end

post_install do |installer|
        installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
            deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
            target_components = deployment_target.split

            if target_components.length > 0
              target_initial = target_components[0].to_i
              if target_initial < 9
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "9.0"
              end
            end
          end
        end
    end

target 'OneSignalNotificationServiceExtension' do
    pod 'OneSignal', '~> 2.13.0'
end
