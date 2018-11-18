//
//  MapActionDelegate.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

/// Delegate for possible user actions on the map view.
protocol MapActionDelegate: AnyObject {

	/// Function called when the user cancel a location-based search
	///
	/// - Parameter location: Location cancelled by the user (e.g. either the pickUp or destination address).
	func cancel(location: Location)

	/// Function called when the user assigned a pin position for a specific address.
	/// Same logic than assigning an real street address to a Location.
	///
	/// - Parameter location: Related Location.
	func pinPoint(location: Location)

	/// Center the map on a specific location.
	///
	/// - Parameter location: Location to center the map to.
	func centerMap(on location: CLLocation)

	/// Update after the notifications received from the MapKit delegate functions.
	func updateUserLocation(_ location: MKUserLocation)
}
