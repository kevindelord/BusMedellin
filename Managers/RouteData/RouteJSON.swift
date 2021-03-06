//
//  RouteJSON.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

struct RouteJSON	: Codable {
	var name		: String
	var code		: String
	var district	: String
	var area		: String
	var number		: String
	var geometry	: [CoordindateJSON]

	// Real JSON Keys from the resource file.
	enum RouteJSONCodingKey: String, CodingKey {
		case Nombre_Rut // Name
		case CODIGO_RUT // Code
		case NomBar		// District
		case NomCom		// Area
		case Numero_Rut // Number
		case geometry
	}

	// 'Sin Nombre' and 'sn' are known invalid values coming from the JSON.
	private static let invalidValues = ["Sin Nombre", "sn"]

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RouteJSONCodingKey.self)
		self.name = try container.decode(String.self, forKey: .Nombre_Rut)
		self.code = try container.decode(String.self, forKey: .CODIGO_RUT)
		self.district = try container.decode(String.self, forKey: .NomBar)
		self.area = try container.decode(String.self, forKey: .NomCom)
		self.number = try container.decode(String.self, forKey: .Numero_Rut)
		self.geometry = try container.decode([CoordindateJSON].self, forKey: .geometry)

		// Only use valid values for the district and the area.
		self.district = (RouteJSON.invalidValues.contains(self.district) == true ? "" : self.district)
		self.area = (RouteJSON.invalidValues.contains(self.area) == true ? "" : self.area)
	}
}

extension RouteJSON {

	public func isAroundLocation(_ location: CLLocation, with radius: Double) -> Bool {
		let result = self.geometry.first { (coordinateJSON: CoordindateJSON) -> Bool in
			return coordinateJSON.isAroundLocation(location, radius: radius)
		}

		return (result != nil)
	}
}
