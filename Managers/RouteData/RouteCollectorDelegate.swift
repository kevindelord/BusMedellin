//
//  RouteCollectorDelegate.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

// TODO: Update pods.

protocol RouteCollectorDelegate: AnyObject {

	/// Fetch all coordinates for a specific route.
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [CLLocationCoordinate2D]) -> Void, failure: @escaping (_ error: Error) -> Void)

	/// Fetch all available routes passing around a start and finish locations (within a given radius range).
	static func routes(between start: CLLocation, and finish: CLLocation, with radius: Double, completion: @escaping (_ routes: [Route]) -> Void)
}
