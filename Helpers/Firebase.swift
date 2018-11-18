//
//  Firebase.swift
//  BusMedellin
//
//  Created by kevindelord on 30/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Firebase

// TODO: Use different log events.

// MARK: - Firebase

struct Firebase {

	static func setup() {
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
	}

	static func send(category: String, action: String, label: String?, value: NSNumber?) {
		var params : [String: Any] = [
			AnalyticsParameterContentType: action,
			AnalyticsParameterItemName: action,
			AnalyticsParameterItemCategory: category
		]

		if let _label = label {
			params[AnalyticsParameterItemVariant] = _label
		}

		if let _value = value {
			params[AnalyticsParameterValue] = _value
		}

		FirebaseAnalytics.Analytics.logEvent(AnalyticsEventSelectContent, parameters: params)
	}
}
