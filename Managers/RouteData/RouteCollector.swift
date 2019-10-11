//
//  RouteCollector.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

class RouteCollector : RouteCollectorDelegate {

	/// Fetch all coordinates for a specific route.
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [CLLocationCoordinate2D]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		DispatchQueue.global(qos: .background).async {
			let selectedRoute = RouteDatabase.routes.first { (route: RouteJSON) -> Bool in
				return (route.code == routeCode)
			}

			let coordinates = selectedRoute?.geometry.map({ (coordinates: CoordindateJSON) -> CLLocationCoordinate2D in
				return coordinates.coordinate2D
			})

			DispatchQueue.main.async {
				success(coordinates ?? [])
			}
		}
	}

	/// Fetch all available routes passing around a start and finish locations (within a given radius range).
	static func routes(between start: CLLocation, and finish: CLLocation, with radius: Double, completion: @escaping (_ routes: [Route]) -> Void) {
		DispatchQueue.global(qos: .background).async {
			let routesAroundStart = RouteDatabase.routes.filter { (route: RouteJSON) -> Bool in
				return route.isAroundLocation(start, with: radius)
			}

			let result = routesAroundStart.filter { (route: RouteJSON) -> Bool in
				return route.isAroundLocation(finish, with: radius)
			}

			let routes = result.map { (routeJSON: RouteJSON) -> Route in
				return Route(name: routeJSON.name, code: routeJSON.code, district: routeJSON.district, area: routeJSON.area, number: routeJSON.number)
			}

			DispatchQueue.main.async {
				completion(routes)
			}
		}
	}
}
