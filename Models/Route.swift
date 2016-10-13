//
//  Route.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

struct Route {
    var name : String
    var code : String

    static func createRoutes(data: [[String]]) -> [Route] {
        var routes = [Route]()
        data.forEach { (values: [String]) in
            if let
                name = values[safe: 0],
                code = values[safe: 1] {
                    routes.append(Route(name: name, code: code))
            }
        }
        return routes
    }
}