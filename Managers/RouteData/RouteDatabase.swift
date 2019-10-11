//
//  RouteDatabase.swift
//  BusMedellin
//
//  Created by kevindelord on 11/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import UIKit
import FirebasePerformance

/// This logic simulates an easy database and improve the launch time.
///
/// In an attempt to reduce the decoding time the file "rutas_medellin_light.json" only contains the values required by the application.
/// A more complete data structure is available in the archive "RUTAS_URBANAS_INTEGRADAS_MEDELLIN.zip".
struct RouteDatabase {

	/// Private static array of RouteJSON values representing the local database.
	private static var _route_collection = [RouteJSON]()

	/// Private static semaphore to lock the usage of the internal variable containing the data.
	private static let _routes_semaphore = DispatchSemaphore(value: 1)

	/// Call this function in the AppDelegate to intialize the offline data.
	/// Reading the local JSON file and parsing the data is done in the background.
	/// A semaphore is used to make certain the availables routes are ready when searched for.
	public static func setup() {
		DispatchQueue.global(qos: .background).async {
			RouteDatabase._routes_semaphore.wait()
			let trace = Performance.startTrace(name: "routes_JSON_import")

			if let path = Bundle.main.path(forResource: "rutas_medellin_light", ofType: "json") {
				do {
					let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
					RouteDatabase._route_collection = try JSONDecoder()
						.decode(FailableCodableArray<RouteJSON>.self, from: data)
						.elements
				} catch {
					let error = RouteCollector.Invalid.json.localizedError as NSError?
					DispatchQueue.main.async {
						UIAlertController.showErrorPopup(error)
					}
				}
			}

			trace?.stop()
			RouteDatabase._routes_semaphore.signal()
		}
	}

	/// Return a copy of the local offline routes. Access is locked with a semaphore to make sure it has been initialised before returned.
	public static var routes: [RouteJSON] {
		RouteDatabase._routes_semaphore.wait()
		let copy = RouteDatabase._route_collection
		RouteDatabase._routes_semaphore.signal()
		return copy
	}
}
