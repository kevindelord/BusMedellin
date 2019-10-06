//
//  RouteCollector.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

// Static variable that is lazy loaded and therefore only initialized and parsed the first time the data is accessed.
// This logic simulates an easy database and improve the launch time.
//
// In an attempt to reduce the decoding time the file "rutas_medellin_light.json" only contains the values required by the application.
// A more complete data structure is available in the archive "RUTAS_URBANAS_INTEGRADAS_MEDELLIN.zip".
private var routeCollection : [RouteJSON] = {
	var routes = [RouteJSON]()
	if let path = Bundle.main.path(forResource: "rutas_medellin_light", ofType: "json") {
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
			routes = try JSONDecoder()
				.decode(FailableCodableArray<RouteJSON>.self, from: data)
				.elements
		} catch {
			let error = RouteCollector.Invalid.json.localizedError as NSError?
			DispatchQueue.main.async {
				UIAlertController.showErrorPopup(error)
			}
		}
	}

	return routes
}()

class RouteCollector : RouteCollectorDelegate {

	/// Fetch all coordinates for a specific route.
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [CLLocationCoordinate2D]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		DispatchQueue.global(qos: .background).async {
			let selectedRoute = routeCollection.first { (route: RouteJSON) -> Bool in
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
			let routesAroundStart = routeCollection.filter { (route: RouteJSON) -> Bool in
				return route.isAroundLocation(start, with: radius)
			}

			let result = routesAroundStart.filter { (route: RouteJSON) -> Bool in
				return route.isAroundLocation(finish, with: radius)
			}

			let routes = result.map { (routeJSON: RouteJSON) -> Route in
				return Route(name: routeJSON.name, code: routeJSON.code, district: routeJSON.district, area: routeJSON.area)
			}

			DispatchQueue.main.async {
				completion(routes)
			}
		}
	}
}
