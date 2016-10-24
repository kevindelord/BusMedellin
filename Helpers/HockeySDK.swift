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

	// MARK: - Public Properties

	static let IdentifierKey	= "HockeyAppId"

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
	static func setup(crashManagerStatus: BITCrashManagerStatus = .AutoSend) {
		if let _identifier = NSBundle.mainBundle().objectForInfoDictionaryKey(IdentifierKey) as? String {
			if (self.isReleaseBuild == true) {
				BITHockeyManager.sharedHockeyManager().configureWithIdentifier(_identifier)
				BITHockeyManager.sharedHockeyManager().startManager()
				BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
				BITHockeyManager.sharedHockeyManager().crashManager.crashManagerStatus = crashManagerStatus
			}
		} else {
			print("Warning: You have to set the `\(IdentifierKey)` key in the info plist.")
		}
	}
}
