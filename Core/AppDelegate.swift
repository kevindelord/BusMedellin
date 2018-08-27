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

    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appirater.setup()
		HockeySDK.setup()
		Analytics.setup()

		if let buglifeIdentifier = Bundle.main.stringEntryInPList(for: BMPlist.BuglifeID) {
        	Buglife.shared().start(withAPIKey: buglifeIdentifier)
		}

        return true
    }
}
