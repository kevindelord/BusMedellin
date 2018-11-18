//
//  MapContainerView.swift
//  BusMedellin
//
//  Created by kevindelord on 11/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit
import Reachability
import Appirater

// TODO: If search is cancelled while fetching data -> cancel all ongoing requests.
// TODO: Fix successful search but address not displayed in addressView
// TODO: Fix successful search but routes list not displayed.
// TODO: Fix scroll on search with multiple results.

class MapContainerView			: UIView, ContentView, MapContainer, MapActionDelegate {

	// ContentView
	weak var coordinator		: Coordinator?
	weak var delegate			: (RouteManagerDelegate & ContentViewDelegate)?

	// Map Container

	weak var routeDataSource	: RouteManagerDataSource?
	weak var map				: (MapContainedElement & MapViewContainer & UserLocationDataSource)?
	weak var pinLocation		: (MapContainedElement & PinLocationContainer)?
	weak var addressLocation	: (MapContainedElement & AddressViewContainer)?
	weak var userLocation		: (MapContainedElement & UserLocationContainer)?

	private var locationCoordinates = [Location: CLLocationCoordinate2D]()
}

// MARK: - MapActionDelegate

extension MapContainerView {

	func updateUserLocation(_ location: MKUserLocation) {
		self.userLocation?.update(userLocation: location)
	}

	func centerMap(on location: CLLocation) {
		self.map?.centerMap(on: location)
	}

	func cancel(location: Location) {
		self.map?.didCancel(location: location)
		self.pinLocation?.didCancel(location: location)
		self.addressLocation?.didCancel(location: location)
		self.userLocation?.didCancel(location: location)
		// Notify the app coordinator.
		self.delegate?.cancelSearch()
		// Analytics
		switch location {
		case .PickUp:		Analytics.PinLocation.didCancelStart.send()
		case .Destination:	Analytics.PinLocation.didCancelDestination.send()
		}
	}

	/// Function called when the user selects a pickup or destination location.
	/// This function checks what needs to be set and forward the process to a more dedicated function.
	func pinPoint(location: Location) {
		guard (Reachability.isConnected == true) else {
			UIAlertController.showErrorMessage(L("NO_INTERNET_CONNECTION"))
			return
		}

		guard let coordinate = self.map?.addAnnotation(forLocation: location) else {
			return
		}

		self.locationCoordinates[location] = coordinate

		// Show waiting HUD
		self.map?.showWaitingHUD()
		// Analytics
		switch location {
		case .PickUp:		Analytics.PinLocation.didSetStart.send()
		case .Destination:	Analytics.PinLocation.didSetDestination.send()
		}

		// Hide the location button and its text
		self.pinLocation?.hide()

		// Fetch the address of the location
		let coreLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		self.routeDataSource?.address(forLocation: coreLocation, completion: { [weak self] (address: String?) in
			// Show the address in the dedicated view.
			self?.addressLocation?.update(location: location, withAddress: address)

			switch location {
			case .PickUp:
				self?.configureInterfaceForDestinationLocation()
				// Hide waiting HUD
				self?.map?.hideWaitingHUD()
			case .Destination:
				// Search for available routes between the two selected locations.
				// This function must hide the HUD on completion.
				self?.searchForAvailableRoutes()
			}
		})
	}

	/// Search for available routes between the two selected locations.
	private func searchForAvailableRoutes() {
		guard
			let start = self.locationCoordinates[.PickUp],
			let destination = self.locationCoordinates[.Destination] else {
				// Hide waiting HUD
				self.map?.hideWaitingHUD()
				return
		}

		self.routeDataSource?.routes(between: start, and: destination, completion: { [weak self] in
			self?.delegate?.reloadContentViews()
			// Hide waiting HUD
			self?.map?.hideWaitingHUD()

			if (self?.routeDataSource?.availableRoutes.isEmpty == false) {
				// Significant Event: The user just did another successful search.
				Appirater.triggerSignificantEvent()
			}
		})
	}

	/// Configure the UI for the Destination State: new location button and text.
	private func configureInterfaceForDestinationLocation() {
		self.addressLocation?.show(viewForLocation: .Destination)
		self.pinLocation?.configureInterface(forLocation: .Destination)
		self.pinLocation?.show()
	}
}

// MARK: - ContentView

extension MapContainerView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		guard
			let route = selectedRoute,
			let dataSource = self.routeDataSource else {
				return
		}

		self.map?.draw(selectedRoute: route, routeDataSource: dataSource)
	}
}
