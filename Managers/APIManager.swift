//
//  APIManager.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

// TODO: Integrate Time-Out in APIManager.

class APIManager {

	private var request			: URLRequest?

	fileprivate init(staticURLWithParameters parameters: [String: String?]) {
		guard
			let bundleIdentifier = Bundle.main.bundleIdentifier,
			var urlComponents = URLComponents(string: Configuration().apiBaseUrl) else {
				return
		}

		urlComponents.addQueryItems(from: parameters)
		guard let url = urlComponents.url else {
			return
		}

		self.request = URLRequest(url: url)
		self.request?.httpMethod = "GET"
		self.request?.setValue(bundleIdentifier, forHTTPHeaderField: "x-ios-bundle-identifier")
	}

	private func get(success: @escaping ((_ json: [AnyHashable: Any]) -> Void), failure: @escaping ((_ error: Error) -> Void)) {
		guard let request = self.request else {
			return
		}

		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
			if let error = error {
				failure(error)
				return
			}

			APIManager.didCompleteSessionTask(data: data, success: success, failure: failure)
		}

		DKLog(Configuration.Verbose.api, "Request: \(request)")
		DKLog(Configuration.Verbose.api, "HTTP header fields: \(request.allHTTPHeaderFields ?? [:])")
		task.resume()
	}

	private static func didCompleteSessionTask(data: Data?, success: @escaping ((_ json: [AnyHashable: Any]) -> Void), failure: @escaping ((_ error: Error) -> Void)) {
		do {
			guard
				let data = data,
				let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] else {
					DispatchQueue.main.async {
						failure(APIManager.Invalid.json.localizedError)
					}

					return
			}

			DispatchQueue.main.async {
				success(json)
			}
		} catch let error {
			DispatchQueue.main.async {
				failure(error)
			}
		}
	}
}

extension APIManager {

	private static var GoogleIdentifiers: (identifier: String, key: String) {
		let identifier = Configuration().fusionTableIdentifier
		let key = Configuration().fusionTableKey
		return (identifier, key)
	}

	/// Fetch all coordinates for a specific route.
	///
	/// Base URL + "?sql=SELECT geometry FROM " + idFusionTable + " WHERE CODIGO_RUT='" + route + "'&key=" + keyFusionTable
	/// https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20geometry%20FROM%20<Google Fusion Table ID>%20WHERE%20CODIGO_RUT=%27RU130RA%27&key=<Google API Key>
	static func coordinates(forRouteCode routeCode: String, success: @escaping (_ coordinates: [[Double]]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		let google = APIManager.GoogleIdentifiers
		let parameters = [
			"key": google.key,
			"sql": "SELECT geometry FROM \(google.identifier) WHERE CODIGO_RUT='\(routeCode)'"
		]
		let manager = APIManager(staticURLWithParameters: parameters)
		manager.get(success: { (json: [AnyHashable: Any]) in
			let rows = (json[API.Response.Key.rows] as? [[[AnyHashable: Any]]] ?? [])
			var coordinates = [[Double]]()
			for row in rows {
				for geometryData in row {
					// Use the working data structure
					let multipleGeometries = geometryData[API.Response.Key.geometries] as? [[AnyHashable: Any]]
					coordinates = (APIManager.parseRoute(for: multipleGeometries) ?? coordinates)
					let singleGeometry = geometryData[API.Response.Key.geometry] as? [AnyHashable: Any]
					coordinates = (APIManager.parseRoute(for: singleGeometry) ?? coordinates)
				}
			}

			if (coordinates.isEmpty == false) {
				DKLog(Configuration.Verbose.api, "APIManager: did Receive \(coordinates.count) coordinates for route name: \(routeCode)\n")
				success(coordinates)
			} else {
				failure(APIManager.Invalid.coordinates.localizedError)
			}

		}, failure: { (error: Error) in
			failure(error)
		})
	}

	private static func parseRoute(for geometry: [AnyHashable: Any]?) -> [[Double]]? {
		return geometry?[API.Response.Key.coordinates] as? [[Double]]
	}

	/// Route with geometries require a sum up of all coordinates to complete the bezier path.
	private static func parseRoute(for geometries: [[AnyHashable: Any]]?) -> [[Double]]? {
		var route = [[Double]]()
		for geometry in (geometries ?? []) {
			guard
				let coordinates = geometry[API.Response.Key.coordinates] as? [[Double]],
				(coordinates.isEmpty == false) else {
					continue
			}

			route += coordinates
		}

		return (route.isEmpty == false ? route : nil)
	}

	/// Fetch all available routes around a specific location.
	///
	/// Base URL + "?sql=SELECT Nombre_Rut,CODIGO_RUT FROM " + idFusionTable + " WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(" + lat + "," + lng + ")," + radius + "))&key=" + keyFusionTable
	/// https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20Nombre_Rut,CODIGO_RUT%20FROM%20<Google Fusion Table ID>%20WHERE%20ST_INTERSECTS(geometry,CIRCLE(LATLNG(6.207853406405264,-75.58648771697993),500))&key=<Google API Key>
	static func routes(aroundLocation location: CLLocation, success: @escaping (_ routes: [Route]) -> Void, failure: @escaping (_ error: Error) -> Void) {
		let google = APIManager.GoogleIdentifiers
		let lat = location.coordinate.latitude
		let lng = location.coordinate.longitude
		let radius = Map.defaultSearchRadius
		let parameters = [
			"key": google.key,
			"sql": "SELECT Nombre_Rut,CODIGO_RUT,NomBar,NomCom FROM \(google.identifier) WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(\(lat),\(lng)),\(radius)))"
		]

		let manager = APIManager(staticURLWithParameters: parameters)
		manager.get(success: { (json: [AnyHashable: Any]) in
			guard
				let jsonObject = json as? [String: Any],
				let routeData = jsonObject[API.Response.Key.rows] as? [[String]] else {
					failure(APIManager.Invalid.routes.localizedError)
					return
			}

			let routes = Route.createRoutes(data: routeData)
			DKLog(Configuration.Verbose.api, "APIManager: did Receive \(routes.count) routes around: \(lat),\(lng)\n")
			success(routes)

		}, failure: { (error: Error) in
			failure(error)
		})
	}
}
