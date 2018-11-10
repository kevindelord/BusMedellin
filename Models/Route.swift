//
//  Route.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

enum RouteData : Int {
	case route = 0
	case code
	case district
	case area
}

struct Route 		: Equatable {
	var name		: String
	var code		: String
	var district	: String
	var area		: String

	static func createRoutes(data: [[String]]) -> [Route] {
		var routes = [Route]()
		for values in data {
			guard
				let name = values[safe: RouteData.route.rawValue],
				let code = values[safe: RouteData.code.rawValue],
				let district = values[safe: RouteData.district.rawValue],
				let area = values[safe: RouteData.area.rawValue] else {
					continue
			}

			routes.append(Route(name: name, code: code, district: district, area: area))
		}

		return routes
	}
}

func ==(lhs: Route, hrs: Route) -> Bool {
	return (lhs.code == hrs.code)
}
