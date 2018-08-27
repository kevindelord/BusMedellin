//
//  BMLocateButton.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

class BMLocateButton	: UIButton {

	var locationState	: MBButtonState = .inactive {
		didSet {
			let img = UIImage(named: "NearMe")?.withRenderingMode(.alwaysTemplate)
			self.setImage(img, for: .normal)
			self.tintColor = self.locationState.tintColor
		}
	}

	func setup(mapView: MKMapView? = nil) {
		guard
			(mapView?.userLocation.location != nil),
			(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) else {
				self.locationState = .inactive
				return
		}

		self.locationState = .available
	}
}
