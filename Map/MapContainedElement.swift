//
//  MapContainedElement.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// Object conforming to this protocol are therefore contained within a MapContainer.
protocol MapContainedElement {

	/// Delegate for possible user actions on a MapContainer.
	var delegate: MapActionDelegate? { get set }

	/// Function called after the user cancelled a location-based search.
	func didCancel(location: Location)
}
