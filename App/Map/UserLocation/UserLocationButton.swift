//
//  UserLocationButton.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

class UserLocationButton	: UIButton {

	var locationState		: ButtonState = .inactive {
		didSet {
			let img = UIImage(named: "NearMe")?.withRenderingMode(.alwaysTemplate)
			self.setImage(img, for: .normal)
			self.tintColor = self.locationState.tintColor
		}
	}

	func update(userLocation: MKUserLocation?) {
		let canShowUserLocation = (userLocation?.location != nil && CLLocationManager.authorizationAccepted == true)
		self.locationState = (canShowUserLocation == true ? .available : .inactive)
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		// Default state on init.
		self.locationState = .inactive
	}
}
