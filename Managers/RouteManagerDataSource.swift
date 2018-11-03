//
//  RouteManagerDataSource.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import CoreLocation

protocol RouteManagerDataSource {

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
