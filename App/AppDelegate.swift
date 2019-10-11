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
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		Appirater.setup()
		Analytics.setup()
		Buglife.shared().start(withAPIKey: Configuration().buglifeIdentifier)
		// Use Firebase library to configure APIs
		FirebaseApp.configure()

		// In the end setup the local database (must happen after Firebase to monitor the performances).
		RouteDatabase.setup()

		return true
	}
}
