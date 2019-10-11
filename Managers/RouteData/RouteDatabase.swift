//
//  RouteDatabase.swift
//  BusMedellin
//
//  Created by kevindelord on 11/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import UIKit

private var _route_collection = [RouteJSON]()

private let _routes_semaphore = DispatchSemaphore(value: 1)

/// This logic simulates an easy database and improve the launch time.
///
/// In an attempt to reduce the decoding time the file "rutas_medellin_light.json" only contains the values required by the application.
/// A more complete data structure is available in the archive "RUTAS_URBANAS_INTEGRADAS_MEDELLIN.zip".
struct RouteDatabase {

	/// Call this function in the AppDelegate to intialize the offline data.
	/// Reading the local JSON file and parsing the data is done in the background.
	/// A semaphore is used to make certain the availables routes are ready when searched for.
	public static func setup() {
		DispatchQueue.global(qos: .background).async {
			_routes_semaphore.wait()
			if let path = Bundle.main.path(forResource: "rutas_medellin_light", ofType: "json") {
				do {
					let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
					_route_collection = try JSONDecoder()
						.decode(FailableCodableArray<RouteJSON>.self, from: data)
						.elements
				} catch {
					let error = RouteCollector.Invalid.json.localizedError as NSError?
					DispatchQueue.main.async {
						UIAlertController.showErrorPopup(error)
					}
				}
			}

			_routes_semaphore.signal()
		}
	}

	/// Return a copy of the local offline routes. Access is locked with a semaphore to make sure it has been initialised before returned.
	public static var routes: [RouteJSON] {
		_routes_semaphore.wait()
		let copy = _route_collection
		_routes_semaphore.signal()
		return copy
	}
}
