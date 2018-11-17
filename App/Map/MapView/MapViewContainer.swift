//
//  MapViewContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

protocol MapViewContainer: HUDContainer {

	/// Add an annotation at the center of the map view for a specific kind of Location.
	///
	/// - Parameter location: Related Location.
	/// - Returns: The CoreLocation of the center of the screen where the pin annotation has been added.
	func addAnnotation(forLocation location: Location) -> CLLocationCoordinate2D?

	/// Draw on the map the given bus Route.
	///
	/// - Parameters:
	///   - selectedRoute: Selected bus Route to draw on the map.
	///   - routeDataSource: Data Source to get exact CoreLocation objects necessary to draw the related route.
	func draw(selectedRoute: Route, routeDataSource: RouteManagerDataSource)

	/// Center the map on a specific location.
	///
	/// - Parameter location: Location to center the map to.
	func centerMap(on location: CLLocation)
}
