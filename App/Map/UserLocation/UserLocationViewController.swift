//
//  UserLocationViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

class UserLocationViewController					: UIViewController, UserLocationContainer, MapContainedElement {

	@IBOutlet private weak var userLocationButton	: UserLocationButton?

	// Use a retained CLLocationManager to ask for the permission (otherwise the popup disappears).
	private let locationManager						= CLLocationManager()

	// MapContainedElement
	weak var delegate								: MapActionDelegate?

	// UserLocationContainer
	weak var dataSource								: UserLocationDataSource?
}

// MARK: - MapContainedElement

extension UserLocationViewController {

	func didCancel(location: Location) {
		// Nothing to do here when the user cancels a search.
	}
}

// MARK: - UserLocationContainer

extension UserLocationViewController {

	func update(userLocation: MKUserLocation) {
		self.userLocationButton?.update(userLocation: userLocation)
	}
}

// MARK: - User Location functions

extension UserLocationViewController {

	private func checkLocationAuthorizationStatus() -> MKUserLocation? {
		if (CLLocationManager.authorizationAccepted == true) {
			let userLocation = self.dataSource?.currentUserLocation
			if (userLocation == nil) {
				self.showPopupToRedirectToSettings()
			}

			return userLocation
		} else if (CLLocationManager.authorizationStatus() == .denied) {
			// The status is `.denied` if it has been refused by the user or if the complete Location Service are turned off.
			self.showPopupToRedirectToSettings()
			return nil
		} else {
			self.locationManager.requestWhenInUseAuthorization()
			Analytics.UserLocation.didAskForUserLocation.send()
			return nil
		}
	}

	private func showPopupToRedirectToSettings() {
		let presentingViewController = UIApplication.shared.windows.first?.rootViewController
		let alertController = UIAlertController(title: L("LOCATION_ERROR_TITLE"), message: L("LOCATION_ERROR_MESSAGE"), preferredStyle: .alert)
		// Cancel action button
		alertController.addAction(UIAlertAction(title: L("LOCATION_ERROR_CANCEL"), style: .default, handler: { (action: UIAlertAction) in
			Analytics.UserLocation.didCancelLocationPopup.send()
		}))
		// Open Settings action button
		alertController.addAction(UIAlertAction(title: L("LOCATION_ERROR_SETTINGS"), style: .cancel, handler: { (action: UIAlertAction) in
			if let url = URL(string: UIApplication.openSettingsURLString) {
				Analytics.UserLocation.didOpenSettings.send()
				UIApplication.shared.openURL(url)
			}
		}))
		// Present Controller
		presentingViewController?.present(alertController, animated: true, completion: nil)
		Analytics.UserLocation.didAskForSettings.send()
	}
}

// MARK: - Interface Builder Action

extension UserLocationViewController {

	/// Function called when the user presses the 'near me' (or aka 'locate me') button.
	@IBAction private func locateUser() {
		guard
			let userLocation = self.checkLocationAuthorizationStatus(),
			let location = userLocation.location else {
				return
		}

		// Update user location button state.
		self.userLocationButton?.update(userLocation: userLocation)
		// Disable the locate me feature if the user is too far away from the city center.
		if (Map.cityCenterLocation.distance(from: location) < Map.maxScrollDistance) {
			self.delegate?.centerMap(on: location)
			Analytics.UserLocation.didLocateUser.send()
		} else {
			UIAlertController.showInfoMessage("", message: L("USER_LOCATION_TOO_FAR"))
			Analytics.UserLocation.didLocateUserTooFar.send()
		}
	}
}
