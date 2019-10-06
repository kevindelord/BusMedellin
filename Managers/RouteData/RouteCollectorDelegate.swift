//
//  RouteCollectorDelegate.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

// TODO: update xcode project and migrate to Swift 5.

protocol RouteCollectorDelegate: AnyObject {

	/// Fetch all coordinates for a specific route.
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [[Double]]) -> Void, failure: @escaping (_ error: Error) -> Void)

	/// Fetch all available routes around a specific location.
	static func routes(aroundLocation location: CLLocation, with radius: Double, success: @escaping (_ routes: [Route]) -> Void, failure: @escaping (_ error: Error) -> Void)
}
