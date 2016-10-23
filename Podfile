source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

def corePods
    pod 'Reachability', '~> 3.2'
	pod 'Appirater', '~> 2.0.5'
	pod 'AFNetworking', '~> 3.0.4'
#	pod 'MBProgressHUD', '~> 0.9.1'
    pod 'CSStickyHeaderFlowLayout'
	pod 'DKHelper', '~> 2.2.3'
    pod 'Buglife', '~> 1.3.3'
end

target 'BusMedellin-Alpha' do
    corePods
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
