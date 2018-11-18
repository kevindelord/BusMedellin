source 'https://github.com/cocoapods/specs.git'

platform :ios, '9.3'
use_frameworks!

target 'BusMedellin' do
	pod 'Reachability', '~> 3.2'
	pod 'Appirater', '~> 2.3.1'
	pod 'MBProgressHUD', '~> 1.1.0'
	pod 'Buglife', '~> 2.8.1'
	pod 'HockeySDK', '~> 5.1.2'
	pod 'SwiftLint', '~> 0.28.0'
	pod 'Firebase/Core', '~> 5.12.0'
end

post_install do |installer|

	installer.pods_project.targets.each do |target|
		if target.name.include?("Pods-")
			require 'fileutils'
			FileUtils.cp_r('Pods/Target Support Files/' + target.name + '/' + target.name + '-acknowledgements.plist',
			'Resources/Settings.bundle/Pods-acknowledgements.plist', :remove_destination => true)
		end

		target.build_configurations.each do |config|
			config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
			config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
			config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
		end
	end
end
