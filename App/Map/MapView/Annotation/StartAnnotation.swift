//
//  StartAnnotation.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

class StartAnnotation : Annotation {

	static func create(withCoordinates coordinates: CLLocationCoordinate2D) -> StartAnnotation {
		return StartAnnotation(coordinate: coordinates, reuseId: Map.ReuseId.pickUpPin, pinColor: .green)
	}
}
