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
        Buglife.shared().start(withAPIKey: Bundle.stringEntryInPList(forKey: BMPlist.BuglifeID))
        HockeySDK.setup()
        Analytics.setup()

        return true
    }
}
