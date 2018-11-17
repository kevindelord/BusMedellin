//
//  PinLocationViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 11/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class PinLocationViewController 						: UIViewController, MapContainedElement, PinLocationContainer {

	@IBOutlet weak private var locationButton			: UIButton?
	@IBOutlet weak private var pinDescriptionLabel		: UILabel?

	var delegate 										: MapActionDelegate?
	var currentLocationState							: Location = .PickUp

	override func viewDidLoad() {
		super.viewDidLoad()

		self.pinDescriptionLabel?.text = L("PIN_PICKUP_LOCATION")
	}

	@IBAction private func setLocationButtonPressed() {
		self.delegate?.pinPoint(location: self.currentLocationState)
	}
}

// MARK: - MapContainedElement

extension PinLocationViewController {

	func didCancel(location: Location) {
		self.configureInterface(forLocation: location)
	}
}

// MARK: - PinLocationContainer

extension PinLocationViewController {

	func configureInterface(forLocation location: Location) {
		self.currentLocationState = location
		UIView.animate(withDuration: 0.3, animations: {
			// Show UI elements
			self.locationButton?.alpha = 1
			self.pinDescriptionLabel?.alpha = 1
			self.locationButton?.setImage(UIImage(named: location.pinImageName), for: .normal)
			self.pinDescriptionLabel?.text = location.pinLocalizedText
		})
	}

	/// Show UI elements
	func show() {
		UIView.animate(withDuration: 0.3, animations: {
			self.locationButton?.alpha = 1
			self.pinDescriptionLabel?.alpha = 1
		})
	}

	// Hide the location button and its text
	func hide() {
		UIView.animate(withDuration: 0.3, animations: {
			self.locationButton?.alpha = 0
			self.pinDescriptionLabel?.alpha = 0
		})
	}
}
