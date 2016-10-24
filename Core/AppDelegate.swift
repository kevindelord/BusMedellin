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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appirater.setup()
        Buglife.sharedBuglife().startWithAPIKey(NSBundle.stringEntryInPListForKey(BMPlist.BuglifeID))
        HockeySDK.setup()

        return true
    }
}
