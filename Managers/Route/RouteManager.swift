//
//  RouteManager.swift
//  BusMedellin
//
//  Created by kevindelord on 02/09/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import CoreLocation

class RouteManager				: RouteManagerDataSource {

	var availableRoutes			= [Route]()
	var selectedRoute			: Route?

	func routes(between start: CLLocationCoordinate2D, and destination: CLLocationCoordinate2D, with radius: Double, completion: @escaping ((_ error: Error?) -> Void)) {
		// Fetch all routes passing by the pick up location.
		self.fetchRoutes(forCoordinates: start, with: radius, completion: { (pickUpRoutes: [Route], error: Error?) in
			guard (error == nil) else {
				completion(error)
				return
			}

			// Fetch all routes passing by the destination location.
			self.fetchRoutes(forCoordinates: destination, with: radius, completion: { (destinationRoutes: [Route], error: Error?) in
				guard (error == nil) else {
					// Reset retained search results.
					self.cancelSearch()
					completion(error)
					return
				}

				// Filter the routes to only the ones matching.
				self.availableRoutes = self.findMatchingRoutes(pickUpRoutes: pickUpRoutes, destinationRoutes: destinationRoutes)
				self.selectedRoute = self.availableRoutes.first
				// Analytics
				Analytics.Search.routes.send(routeCode: nil, rounteCount: self.availableRoutes.count)
				// Check in the end if at least one route has been found.
				completion((self.selectedRoute == nil ? RouteCollector.Invalid.routes.localizedError : nil))
			})
		})
	}

	func routeCoordinates(for routeCode: String, completion: @escaping ((_ coordinates: [CLLocationCoordinate2D], _ error: Error?) -> Void)) {
		RouteCollector.coordinates(forRouteCode: routeCode, success: { (coordinates: [[Double]]) in
			let locationCoordinates = self.createLocations(fromCoordinates: coordinates)
			completion(locationCoordinates, nil)
		}, failure: { (error: Error) in
			completion([], error)
		})
	}

	func address(forLocation location: CLLocation, completion: @escaping ((_ address: String?, _ error: Error?) -> Void)) {
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

// MARK: - RouteDataSourceHandler

extension RouteManager: RouteManagerDelegate {

	func cancelSearch() {
		self.selectedRoute = nil
		self.availableRoutes = []
	}

	func select(route: Route) {
		self.selectedRoute = route
	}
}

// MARK: - Private Functions

extension RouteManager {

	/// Filter the available routes to only the ones going through both PICKUP and DESTINATION annotation areas.
	///
	/// - Parameters:
	///   - pickUpRoutes: All routes going through the PICKUP annotation area.
	///   - destinationRoutes: All routes going through the DESTINATION annotation area.
	/// - Returns: Array of matching routes that go through both PICKUP and DESTINATION annotation areas.
	private func findMatchingRoutes(pickUpRoutes: [Route], destinationRoutes: [Route]) -> [Route] {
		var commonRoutes = [Route]()
		for pickUpRoute in pickUpRoutes {
			for destinationRoute in destinationRoutes
				where (destinationRoute.code == pickUpRoute.code) {
					commonRoutes.append(destinationRoute)
			}
		}

		return commonRoutes
	}

	/// Transform an array of latitudes and longitudes into an array of CLLocationCoordinate2D.
	///
	/// - Parameter coordinates: Array of latitudes and longitudes.
	/// - Returns: Array of CLLocationCoordinate2D.
	private func createLocations(fromCoordinates coordinates: [[Double]]) -> [CLLocationCoordinate2D] {
		var pointsToUse = [CLLocationCoordinate2D]()
		for values in coordinates {
			guard
				let y = values[safe: 0],
				let x = values[safe: 1] else {
					continue
			}

			pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(x), CLLocationDegrees(y))]
		}

		return pointsToUse
	}

	/// Fetch all bus routes around given coordinates.
	///
	/// - Parameters:
	///   - coordinates: The coordinates to search for routes around.
	///   - radius: Search radius in meters.
	///   - completion: Completion closure with the available routes at specific coordinates and an optional error object.
	private func fetchRoutes(forCoordinates coordinates: CLLocationCoordinate2D, with radius: Double, completion: @escaping ((_ routes: [Route], _ error: Error?) -> Void)) {
		let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
		self.fetchRoutes(forLocation: location, with: radius, completion: completion)
	}

	/// Fetch all bus routes around a given location.
	///
	/// - Parameters:
	///   - location: The location to search for routes around it.
	///   - radius: Search radius in meters.
	///   - completion: Completion closure with the available routes at a specific location and an optional error object.
	private func fetchRoutes(forLocation location: CLLocation, with radius: Double, completion: @escaping ((_ routes: [Route], _ error: Error?) -> Void)) {
		RouteCollector.routes(aroundLocation: location, with: radius, success: { (routes: [Route]) in
			completion(routes, nil)
		}, failure: { (error: Error) in
			completion([], error)
		})
	}
}
