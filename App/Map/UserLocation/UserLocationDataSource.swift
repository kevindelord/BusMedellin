//
//  UserLocationDataSource.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

protocol UserLocationDataSource: AnyObject {

	/// Current user location available.
	var currentUserLocation : MKUserLocation? { get }
}
