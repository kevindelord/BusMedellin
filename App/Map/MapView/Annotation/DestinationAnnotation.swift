//
//  DestinationAnnotation.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

class DestinationAnnotation : Annotation {

	static func create(withCoordinates coordinates: CLLocationCoordinate2D) -> DestinationAnnotation {
		return DestinationAnnotation(coordinate: coordinates, reuseId: Map.ReuseId.destinationPin, pinColor: .red)
	}
}

