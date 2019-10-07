//
//  MapContainerViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class MapContainerViewController : UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup hud view.
		self.container?.hudView = HUDView(within: self.view, layoutSupport: self.bottomLayoutGuide)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		// There is no need to check the segue's identifier as each destination controller conforms to dedicated protocols.
		if let addressController = segue.destination as? (MapContainedElement & AddressViewContainer) {
			self.container?.addressLocation = addressController
			addressController.delegate = self.container
		}

		if let mapController = segue.destination.view as? (MapContainedElement & MapViewContainer & UserLocationDataSource) {
			self.container?.map = mapController
			mapController.delegate = self.container
		}

		if let pinController = segue.destination as? (MapContainedElement & PinLocationContainer) {
			self.container?.pinLocation = pinController
			pinController.delegate = self.container
		}

		if let locationController = segue.destination as? (MapContainedElement & UserLocationContainer) {
			self.container?.userLocation = locationController
			locationController.delegate = self.container
			locationController.dataSource = self.container?.map
		}

		if let sliderController = segue.destination as? (MapContainedElement & RadiusSliderContainer) {
			self.container?.radiusSlider = sliderController
			sliderController.delegate = self.container
		}
	}

	private var container : (MapContainer & MapActionDelegate & HUDContainer)? {
		return (self.view as? (MapContainer & MapActionDelegate & HUDContainer))
	}
}
