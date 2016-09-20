# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'teferi' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for teferi
    pod 'RxSwift',    '~> 3.0.0-beta.1'
    pod 'RxCocoa',    '~> 3.0.0-beta.1'
    pod 'HockeySDK', '~> 4.1.1'

  target 'teferiTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift',    '~> 3.0.0-beta.1'
  end
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '3.0'
              config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
          end
      end
  end
end
