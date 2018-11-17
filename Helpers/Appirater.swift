//
//  Appirater.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import Appirater

extension Appirater {

	class func setup() {
		Appirater.setAppId(Configuration().appIdentifier)
		Appirater.setDaysUntilPrompt(0)
		Appirater.setUsesUntilPrompt(0)
		Appirater.setSignificantEventsUntilPrompt(3)
		Appirater.setTimeBeforeReminding(1)
		Appirater.setDebug(Configuration.debugAppirater)
		Appirater.appLaunched(true)
	}

	class func triggerSignificantEvent() {
		Appirater.userDidSignificantEvent(true)
	}
}
