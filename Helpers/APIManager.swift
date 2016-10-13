//
//  APIManager.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import AFNetworking
import DKHelper
import MapKit

extension AFHTTPRequestSerializer {

	func addHeaderFields(headerFields: [(value: String, key: String)]?) {
		for tuple in (headerFields ?? []) {
			self.setValue(tuple.value, forHTTPHeaderField: tuple.key)
		}
	}
}
extension NSURLSessionTask {

	/// Cast the current `response` NSURLResponse into a NSHTTPURLResponse and return the static code.
	var responseStatusCode : Int? {
		return (self.response as? NSHTTPURLResponse)?.statusCode
	}
}

struct APIManager {

	private static func GETRequest(parameters: AnyObject?, success:((session: NSURLSessionDataTask, responseObject: AnyObject?) -> Void), failure:((session: NSURLSessionTask?, error: NSError) -> Void)) {

		let fullPath = NSBundle.stringEntryInPListForKey(BMPlist.APIBaseURL)
		let manager = AFHTTPSessionManager()
		manager.requestSerializer = AFHTTPRequestSerializer()
		DKLog(Verbose.Manager.API, "GET Request: \(fullPath) parameters: \(parameters)")
		DKLog(Verbose.Manager.API, "GET Request HTTP header field: \(manager.requestSerializer.HTTPRequestHeaders)")

		manager.GET(fullPath, parameters: parameters, progress: nil, success: { (session: NSURLSessionDataTask, responseObject: AnyObject?) in

			success(session: session, responseObject: responseObject)
            }, failure: { (session: NSURLSessionDataTask?, error: NSError) in
				let errorMsg = (error.localizedDescription ?? "no NSError object")
                print(errorMsg)
				failure(session: session, error: error)
		})
	}
}


extension APIManager {

    static func coordinatesForRouteName(routeName: String, completion: ((coordinates: [[Double]], error: NSError?) -> Void)?) {

        //
        // baseURL+ "?sql=SELECT geometry FROM " + idFusionTable + " WHERE CODIGO_RUT='" + route + "'&key=" + keyFusionTable
        //
        // https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20geometry%20FROM%201_ihDJT-_zFRLXb526aaS0Ct3TiXTlcPDy_BlAz0%20WHERE%20CODIGO_RUT=%27RU130RA%27&key=AIzaSyC59BP_KRtQDLeb5XM_x0eQNT_tdlBbHZc&callback=jQuery180014487654335838962_1476318703876&_=1476324379366
        //
        let identifier = NSBundle.stringEntryInPListForKey(BMPlist.FusionTable.Identifier)
        let key = NSBundle.stringEntryInPListForKey(BMPlist.FusionTable.Key)
        let parameters = ["sql":"SELECT geometry FROM \(identifier) WHERE CODIGO_RUT='\(routeName)'", "key" : key]

        self.GETRequest(parameters, success: { (session, responseObject) in

            if let
                jsonObject      = responseObject as? [String:AnyObject],
                rows            = jsonObject[API.Response.Key.Rows] as? [[[String:AnyObject]]],
                row             = rows.first?.first,
                geometry        = row[API.Response.Key.Geometry] as? [String:AnyObject],
                coordinates     = geometry[API.Response.Key.Coordinates] as? [[Double]] {

                    DKLog(Verbose.Manager.API, "APIManager: did Receive \(coordinates.count) coordinates for route name: \(routeName)\n")
                    completion?(coordinates: coordinates, error: nil)
                    return
            }

            DKLog(Verbose.Manager.API, "APIManager: parsing 'geometry' list failed for route name: \(routeName)\n")
            completion?(coordinates: [], error: nil)
            }, failure: { (operation: NSURLSessionTask?, error: NSError) in
                completion?(coordinates: [], error: error)
        })
    }

    static func routesAroundLocation(location: CLLocation, radius: Double = Map.DefaultSearchRadius, completion: ((routes: [Route], error: NSError?) -> Void)?) {

        //
        // BaseURL + "?sql=SELECT Nombre_Rut,CODIGO_RUT FROM " + idFusionTable + " WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(" + lat + "," + lng + ")," + radius + "))&key=" + keyFusionTable
        //
        // https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20Nombre_Rut,CODIGO_RUT%20FROM%201_ihDJT-_zFRLXb526aaS0Ct3TiXTlcPDy_BlAz0%20WHERE%20ST_INTERSECTS(geometry,CIRCLE(LATLNG(6.207853406405264,-75.58648771697993),500))&key=AIzaSyC59BP_KRtQDLeb5XM_x0eQNT_tdlBbHZc&callback=jQuery180014487654335838962_1476318703876&_=1476328479515

        //
        let identifier = NSBundle.stringEntryInPListForKey(BMPlist.FusionTable.Identifier)
        let key = NSBundle.stringEntryInPListForKey(BMPlist.FusionTable.Key)
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let parameters = ["sql":"SELECT Nombre_Rut,CODIGO_RUT FROM \(identifier) WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(\(lat),\(lng)),\(radius)))", "key" : key]

        self.GETRequest(parameters, success: { (session, responseObject) in

            if let
                jsonObject  = responseObject as? [String:AnyObject],
                routeData   = jsonObject[API.Response.Key.Rows] as? [[String]] {

                let routes = Route.createRoutes(routeData)
                DKLog(Verbose.Manager.API, "APIManager: did Receive \(routes.count) routes around: \(lat),\(lng)\n")
                completion?(routes: routes, error: nil)
                return
            }

            DKLog(Verbose.Manager.API, "APIManager: parsing 'routes' list failed for routes around: \(lat),\(lng)\n")
            completion?(routes: [], error: nil)
            }, failure: { (operation: NSURLSessionTask?, error: NSError) in
                completion?(routes: [], error: error)
        })
    }
}
