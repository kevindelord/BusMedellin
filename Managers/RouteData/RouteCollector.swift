//
//  RouteCollector.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

private var routeCollection : [RouteJSON] = {
	var routes = [RouteJSON]()
	if let path = Bundle.main.path(forResource: "rutas_medellin", ofType: "json") {
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
			routes = try JSONDecoder()
				.decode(FailableCodableArray<RouteJSON>.self, from: data)
				.elements
		} catch {
			assertionFailure("Cannot Parse Routes")
		}
	}

	return routes
}()

class RouteCollector {
}

extension RouteCollector : RouteDataDelegate {

	/// Fetch all coordinates for a specific route.
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [[Double]]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		let selectedRoute = routeCollection.first { (route: RouteJSON) -> Bool in
			return (route.code == routeCode)
		}

		let coordinates = selectedRoute?.geometry.map({ (coordinates: CoordindateJSON) -> [Double] in
			return [coordinates.longitude, coordinates.latitude]
		})

		success(coordinates ?? [])
	}

	/// Fetch all available routes around a specific location.
	static func routes(aroundLocation location: CLLocation, success: @escaping (_ routes: [Route]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		let result = routeCollection.filter { (route: RouteJSON) -> Bool in
			return route.isAroundLocation(location)
		}

		let routes = result.map { (routeJSON: RouteJSON) -> Route in
			return Route(name: routeJSON.name, code: routeJSON.code, district: routeJSON.district, area: routeJSON.area)
		}

		success(routes)
	}
}
