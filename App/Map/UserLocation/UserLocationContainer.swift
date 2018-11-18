//
//  UserLocationContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

protocol UserLocationContainer: AnyObject {

	/// Update the UI to reflect a user location status' change.
	func update(userLocation: MKUserLocation)

	/// DataSource getting real time user locations.
	var dataSource : UserLocationDataSource? { get set }
}
