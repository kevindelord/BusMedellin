//
//  Route.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

enum RouteData : Int {
    case Route = 0
    case Code
    case District
    case Area
}

struct Route {
    var name        : String
    var code        : String
    var district    : String
    var area        : String

    static func createRoutes(data: [[String]]) -> [Route] {
        var routes = [Route]()
        data.forEach { (values: [String]) in
            if let
                name = values[safe: RouteData.Route.rawValue],
                code = values[safe: RouteData.Code.rawValue],
                district = values[safe: RouteData.District.rawValue],
                area = values[safe: RouteData.Area.rawValue] {
                    routes.append(Route(name: name, code: code, district: district, area: area))
            }
        }
        return routes
    }
}