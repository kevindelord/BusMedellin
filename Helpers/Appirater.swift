//
//  Appirater.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import Appirater

// TODO: Test Appirater+Storekit on iOS 10.3 and newer. https://github.com/arashpayan/appirater

extension Appirater {

	class func setup() {
		Appirater.setAppId(Configuration().appIdentifier)
		Appirater.setDaysUntilPrompt(3)
		Appirater.setUsesUntilPrompt(3)
		Appirater.setSignificantEventsUntilPrompt(-1)
		Appirater.setTimeBeforeReminding(7)
		Appirater.setDebug(Configuration.debugAppirater)
		Appirater.appLaunched(true)
	}
}
