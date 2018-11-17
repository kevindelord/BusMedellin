//
//  MapContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// Protocol defining what a map container must have as contained elements.
protocol MapContainer {

	/// Data Source to get exact CoreLocation objects to display bus routes.
	var routeDataSource			: RouteManagerDataSource? { get set }

	/// Element displaying the MKMapView.
	var map				 		: (MapContainedElement & MapViewContainer)? { get set }

	/// Element displaying the selected address views.
	var addressLocation			: (MapContainedElement & AddressViewContainer)? { get set }

	/// Element displaying the tool kit helping the user to pin point a location on the map.
	var pinLocation				: (MapContainedElement & PinLocationContainer)? { get set }
}

