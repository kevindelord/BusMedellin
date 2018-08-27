//
//  APIManager.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

extension URLComponents {

	mutating func addQueryItems(from parameters: [String: String?]) {
		self.queryItems = parameters.compactMap { (key: String, value: String?) -> URLQueryItem? in
			guard let value = value else {
				return nil
			}

			return URLQueryItem(name: key, value: value)
		}
	}
}

class APIManager {

	private var request			: URLRequest?

	fileprivate init(staticURLWithParameters parameters: [String: String?]) {
		guard
			let fullPath = Bundle.main.stringEntryInPList(for: BMPlist.APIBaseURL),
			let bundleIdentifier = Bundle.main.bundleIdentifier,
			var urlComponents = URLComponents(string: fullPath) else {
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

		DKLog(Verbose.Manager.API, "Request: \(request)")
		DKLog(Verbose.Manager.API, "HTTP header fields: \(request.allHTTPHeaderFields ?? [:])")
		task.resume()
	}

	private static func didCompleteSessionTask(data: Data?, success: @escaping ((_ json: [AnyHashable: Any]) -> Void), failure: @escaping ((_ error: Error) -> Void)) {
		do {
			guard
				let data = data,
				let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] else {
					DispatchQueue.main.async {
						failure(NSError(domain: "BusPaisa", code: 300, userInfo: [NSLocalizedDescriptionKey: "Can't deserialize response."]))
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
		guard
			let identifier = Bundle.main.stringEntryInPList(for: BMPlist.FusionTable.Identifier),
			let key = Bundle.main.stringEntryInPList(for: BMPlist.FusionTable.Key) else {
				return ("", "")
		}

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
			guard
				let jsonObject      = json as? [String: Any],
				let rows            = jsonObject[API.Response.Key.Rows] as? [[[String: Any]]],
				let row             = rows.first?.first,
				let geometry        = row[API.Response.Key.Geometry] as? [String:Any],
				let coordinates     = geometry[API.Response.Key.Coordinates] as? [[Double]] else {
					let message = "Parsing geometry list failed for route name: \(routeCode)"
					let error = NSError(domain: "BusPaisa", code: 300, userInfo: [NSLocalizedDescriptionKey: message])
					failure(error)
					return
			}

			DKLog(Verbose.Manager.API, "APIManager: did Receive \(coordinates.count) coordinates for route name: \(routeCode)\n")
			success(coordinates)
		}, failure: { (error: Error) in
			failure(error)
		})
	}

	/// Fetch all available routes around a specific location.
	///
	/// Base URL + "?sql=SELECT Nombre_Rut,CODIGO_RUT FROM " + idFusionTable + " WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(" + lat + "," + lng + ")," + radius + "))&key=" + keyFusionTable
	/// https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20Nombre_Rut,CODIGO_RUT%20FROM%20<Google Fusion Table ID>%20WHERE%20ST_INTERSECTS(geometry,CIRCLE(LATLNG(6.207853406405264,-75.58648771697993),500))&key=<Google API Key>
	static func routes(aroundLocation location: CLLocation, success: @escaping (_ routes: [Route]) -> Void, failure: @escaping (_ error: Error) -> Void) {
        let google = APIManager.GoogleIdentifiers
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
		let radius = Map.DefaultSearchRadius
        let parameters = [
			"key": google.key,
			"sql": "SELECT Nombre_Rut,CODIGO_RUT,NomBar,NomCom FROM \(google.identifier) WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(\(lat),\(lng)),\(radius)))"
		]

		let manager = APIManager(staticURLWithParameters: parameters)
		manager.get(success: { (json: [AnyHashable: Any]) in
            guard
                let jsonObject  = json as? [String: Any],
                let routeData   = jsonObject[API.Response.Key.Rows] as? [[String]] else {
					let message = "Parsing route list failed for routes around location: \(lat),\(lng)"
					let error = NSError(domain: "BusPaisa", code: 300, userInfo: [NSLocalizedDescriptionKey: message])
					failure(error)
					return
			}

			let routes = Route.createRoutes(data: routeData)
			DKLog(Verbose.Manager.API, "APIManager: did Receive \(routes.count) routes around: \(lat),\(lng)\n")
			success(routes)

		}, failure: { (error: Error) in
			failure(error)
        })
    }
}
