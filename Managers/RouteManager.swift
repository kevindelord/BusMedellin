//
//  RouteManager.swift
//  BusMedellin
//
//  Created by kevindelord on 02/09/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import CoreLocation

protocol RouteDataSource {

	/// Fetch the real address of a location using the CLGeocoder.
	///
	/// - Parameters:
	///   - location: The location to find the address.
	///   - completion: Block having as optional parameter the address of the given location.
	func address(forLocation location: CLLocation, completion: @escaping ((_ address: String?) -> Void))

	/// Fetch coordinates of a route using its identifier (aka route code).
	///
	/// - Parameters:
	///   - routeCode: The route identifier used to fetch the coordinates.
	///   - completion: Closure called when the route has been fetched.
	func routeCoordinates(for routeCode: String, completion: @escaping ((_ coordinates: [CLLocationCoordinate2D]) -> Void))

	/// Fetch routes between start and desitnation coordinates.
	///
	/// - Parameters:
	///   - start: Coordinates of the start / pickup annotation.
	///   - destination: Coordinates of the destination annotation.
	///   - completion: Closure called when the matching routes have been fetched.
	func routes(between start: CLLocationCoordinate2D, and destination: CLLocationCoordinate2D, completion: @escaping (() -> Void))

	/// Array of all matching round found for the active search (active start and destination annotations).
	var availableRoutes			: [Route] { get }

	/// Optional selected Route.
	var selectedRoute			: Route? { get }
}


class RouteManager				: RouteDataSource {

	var availableRoutes			= [Route]()
	var selectedRoute			: Route?
}


// MARK: - Route Data Management

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
	///   - completion: Block having as parameter an array of routes passing by the given coordinates.
	private func fetchRoutes(forCoordinates coordinates: CLLocationCoordinate2D, completion: @escaping ((_ routes: [Route]) -> Void)) {
		let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
		self.fetchRoutes(forLocation: location, completion: completion)
	}

	/// Fetch all bus routes around a given location.
	///
	/// - Parameters:
	///   - location: The location to search for routes around it.
	///   - completion: Block having as parameter an array of routes passing by the given location.
	private func fetchRoutes(forLocation location: CLLocation, completion: @escaping ((_ routes: [Route]) -> Void)) {
		APIManager.routes(aroundLocation: location, success: { (routes: [Route]) in
			completion(routes)
		}, failure: { (error: Error) in
			UIAlertController.showErrorPopup(error as NSError?)
			completion([])
		})
	}
}

// MARK: - Route Data Source

extension RouteManager {

	func routes(between start: CLLocationCoordinate2D, and destination: CLLocationCoordinate2D, completion: @escaping (() -> Void)) {
		// Fetch all routes passing by the pick up location.
		self.fetchRoutes(forCoordinates: start, completion: { (pickUpRoutes: [Route]) in
			// Analytics
			Analytics.Search.startRoutes.send(routeCode: nil, rounteCount: pickUpRoutes.count)
			// Fetch all routes passing by the destination location.
			self.fetchRoutes(forCoordinates: destination, completion: { (destinationRoutes: [Route]) in
				// Analytics
				Analytics.Search.destinationRoutes.send(routeCode: nil, rounteCount: destinationRoutes.count)

				// Filter the routes to only the ones matching.
				self.availableRoutes = self.findMatchingRoutes(pickUpRoutes: pickUpRoutes, destinationRoutes: destinationRoutes)
				self.selectedRoute = self.availableRoutes.first
				// Analytics
				Analytics.Search.matchingRoutes.send(routeCode: nil, rounteCount: self.availableRoutes.count)
				completion()
			})
		})
	}

	func routeCoordinates(for routeCode: String, completion: @escaping ((_ coordinates: [CLLocationCoordinate2D]) -> Void)) {
		APIManager.coordinates(forRouteCode: routeCode, success: { (coordinates: [[Double]]) in
			let locationCoordinates = self.createLocations(fromCoordinates: coordinates)
			completion(locationCoordinates)
		}, failure: { (error: Error) in
			UIAlertController.showErrorPopup(error as NSError?)
			completion([])
		})
	}

	func address(forLocation location: CLLocation, completion: @escaping ((_ address: String?) -> Void)) {
		let handler = { (placemarks: [CLPlacemark]?, error: Error?) in
			for placemark in (placemarks ?? []) {
				DKLog(Configuration.Verbose.pinAddress, "Address found: \(placemark.addressDictionary ?? [:])")
				let street = placemark.addressDictionary?[Map.Address.street] as? String
				completion(street)
			}
		}

		CLGeocoder().reverseGeocodeLocation(location, completionHandler: handler)
	}
}
