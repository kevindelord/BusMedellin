//
//  RadiusSliderViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

final class RadiusSliderViewController				: UIViewController, MapContainedElement, RadiusSliderContainer {

	@IBOutlet private weak var radiusSlider			: RadiusSlider!

	private var metersLabel							= MetersLabel()

	// MapContainedElement
	weak var delegate								: MapActionDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add the meters label to the view
		self.view.addSubview(self.metersLabel)
		// By default hide all UI elements
		self.radiusSlider.alpha = 0
		self.metersLabel.alpha = 0
		// Trigger an position and text update of the metersLabel
		self.sliderThumbDidMove()
	}

	@IBAction private func sliderThumbDidMove() {
		guard let slider = self.radiusSlider else {
			return
		}

		let trackRect = slider.trackRect(forBounds: slider.frame)
		let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
		self.metersLabel.center = CGPoint(x: thumbRect.midX, y: slider.frame.origin.y - 20)
		self.metersLabel.text = String(format: "%.0f m", slider.value)
	}

	@IBAction private func selectNewRadiusValue() {
		self.delegate?.updateSearchRadius(to: Double(self.radiusSlider.value))
	}

	/// Hide the slider from the user.
	private func hide() {
		UIView.animate(withDuration: 0.3, animations: {
			self.radiusSlider.alpha = 0
			self.metersLabel.alpha = 0
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
			self.radiusSlider.alpha = 1
			self.metersLabel.alpha = 1
		})
	}
}
