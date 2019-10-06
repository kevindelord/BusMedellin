//
//  RadiusSliderViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

class RadiusSliderViewController					: UIViewController, MapContainedElement, RadiusSliderContainer {

	@IBOutlet private weak var radiusSlider			: UISlider?

	// MapContainedElement
	weak var delegate								: MapActionDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.radiusSlider?.minimumValue = Float(Map.minimumSearchRadius)
		self.radiusSlider?.maximumValue = Float(Map.maximumSearchRadius)
		self.radiusSlider?.value = Float(Map.defaultSearchRadius)
		self.radiusSlider?.tintColor = Color.blue
		self.radiusSlider?.alpha = 0
	}

	@IBAction private func sliderValueDidChange() {
		let radiusValue = (self.radiusSlider?.value ?? Float(Map.defaultSearchRadius))
		self.delegate?.updateSearchRadius(to: Double(radiusValue))
	}

	/// Hide the slider from the user.
	private func hide() {
		UIView.animate(withDuration: 0.3, animations: {
			self.radiusSlider?.alpha = 0
		})
	}
}

// MARK: - MapContainedElement

extension RadiusSliderViewController {

	/// Only hide the slider when the chosen pickup location has been cancelled.
	func didCancel(location: Location) {
		guard (location == .PickUp) else {
			return
		}

		self.hide()
	}
}

// MARK: - RadiusSliderContainer

extension RadiusSliderViewController {

	/// Show UI elements
	func show() {
		UIView.animate(withDuration: 0.3, animations: {
			self.radiusSlider?.alpha = 1
		})
	}
}
