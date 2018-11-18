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

		if (segue.identifier == Segue.Embed.ViewController.Address), var addressController = segue.destination as? (MapContainedElement & AddressViewContainer) {
			var container = (self.view as? (MapContainer & MapActionDelegate))
			container?.addressLocation = addressController
			addressController.delegate = container
		}

		if (segue.identifier == Segue.Embed.ViewController.Map), var mapController = segue.destination.view as? (MapContainedElement & MapViewContainer & UserLocationDataSource) {
			var container = (self.view as? (MapContainer & MapActionDelegate))
			container?.map = mapController
			mapController.delegate = container
		}

		if (segue.identifier == Segue.Embed.ViewController.ActionPin), var pinController = segue.destination as? (MapContainedElement & PinLocationContainer) {
			var container = (self.view as? (MapContainer & MapActionDelegate))
			container?.pinLocation = pinController
			pinController.delegate = container
		}

		if (segue.identifier == Segue.Embed.ViewController.UserLocation), var locationController = segue.destination as? (MapContainedElement & UserLocationContainer) {
			var container = (self.view as? (MapContainer & MapActionDelegate))
			container?.userLocation = locationController
			locationController.delegate = container
			locationController.dataSource = container?.map
		}
	}
}
