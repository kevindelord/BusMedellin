source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

def corePods
    pod 'Reachability', '~> 3.2'
	pod 'Appirater', '~> 2.3.1'
	pod 'MBProgressHUD', '~> 1.1.0'
    pod 'CSStickyHeaderFlowLayout', '~> 0.2.11'
	pod 'Buglife', '~> 1.9.5' # Versions >= 2.0.0 require min iOS 9.0
    pod 'HockeySDK', '~> 5.1.2'
	pod 'SwiftLint', '~> 0.27.0'
end

def analytics
    pod 'Google/Analytics'
    pod 'Firebase/Core'
end

target 'BusMedellin-Alpha-AdHoc' do
    corePods
	analytics
end

target 'BusMedellin-Live-AppStore' do
    corePods
	analytics
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
