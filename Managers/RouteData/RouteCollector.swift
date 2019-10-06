//
//  RouteCollector.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

// Static variable that is lazy laoded and therefore only initialized and parsed the first time the data is accessed.
// Improve launch time.
private var routeCollection : [RouteJSON] = {
	var routes = [RouteJSON]()
	if let path = Bundle.main.path(forResource: "rutas_medellin", ofType: "json") {
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
			routes = try JSONDecoder()
				.decode(FailableCodableArray<RouteJSON>.self, from: data)
				.elements
		} catch {
			let error = RouteCollector.Invalid.json.localizedError
			assertionFailure("Error Parsing JSON: \(error as NSError?)")
			DispatchQueue.main.async {
				UIAlertController.showErrorPopup(error as NSError?)
			}
		}
	}

	return routes
}()

class RouteCollector : RouteCollectorDelegate {

	/// Fetch all coordinates for a specific route.
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [[Double]]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		DispatchQueue.global(qos: .background).async {
			let selectedRoute = routeCollection.first { (route: RouteJSON) -> Bool in
				return (route.code == routeCode)
			}

			let coordinates = selectedRoute?.geometry.map({ (coordinates: CoordindateJSON) -> [Double] in
				return [coordinates.longitude, coordinates.latitude]
			})

			DispatchQueue.main.async {
				success(coordinates ?? [])
			}
		}
	}

	/// Fetch all available routes around a specific location.
	static func routes(aroundLocation location: CLLocation, success: @escaping (_ routes: [Route]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		DispatchQueue.global(qos: .background).async {
			let result = routeCollection.filter { (route: RouteJSON) -> Bool in
				return route.isAroundLocation(location)
			}

			let routes = result.map { (routeJSON: RouteJSON) -> Route in
				return Route(name: routeJSON.name, code: routeJSON.code, district: routeJSON.district, area: routeJSON.area)
			}

			DispatchQueue.main.async {
				success(routes)
			}
		}
	}
}
