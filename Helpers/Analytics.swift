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
		if (Configuration.analyticsEnabled == false) {
			return
		}

		// Firebase
		Firebase.setup()

		// Google Analytics
		GoogleAnalytics.setup()
	}

	// MARK: - Send Actions

	private static func send(category: String, action: String, label: String?, value: NSNumber?) {
		// Check if the analytics is enabled
		if (Configuration.analyticsEnabled == false) {
			return
		}

		// Google Analytics
		GoogleAnalytics.send(category: category, action: action, label: label, value: value)

		// Firebase
		Firebase.send(category: category, action: action, label: label, value: value)
	}

	static func send(screenView screen: Analytics.Screen) {
		// Check if the analytics is enabled
		if (Configuration.analyticsEnabled == false) {
			return
		}

		// Google Analytics
		GoogleAnalytics.send(screenView: screen)

		// Firebase
		Firebase.send(screenView: screen)
	}

	// MARK: - Actions type

	enum Screen								: String {

		case mapView						= "Screen_MapView"
		case settings						= "Screen_Settings"
	}

	enum PinLocation						: String {

		static let categoryId				= "PinLocation"

		case didSetStart					= "Pin_DidSetStart"
		case didSetDestination				= "Pin_DidSetDestination"
		case didCancelStart					= "Pin_DidCancelStart"
		case didCancelDestination			= "Pin_DidCancelDestination"

		func send() {
			let category = Analytics.PinLocation.categoryId
			Analytics.send(category: category, action: self.rawValue, label: nil, value: nil)
		}
	}

	enum UserLocation						: String {

		static let categoryId				= "UserLocation"

		case didLocateUser					= "UserLocation_DidLocateUser"
		case didLocateUserTooFar			= "UserLocation_DidLocateUserTooFar"
		case didAskForSettings				= "UserLocation_DidAskForSettings"
		case didAskForUserLocation			= "UserLocation_DidAskForUserLocation"

		func send() {
			let category = Analytics.UserLocation.categoryId
			Analytics.send(category: category, action: self.rawValue, label: nil, value: nil)
		}
	}

	enum Route								: String {

		static let categoryId				= "Route"
		static let labelSearch				= "Search"

		case didDrawRoute					= "Route_DidDrawRoute"
		case didSelectRoute					= "Route_DidSelectRoute"
		case didSearchForMatchingRoutes		= "Route_DidSearchForMatchingRoutes"
		case didSearchForStartRoutes		= "Route_DidSearchForStartRoutes"
		case didSearchForDestinationRoutes	= "Route_DidSearchForDestinationRoutes"

		func send(routeCode: String? = nil, rounteCount: Int? = 0) {
			let category = Analytics.Route.categoryId
			var value: NSNumber?
			if let rounteCount = rounteCount {
				value = NSNumber(value: rounteCount)
			}

			switch self {
			case .didDrawRoute, .didSelectRoute:
				Analytics.send(category: category, action: self.rawValue, label: routeCode, value: value)
			case .didSearchForMatchingRoutes, .didSearchForStartRoutes, .didSearchForDestinationRoutes:
				Analytics.send(category: category, action: self.rawValue, label: Analytics.Route.labelSearch, value: value)
			}
		}
	}
}

// MARK: - Google Analytics

private struct GoogleAnalytics {

	fileprivate static func setup() {
		// Configure tracker from GoogleService-Info.plist.
		// Optional: configure GAI options.
		guard let gai = GAI.sharedInstance() else {
			assert(false, "Google Analytics not configured correctly")
		}

		gai.tracker(withTrackingId: "YOUR_TRACKING_ID")
		gai.trackUncaughtExceptions = true // Report uncaught exceptions
		#if RELEASE
		gai.logger.logLevel = .Error
		#else
		gai.logger.logLevel = (Configuration.Verbose.analytics == true ? .verbose : .none)
		#endif
	}

	// MARK: - Send Actions

	fileprivate static func send(category: String, action: String, label: String?, value: NSNumber?) {
		guard
			let event = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value),
			let dictionary = event.build() as? [AnyHashable: Any] else {
				return
		}

		GAI.sharedInstance().defaultTracker.send(dictionary)
	}

	static func send(screenView screen: Analytics.Screen) {
		guard
			let builder = GAIDictionaryBuilder.createScreenView(),
			let tracker = GAI.sharedInstance().defaultTracker,
			let info = builder.build() as? [AnyHashable: Any] else {
				return
		}

		tracker.set(kGAIScreenName, value: screen.rawValue)
		tracker.send(info)
	}
}

// MARK: - Firebase

private struct Firebase {

	fileprivate static func setup() {
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
	}

	fileprivate static func send(category: String, action: String, label: String?, value: NSNumber?) {
		var params = [AnalyticsParameterContentType: action as NSObject, kFIRParameterItemCategory: category as NSObject]
		if let _label = label {
			params[AnalyticsParameterItemName] = _label as NSObject
		}

		if let _value = value {
			params[AnalyticsParameterValue] = _value as NSObject
		}

		Analytics.logEvent(withName: kFIREventSelectContent, parameters: params)
	}

	static func send(screenView screen: Analytics.Screen) {
		let params = [kFIRParameterItemName: screen.rawValue as NSObject, kFIRParameterItemCategory: kGAIScreenName as NSObject]
		FIRAnalytics.logEvent(withName:kFIREventSelectContent, parameters: params)
	}
}
