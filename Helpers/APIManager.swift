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

extension URLSessionTask {

	/// Cast the current `response` NSURLResponse into a NSHTTPURLResponse and return the static code.
	var responseStatusCode : Int? {
		return (self.response as? HTTPURLResponse)?.statusCode
	}
}

struct APIManager {

    private static func GETRequest(parameters: AnyObject?, success: @escaping ((_ session: URLSessionDataTask, _ responseObject: Any?) -> Void), failure: @escaping ((_ session: URLSessionTask?, _ error: Error) -> Void)) {

        let fullPath = Bundle.stringEntryInPList(forKey:BMPlist.APIBaseURL)
		let manager = AFHTTPSessionManager()
		manager.requestSerializer = AFHTTPRequestSerializer()
        DKLog(Verbose.Manager.API, "GET Request: \(fullPath) parameters: \(String(describing: parameters))")
		DKLog(Verbose.Manager.API, "GET Request HTTP header field: \(manager.requestSerializer.httpRequestHeaders)")

        
        manager.get(fullPath, parameters: parameters, success: success, failure: { (session: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(session, error)
        })
	}
}

extension APIManager {

    static func coordinates(forRouteCode routeCode: String, completion: ((_ coordinates: [[Double]], _ error: Error?) -> Void)?) {

        /*
        baseURL+ "?sql=SELECT geometry FROM " + idFusionTable + " WHERE CODIGO_RUT='" + route + "'&key=" + keyFusionTable

        https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20geometry%20FROM%201_ihDJT-_zFRLXb526aaS0Ct3TiXTlcPDy_BlAz0%20WHERE%20CODIGO_RUT=%27RU130RA%27&key=AIzaSyC59BP_KRtQDLeb5XM_x0eQNT_tdlBbHZc&callback=jQuery180014487654335838962_1476318703876&_=1476324379366
        */
        let identifier = Bundle.stringEntryInPList(forKey:BMPlist.FusionTable.Identifier)
        let key = Bundle.stringEntryInPList(forKey:BMPlist.FusionTable.Key)
        let parameters = ["sql":"SELECT geometry FROM \(identifier) WHERE CODIGO_RUT='\(routeCode)'", "key" : key]

        self.GETRequest(parameters: parameters as AnyObject, success: { (session: URLSessionDataTask, responseObject: Any?) in

            if
                let jsonObject      = responseObject as? [String:AnyObject],
                let rows            = jsonObject[API.Response.Key.Rows] as? [[[String:AnyObject]]],
                let row             = rows.first?.first,
                let geometry        = row[API.Response.Key.Geometry] as? [String:AnyObject],
                let coordinates     = geometry[API.Response.Key.Coordinates] as? [[Double]] {

                    DKLog(Verbose.Manager.API, "APIManager: did Receive \(coordinates.count) coordinates for route name: \(routeCode)\n")
                    completion?(coordinates, nil)
                    return
            }

            DKLog(Verbose.Manager.API, "APIManager: parsing 'geometry' list failed for route name: \(routeCode)\n")
            completion?([], nil)
            }, failure: { (operation: URLSessionTask?, error: Error) in
                completion?([], error)
        })
    }

    static func routes(aroundLocation location: CLLocation, radius: Double = Map.DefaultSearchRadius, completion: ((_ routes: [Route], _ error: Error?) -> Void)?) {

        /*
        BaseURL + "?sql=SELECT Nombre_Rut,CODIGO_RUT FROM " + idFusionTable + " WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(" + lat + "," + lng + ")," + radius + "))&key=" + keyFusionTable

        // swiftlint:disable line_length
        https://www.googleapis.com/fusiontables/v1/query?sql=SELECT%20Nombre_Rut,CODIGO_RUT%20FROM%201_ihDJT-_zFRLXb526aaS0Ct3TiXTlcPDy_BlAz0%20WHERE%20ST_INTERSECTS(geometry,CIRCLE(LATLNG(6.207853406405264,-75.58648771697993),500))&key=AIzaSyC59BP_KRtQDLeb5XM_x0eQNT_tdlBbHZc&callback=jQuery180014487654335838962_1476318703876&_=1476328479515
        // swiftlint:enable line_length
        */
        let identifier = Bundle.stringEntryInPList(forKey:BMPlist.FusionTable.Identifier)
        let key = Bundle.stringEntryInPList(forKey:BMPlist.FusionTable.Key)
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let parameters = ["sql":"SELECT Nombre_Rut,CODIGO_RUT,NomBar,NomCom FROM \(identifier) WHERE ST_INTERSECTS(geometry,CIRCLE(LATLNG(\(lat),\(lng)),\(radius)))", "key" : key]

        self.GETRequest(parameters: parameters as AnyObject, success: { (session: URLSessionDataTask, responseObject: Any?) in
            if
                let jsonObject  = responseObject as? [String: AnyObject],
                let routeData   = jsonObject[API.Response.Key.Rows] as? [[String]] {

                let routes = Route.createRoutes(data: routeData)
                DKLog(Verbose.Manager.API, "APIManager: did Receive \(routes.count) routes around: \(lat),\(lng)\n")
                completion?(routes, nil)
                return
            }

            DKLog(Verbose.Manager.API, "APIManager: parsing 'routes' list failed for routes around: \(lat),\(lng)\n")
            completion?([], nil)
            }, failure: { (operation: URLSessionTask?, error: Error) in
                completion?([], error)
        })
    }
}
