//
//  API.swift
//  BusMedellin
//
//  Created by kevindelord on 18/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

struct API {

	struct Response {

		struct Key {

			static let rows			= "rows"
			static let coordinates	= "coordinates"
			static let geometry		= "geometry"
			static let geometries	= "geometries"
		}

		// 'Sin Nombre' and 'sn' are known invalid values coming from the API.
		static let invalidValues	= ["Sin Nombre", "sn"]
	}
}
