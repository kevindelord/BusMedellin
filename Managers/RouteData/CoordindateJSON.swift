//
//  CoordindateJSON.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import MapKit

struct CoordindateJSON : Codable {
	var latitude: Double
	var longitude: Double

	var coordinate2D : CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}

	static func generate(from stringCoordinates: String) -> [CoordindateJSON] {
		var locations = [CoordindateJSON]()
		for singleStringCoordinate in stringCoordinates.split(separator: " ") {
			let coordinates = singleStringCoordinate.split(separator: ",")
			guard
				let latitude = Double(coordinates[1]),
				let longitude = Double(coordinates[0]) else {
					continue
			}

			let location = CoordindateJSON(latitude: latitude, longitude: longitude)
			locations.append(location)
		}

		return locations
	}
}

extension CoordindateJSON {

	public func isAroundLocation(_ location: CLLocation, radius: Double) -> Bool {
		let currentLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
		return (location.distance(from: currentLocation) <= radius)
	}
}
