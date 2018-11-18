//
//  MapCircle.swift
//  BusMedellin
//
//  Created by Kevin Delord on 24/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

class MapCircle	: MKCircle {

	var color		: UIColor?

	class func create(centerCoordinate coord: CLLocationCoordinate2D, radius: CLLocationDistance, color: UIColor) -> MapCircle {
		let circle = MapCircle(center: coord, radius: radius)
		circle.color = color
		return circle
	}

	class func createStartCircle(centerCoordinate coord: CLLocationCoordinate2D) -> MapCircle {
		return MapCircle.create(centerCoordinate: coord, radius: Map.defaultSearchRadius, color: Color.green)
	}

	class func createDestinationCircle(centerCoordinate coord: CLLocationCoordinate2D) -> MapCircle {
		return MapCircle.create(centerCoordinate: coord, radius: Map.defaultSearchRadius, color: Color.red)
	}
}
