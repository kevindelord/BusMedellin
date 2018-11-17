//
//  Annotation.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

class Annotation	: NSObject, MKAnnotation {

	let title		: String?
	let subtitle	: String?
	var coordinate	: CLLocationCoordinate2D
	let reuseId		: String
	let pinColor	: UIColor

	init(coordinate: CLLocationCoordinate2D, reuseId: String, pinColor: UIColor) {
		self.title = nil
		self.subtitle = nil
		self.coordinate = coordinate
		self.reuseId = reuseId
		self.pinColor = pinColor
		super.init()
	}
}
