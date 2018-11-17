//
//  Map.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

struct Map {

	static let defaultSearchRadius	= 500.0
	static let defaultZoomRadius	: Double = 3300
	static let deltaAfterSearch		= 0.007
	static let maxScrollDistance	: Double = 12000.0
	static let circleColorAlpha		: CGFloat = 0.3
	static let polylineWidth		: CGFloat = 2

	struct Address {

		static let Street			= "Street"
	}

	/// Default city center location
	static var cityCenterLocation	: CLLocation {
		let config = Configuration()
		let latitude = (Double(config.defaultLatitude) ?? 0)
		let longitude = (Double(config.defaultLongitude) ?? 0)
		return CLLocation(latitude: latitude, longitude: longitude)
	}
}
