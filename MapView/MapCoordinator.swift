//
//  MapCoordinator.swift
//  BusMedellin
//
//  Created by kevindelord on 11/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit
import Reachability

// TODO: Fix bug when using the cancel buttons.

class MapCoordinator			: UIView, ContentView, MapContainer, MapActionDelegate {

	// ContentView
	var coordinator				: Coordinator?
	var delegate				: (RouteManagerDelegate & ContentViewDelegate)?

	// Map Container
	var routeDataSource			: RouteManagerDataSource?
	var map						: (MapCoordinatedElement & MapViewContainer)?
	var pinLocation				: (MapCoordinatedElement & PinLocationContainer)?
	var addressLocation			: (MapCoordinatedElement & AddressViewContainer)?

	private var locationCoordinates = [Location: CLLocationCoordinate2D]()
}

// MARK: - MapActionDelegate

extension MapCoordinator {

	func cancel(location: Location) {
		self.map?.didCancel(location: location)
		self.pinLocation?.didCancel(location: location)
		self.addressLocation?.didCancel(location: location)
		// Notify the app coordinator.
		self.delegate?.cancelSearch()
		// Analytics
		if (location == .PickUp) {
			Analytics.PinLocation.didCancelStart.send()
		} else {
			Analytics.PinLocation.didCancelDestination.send()
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
		let tag: Analytics.PinLocation = (location == .PickUp ? .didSetStart : .didSetDestination)
		tag.send()

		// Hide the location button and its text
		self.pinLocation?.hide()

		// Fetch the address of the location
		let coreLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		self.routeDataSource?.address(forLocation: coreLocation, completion: { [weak self] (address: String?) in
			// Show the address in the dedicated view.
			self?.addressLocation?.update(location: location, withAddress: address)

			if (location == .PickUp) {
				self?.configureInterfaceForDestinationLocation()
				// Hide waiting HUD
				self?.map?.hideWaitingHUD()
			} else {
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

extension MapCoordinator {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		guard
			let route = selectedRoute,
			let dataSource = self.routeDataSource else {
				return
		}

		self.map?.draw(selectedRoute: route, routeDataSource: dataSource)
	}
}
