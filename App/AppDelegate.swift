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
		Appirater.setup()
		Analytics.setup()
		Buglife.shared().start(withAPIKey: Configuration().buglifeIdentifier)
		RouteDatabase.setup()

		return true
	}
}
