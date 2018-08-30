//
//  Firebase.swift
//  BusMedellin
//
//  Created by kevindelord on 30/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Firebase

// MARK: - Firebase

struct Firebase {

	static func setup() {
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
	}

	static func send(category: String, action: String, label: String?, value: NSNumber?) {
		var params = [AnalyticsParameterContentType: action as NSObject, AnalyticsParameterItemCategory: category as NSObject]
		if let _label = label {
			params[AnalyticsParameterItemName] = _label as NSObject
		}

		if let _value = value {
			params[AnalyticsParameterValue] = _value as NSObject
		}

		FirebaseAnalytics.Analytics.logEvent(AnalyticsEventSelectContent, parameters: params)
	}

	static func send(screenView screen: Analytics.Screen) {
		FirebaseAnalytics.Analytics.setScreenName(screen.name, screenClass: screen.screenClass)
	}
}
