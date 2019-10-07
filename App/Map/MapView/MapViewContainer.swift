//
//  MapViewContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

protocol MapViewContainer: AnyObject {

	/// Add an annotation at the center of the map view for a specific kind of Location.
	///
	/// - Parameters:
	///   - location: Related Location.
	///   - radius: Size in meters of the circle around the map.
	/// - Returns: The CoreLocation of the center of the screen where the pin annotation has been added.
	func addAnnotation(forLocation location: Location, radius: Double) -> CLLocationCoordinate2D?

	/// Update the circle around the annotation related to the location.
	///
	/// - Parameters:
	///   - location: Related Location.
	///   - radius: Size in meters of the circle around the map.
	func updateAnnotationCircle(forLocation location: Location, radius: Double)

	/// Draw on the map the given bus Route.
	///
	/// - Parameters:
	///   - selectedRoute: Selected bus Route to draw on the map.
	///   - routeDataSource: Data Source to get exact CoreLocation objects necessary to draw the related route.
	func draw(selectedRoute: Route, routeDataSource: RouteManagerDataSource, completion: @escaping ((_ error: Error?) -> Void))

	/// Center the map on a specific location.
	///
	/// - Parameter location: Location to center the map to.
	func centerMap(on location: CLLocation)

	/// Remove any drawn routes from the mapView.
	func removeDrawnRoutes()
}
