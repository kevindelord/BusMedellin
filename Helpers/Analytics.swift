//
//  Analytics.swift
//  BusMedellin
//
//  Created by Kevin Delord on 24/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

struct Analytics {

	static func setup() {
		// Check if the analytics is enabled
		if (Configuration.analyticsEnabled == false) {
			return
		}

		// Firebase
		Firebase.setup()
	}

	// MARK: - Send Actions

	private static func send(category: String, action: String, label: String?, value: NSNumber?) {
		// Check if the analytics is enabled
		if (Configuration.analyticsEnabled == false) {
			return
		}

		// Firebase
		Firebase.send(category: category, action: action, label: label, value: value)
	}

	static func send(screenView screen: Analytics.Screen) {
		// Check if the analytics is enabled
		if (Configuration.analyticsEnabled == false) {
			return
		}

		// Firebase
		Firebase.send(screenView: screen)
	}

	// MARK: - Actions type

	enum Screen {

		case mapView
		case settings

		var name: String {
			switch self {
			case .mapView					: return "Screen_MapView"
			case .settings					: return "Screen_Settings"
			}
		}

		var screenClass: String {
			switch self {
			case .mapView					: return "BMCollectionViewController"
			case .settings					: return "BMSettingsViewController"
			}
		}
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
