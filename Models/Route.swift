//
//  Route.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

struct Route		: Equatable {
	var name		: String
	var code		: String
	var district	: String
	var area		: String
	var number		: String

	var description	: String {
		var description = ""
		if (self.district != "") {
			description = self.district
			if (self.area != "") {
				description += ", \(self.area)"
			}
		}

		return description
	}
}

func == (lhs: Route, hrs: Route) -> Bool {
	return (lhs.code == hrs.code)
}
