//
//  CoordindateJSON.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import MapKit

typealias CoordindateJSON = [Double]

// Data received from the local JSON: [longitude, latitude].
extension CoordindateJSON {

	var latitude: Double {
		return self[1]
	}

	var longitude: Double {
		return self[0]
	}

	var coordinate2D : CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}

	public func isAroundLocation(_ location: CLLocation, radius: Double) -> Bool {
		let currentLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
		return (location.distance(from: currentLocation) <= radius)
	}
}
