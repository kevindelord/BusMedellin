//
//  Analytics.swift
//  BusMedellin
//
//  Created by Kevin Delord on 24/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import Firebase

struct Analytics {

	static func setup() {
		// Check if the analytics is enabled
		guard (Configuration.isAnalyticsEnabled == true) else {
			return
		}

		// Set the Firebase log to the minimum required.
		FirebaseConfiguration.shared.setLoggerLevel(.min)
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
	}

	// MARK: - Send Actions

	private static func send(category: Analytics.Category, action: String, label: String?, value: NSNumber?) {
		// Check if the analytics is enabled
		guard (Configuration.isAnalyticsEnabled == true) else {
			return
		}

		var params: [String: Any] = [
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

extension Analytics {

	// MARK: - Categories

	fileprivate enum Category				: String {

		case PinLocation					= "PinLocation"
		case UserLocation					= "UserLocation"
		case Route							= "Route"
		case Search							= "Search"
	}

	// MARK: - Actions type

	enum PinLocation						: String {

		case didSetStart					= "Pin_DidSetStart"
		case didSetDestination				= "Pin_DidSetDestination"
		case didCancelStart					= "Pin_DidCancelStart"
		case didCancelDestination			= "Pin_DidCancelDestination"

		func send() {
			Analytics.send(category: .PinLocation, action: self.rawValue, label: nil, value: nil)
		}
	}

	enum UserLocation						: String {

		case didLocateUser					= "Location_LocateUser"
		case didLocateUserTooFar			= "Location_UserTooFar"
		case didAskForSettings				= "Location_AskForSettings"
		case didOpenSettings				= "Location_OpenSettings"
		case didCancelLocationPopup			= "Location_CancelAuthorization"
		case didAskForUserLocation			= "Location_RequestAuthorization"

		func send() {
			Analytics.send(category: .UserLocation, action: self.rawValue, label: nil, value: nil)
		}
	}

	enum Route								: String {

		case didDrawRoute					= "Route_DidDrawRoute"
		case didSelectRoute					= "Route_DidSelectRoute"

		func send(routeCode: String? = nil, rounteCount: Int? = 0) {
			var value: NSNumber?
			if let rounteCount = rounteCount {
				value = NSNumber(value: rounteCount)
			}

			Analytics.send(category: .Route, action: self.rawValue, label: routeCode, value: value)
		}
	}

	enum Search								: String {

		case routes							= "Search_Routes"

		func send(routeCode: String? = nil, rounteCount: Int? = 0) {
			var value: NSNumber?
			if let rounteCount = rounteCount {
				value = NSNumber(value: rounteCount)
			}

			Analytics.send(category: .Search, action: self.rawValue, label: nil, value: value)
		}
	}
}
