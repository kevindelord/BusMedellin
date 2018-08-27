//
//  HockeySDK.swift
//  BusMedellin
//
//  Created by Kevin Delord on 24/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import HockeySDK

struct HockeySDK {

	// MARK: - Private Properties

	private static var isReleaseBuild: Bool {
		#if RELEASE
			return true
		#else
			return false
		#endif
	}

	// MARK: - Methods

	/**
	This will setup the HockeySDK with the common base configuration. Crashes will be detected if the app is build with the release build type and the `HockeyAppId` token taken from the info plists.

	- parameter crashManagerStatus: The `BITCrashManagerStatus` which determines whether crashes should be send to HockeyApp and whether it should be done automatically or manually by the user. The default value is `AutoSend`.
	*/
	static func setup(crashManagerStatus: BITCrashManagerStatus = .autoSend) {
		if (self.isReleaseBuild == true) {
			BITHockeyManager.shared().configure(withIdentifier: Configuration().hockeyAppIdentifier)
			BITHockeyManager.shared().start()
			BITHockeyManager.shared().authenticator.authenticateInstallation()
			BITHockeyManager.shared().crashManager.crashManagerStatus = crashManagerStatus
		}
	}
}
