//
//  MapContainerViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class MapContainerViewController : UIViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		let container = (self.view as? (MapContainer & MapActionDelegate))
		// There is no need to check the segue's identifier as each destination controller conforms to dedicated protocols.
		if let addressController = segue.destination as? (MapContainedElement & AddressViewContainer) {
			container?.addressLocation = addressController
			addressController.delegate = container
		}

		if let mapController = segue.destination.view as? (MapContainedElement & MapViewContainer & UserLocationDataSource) {
			container?.map = mapController
			mapController.delegate = container
		}

		if let pinController = segue.destination as? (MapContainedElement & PinLocationContainer) {
			container?.pinLocation = pinController
			pinController.delegate = container
		}

		if let locationController = segue.destination as? (MapContainedElement & UserLocationContainer) {
			container?.userLocation = locationController
			locationController.delegate = container
			locationController.dataSource = container?.map
		}
	}
}
