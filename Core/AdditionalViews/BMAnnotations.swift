//
//  BMAnnotation.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

class BMAnnotation	: NSObject, MKAnnotation {

	let title		: String?
	let subtitle	: String?
	var coordinate	: CLLocationCoordinate2D
	let reuseId		: String
	let pinColor	: MKPinAnnotationColor

	init(coordinate: CLLocationCoordinate2D, reuseId: String, pinColor: MKPinAnnotationColor) {
		self.title = nil
		self.subtitle = nil
		self.coordinate = coordinate
		self.reuseId = reuseId
		self.pinColor = pinColor
		super.init()
	}
}

class BMStartAnnotation : BMAnnotation {

	static func create(withCoordinates coordinates: CLLocationCoordinate2D) -> BMStartAnnotation {
		return BMStartAnnotation(coordinate: coordinates, reuseId: ReuseId.pickUpPin, pinColor: .green)
	}
}

class BMDestinationAnnotation : BMAnnotation {

	static func create(withCoordinates coordinates: CLLocationCoordinate2D) -> BMStartAnnotation {
		return BMStartAnnotation(coordinate: coordinates, reuseId: ReuseId.destinationPin, pinColor: .red)
	}
}
