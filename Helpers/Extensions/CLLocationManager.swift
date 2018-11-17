//
//  CLLocationManager.swift
//  BusMedellin
//
//  Created by kevindelord on 18/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import MapKit

extension CLLocationManager {

	static var authorizationAccepted : Bool {
		return (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways)
	}
}
