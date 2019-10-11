//
//  AppDelegate.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import Appirater
import Buglife

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		// AppStore user ratings
		Appirater.setup()
		// Firebase Frameworks: Performance, Analytics, Crashlytics.
		Firebase.setup()
		// User Bug Reports
		Buglife.shared().start(withAPIKey: Configuration().buglifeIdentifier)

		// In the end setup the local database (must happen after Firebase to monitor the performances).
		RouteDatabase.setup()

		return true
	}
}
