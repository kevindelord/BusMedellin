source 'https://github.com/cocoapods/specs.git'

platform :ios, '9.3'
use_frameworks!
inhibit_all_warnings!

target 'BusMedellin' do
	pod 'Appirater', '~> 2.3.1'
	pod 'Buglife', '~> 2.10.1'
	pod 'SwiftLint', '~> 0.35.0'
	pod 'CHIPageControl/Jalapeno', '~> 0.2'

	# Google Analytics + Crash Reports
	pod 'Firebase/Analytics', '~> 6.10.0'
	pod 'Firebase/Performance', '~> 6.10.0'
	pod 'Fabric', '~> 1.10.2'
	pod 'Crashlytics', '~> 3.14.0'
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
