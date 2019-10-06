//
//  RouteManager.swift
//  BusMedellin
//
//  Created by kevindelord on 02/09/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import CoreLocation

class RouteManager {

	var availableRoutes = [Route]()
	var selectedRoute : Route?
}

// MARK: - RouteManagerDataSource

extension RouteManager : RouteManagerDataSource {

	/// Fetch all routes passing by the pick up (aka start) and destination (aka finish) locations.
	public func routes(between start: CLLocationCoordinate2D, and destination: CLLocationCoordinate2D, with radius: Double, completion: @escaping ((_ error: Error?) -> Void)) {
		let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
		let endLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

		RouteCollector.routes(between: startLocation, and: endLocation, with: radius, completion: { (routes: [Route]) in
			// Filter the routes to only the ones matching.
			self.availableRoutes = routes
			self.selectedRoute = self.availableRoutes.first
			// Analytics
			Analytics.Search.routes.send(routeCode: nil, rounteCount: self.availableRoutes.count)
			// Check in the end if at least one route has been found.
			completion((self.selectedRoute == nil ? RouteCollector.Invalid.routes.localizedError : nil))
		})
	}

	public func routeCoordinates(for routeCode: String, completion: @escaping ((_ coordinates: [CLLocationCoordinate2D], _ error: Error?) -> Void)) {
		RouteCollector.coordinates(forRouteCode: routeCode, success: { (coordinates: [CLLocationCoordinate2D]) in
			completion(coordinates, nil)
		}, failure: { (error: Error) in
			completion([], error)
		})
	}

	public func address(forLocation location: CLLocation, completion: @escaping ((_ address: String?, _ error: Error?) -> Void)) {
		let handler = { (placemarks: [CLPlacemark]?, error: Error?) in
			if (error != nil) {
				// Ignore the errors coming from the CLGeocoder.
				// Since the data is coming froma local json the only thing needed is the CLLocation values.
				// The reverse geocode is only necessary for the UI elements but does not provide any real feature.
				completion(L("LOCATION_UNKNOWN"), nil)
				return
			}

			guard let placemark = placemarks?.first else {
				completion(nil, RouteCollector.Invalid.routes.localizedError)
				return
			}

			Log(.pinAddress, "Address found: \(placemark.addressDictionary ?? [:])")
			let street = placemark.addressDictionary?[Map.Address.street] as? String
			let address = placemark.addressDictionary?[Map.Address.formatedAddress] as? String
			completion(street ?? address ?? L("LOCATION_UNKNOWN"), error)
		}

		CLGeocoder().reverseGeocodeLocation(location, completionHandler: handler)
	}
}

// MARK: - RouteManagerDelegate

extension RouteManager: RouteManagerDelegate {

	func cancelSearch() {
		self.selectedRoute = nil
		self.availableRoutes = []
	}

	func select(route: Route) {
		self.selectedRoute = route
	}
}
