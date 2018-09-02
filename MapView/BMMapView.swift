//
//  BMMapView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit
import Reachability

// TODO: fully extract location Manager
// TODO: fully extract top view
// TODO: fix position of locationButton compared to annotations.

class BMMapView											: UIView {

	@IBOutlet weak private var mapView					: MKMapView?
	@IBOutlet weak private var nearMeButton				: BMLocateButton?
	@IBOutlet weak private var locationButton			: UIButton?
	@IBOutlet weak private var pinDescriptionLabel		: UILabel?
	@IBOutlet weak private var pickUpInfoView			: BMAddressView?
	@IBOutlet weak private var destinationInfoView		: BMAddressView?
	@IBOutlet weak private var cancelDestinationButton	: UIButton?
	@IBOutlet weak private var cancelPickUpButton		: UIButton?
	@IBOutlet weak private var destinationInfoViewTopConstraint : NSLayoutConstraint?

	private let locationManager							= CLLocationManager()
	private var startAnnotation							: BMAnnotation?
	private var destinationAnnotation					: BMAnnotation?
	private var startCircle								: BMMapCircle?
	private var destinationCircle						: BMMapCircle?

	var coordinator										: Coordinator?
	var routeDataSource									: RouteDataSource?
	var contentViewDelegate								: ContentViewDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		// Initialize the interface that way only once.
		_ = initializationProcess
	}

	private lazy var initializationProcess: Void = {
		// By default show Medellin city center
		self.centerMap(on: self.cityCenterLocation)
		// Setup 'locate me' button.
		self.nearMeButton?.setup(mapView: self.mapView)
		// Setup address views
		self.pinDescriptionLabel?.text = L("PIN_PICKUP_LOCATION")
		self.pickUpInfoView?.setupWithState(state: .PickUp)
		self.destinationInfoView?.setupWithState(state: .Destination)
		// Setup cancel buttons
		let imageInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
		self.cancelPickUpButton?.imageEdgeInsets = imageInset
		self.cancelDestinationButton?.imageEdgeInsets = imageInset
	}()
}

// MARK: - ContentView

extension BMMapView: ContentView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		guard let routeCode = selectedRoute?.code else {
			return
		}

		self.routeDataSource?.routeCoordinates(for: routeCode, completion: { [weak self] (coordinates: [CLLocationCoordinate2D]) in
			self?.drawRouteForCoordinates(coordinates: coordinates)
			// Analytics
			Analytics.Route.didDrawRoute.send(routeCode: routeCode, rounteCount: 1)
			// Hide waiting HUD
			self?.coordinator?.hideWaitingHUD()
		})
	}
}

// MARK: - MapView Delegate functions

extension BMMapView: MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		// Force the map to stay close to the city center.
		if (self.cityCenterLocation.distance(from: mapCenter) > Map.maxScrollDistance) {
			self.centerMap(on: self.cityCenterLocation)
		}
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? BMAnnotation {

			var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.reuseId) as? MKPinAnnotationView
			if (annotationView == nil) {
				annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.reuseId)
			}

			annotationView?.annotation = annotation
			annotationView?.animatesDrop = false
			annotationView?.pinTintColor = annotation.pinColor
			annotationView?.canShowCallout = false
			return annotationView
		}

		return nil
	}

	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		// If the location suddenly become available adapt the location button.
		if (userLocation.location == nil) {
			self.nearMeButton?.locationState = .inactive
		} else if (self.nearMeButton?.locationState == .inactive) {
			self.nearMeButton?.locationState = .available
		}
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if (overlay is MKGeodesicPolyline) {
			let lineView = MKPolylineRenderer(overlay: overlay)
			lineView.strokeColor = BMColor.blue
			lineView.lineWidth = Map.polylineWidth
			return lineView

		} else if let circle = overlay as? BMMapCircle {
			let circleRenderer = MKCircleRenderer(overlay: overlay)
			circleRenderer.fillColor = (circle.color ?? UIColor.blue).withAlphaComponent(Map.circleColorAlpha)
			circleRenderer.strokeColor = (circle.color ?? UIColor.blue)
			circleRenderer.lineWidth = 1
			return circleRenderer
		}

		return MKOverlayRenderer()
	}
}

// MARK: - User Location functions

extension BMMapView {

	/// Default city center location
	private var cityCenterLocation : CLLocation {
		let latitude = (Double(Configuration().defaultLatitude) ?? 0)
		let longitude = (Double(Configuration().defaultLongitude) ?? 0)
		return CLLocation(latitude: latitude, longitude: longitude)
	}

	private func checkLocationAuthorizationStatus() -> CLLocation? {
		if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
			self.mapView?.showsUserLocation = true
			let userLocation = self.mapView?.userLocation.location
			if (userLocation == nil) {
				self.showPopupToRedirectToSettings()
			}

			return userLocation
		} else if (CLLocationManager.authorizationStatus() == .denied) {
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
			if let url = URL(string: UIApplicationOpenSettingsURLString) {
				Analytics.UserLocation.didOpenSettings.send()
				UIApplication.shared.openURL(url)
			}
		}))
		// Present Controller
		presentingViewController?.present(alertController, animated: true, completion: nil)
		Analytics.UserLocation.didAskForSettings.send()
	}
}

// MARK: - MapView Utility functions

extension BMMapView {

	/**
	Center the map on a specific location.

	- parameter location: Location to center the map to.
	*/
	private func centerMap(on location: CLLocation) {
		let regionRadius: CLLocationDistance = Map.defaultZoomRadius
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
		self.mapView?.setRegion(coordinateRegion, animated: true)
	}

	/**
	Draw a new route on the map using a set of coordinates.

	This function also removes all already drawn routes from the mapView.

	- parameter coordinates: Array of coordinates representing the route to display.
	*/
	private func drawRouteForCoordinates(coordinates: [CLLocationCoordinate2D]) {
		guard (coordinates.isEmpty == false) else {
			return
		}

		// A 'var' is required by MKGeodesicPolyline()
		var pointsToUse = coordinates
		let myPolyline = MKGeodesicPolyline(coordinates: &pointsToUse, count: coordinates.count)
		// Remove previous overlays
		self.removeDrawnRoutes()
		// Add new overlay
		self.mapView?.add(myPolyline, level: MKOverlayLevel.aboveLabels)
	}

	/**
	Remove any drawn routes from the mapView.
	*/
	private func removeDrawnRoutes() {
		self.mapView?.overlays.forEach { (overlay: MKOverlay) in
			if (overlay is MKGeodesicPolyline) {
				self.mapView?.remove(overlay)
			}
		}
	}

	/**
	Add a new start/pickup annotation on the map.

	- parameter coordinate: Coordinate of the annotation.
	*/
	private func addPickupAnnotation(coordinate: CLLocationCoordinate2D) {
		self.startAnnotation = BMStartAnnotation.create(withCoordinates: coordinate)
		self.mapView?.addAnnotation(safe: self.startAnnotation)
		self.startCircle = BMMapCircle.createStartCircle(centerCoordinate: coordinate)
		self.mapView?.addOverlay(safe: self.startCircle)
	}

	/**
	Add a new destination annotation on the map.

	- parameter coordinate: Coordinate of the annotation.
	*/
	private func addDestinationAnnotation(coordinate: CLLocationCoordinate2D) {
		self.destinationAnnotation = BMDestinationAnnotation.create(withCoordinates: coordinate)
		self.mapView?.addAnnotation(safe: self.destinationAnnotation)
		self.destinationCircle = BMMapCircle.createDestinationCircle(centerCoordinate: coordinate)
		self.mapView?.addOverlay(safe: self.destinationCircle)
	}

	/**
	Move the mapView up North from the given coordinates.

	- parameter coordinate: Coordinate from where to move/scroll north.
	- parameter delta:      Delta to move the map.
	*/
	private func moveMapViewNorthFromCoordinate(coordinate: CLLocationCoordinate2D, delta: Double = Map.deltaAfterSearch) {
		let newLocation = CLLocation(latitude: coordinate.latitude + delta, longitude: coordinate.longitude)
		let regionRadius: CLLocationDistance = Map.defaultZoomRadius
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
		self.mapView?.setRegion(coordinateRegion, animated: true)
	}
}

// MARK: - Interface Builder Action

extension BMMapView {

	/// Function called when the user presses the 'x' to cancel the PICKUP location.
	@IBAction private func cancelPickUpButtonPressed() {
		UIView.animate(withDuration: 0.3, animations: {
			// Hide UI elements
			self.locationButton?.alpha = 1
			self.pinDescriptionLabel?.alpha = 1
			self.cancelPickUpButton?.alpha = 0
			self.pickUpInfoView?.update(withAddress: nil)
			// Show the destination address view.
			self.destinationInfoView?.backgroundColor = BMColor.viewBorder
			self.destinationInfoViewTopConstraint?.constant -= ((self.destinationInfoView?.frame.height ?? 0) * 0.5)
			// Reset map
			self.removeDrawnRoutes()
			self.mapView?.removeAnnotation(safe: self.startAnnotation)
			self.mapView?.removeOverlay(safe: self.startCircle)
			self.startAnnotation = nil
			// Reset map indicator
			self.locationButton?.setImage(UIImage(named: "pickupLocation"), for: .normal)
			self.pinDescriptionLabel?.text = L("PIN_PICKUP_LOCATION")
			// Notify and reload the collection view.
			self.contentViewDelegate?.cancelSearch()
			// Analytics
			Analytics.PinLocation.didCancelStart.send()
		})
	}

	/// Function called when the user presses the 'x' to cancel the DESTINATION location.
	@IBAction private func cancelDestinationButtonPressed() {
		UIView.animate(withDuration: 0.3, animations: {
			// Hide UI elements
			self.locationButton?.alpha = 1
			self.pinDescriptionLabel?.alpha = 1
			self.cancelDestinationButton?.alpha = 0
			self.cancelPickUpButton?.alpha = 1
			self.destinationInfoView?.update(withAddress: nil)
			// Reset map
			self.removeDrawnRoutes()
			self.mapView?.removeAnnotation(safe: self.destinationAnnotation)
			self.mapView?.removeOverlay(safe: self.destinationCircle)
			self.destinationAnnotation = nil
			// Reset map indicator
			self.locationButton?.setImage(UIImage(named: "destinationLocation"), for: .normal)
			self.pinDescriptionLabel?.text = L("PIN_DESTINATION_LOCATION")
			// Notify and reload the collection view with the new results.
			self.contentViewDelegate?.cancelSearch()
			// Analytics
			Analytics.PinLocation.didCancelDestination.send()
		})
	}

	/// Function called when the user selects a pickup or destination location.
	/// This function checks what needs to be set and forward the process to a more dedicated function.
	@IBAction private func setLocationButtonPressed() {
		if (Reachability.isConnected == true) {
			if (self.startAnnotation == nil) {
				self.didSetPickUpLocation()
			} else if (self.destinationAnnotation == nil) {
				self.didSetDestinationLocation()
			}
		} else {
			UIAlertController.showErrorMessage(L("NO_INTERNET_CONNECTION"))
		}
	}

	/// Function called when the user presses the 'near me' (or aka 'locate me') button.
	@IBAction private func locateMeButtonPressed() {
		if let userLocation = self.checkLocationAuthorizationStatus() {
			// Disable the locate me feature if the user is too far away from the city center.
			if (self.cityCenterLocation.distance(from: userLocation) < Map.maxScrollDistance) {
				self.centerMap(on: userLocation)
				Analytics.UserLocation.didLocateUser.send()
			} else {
				UIAlertController.showInfoMessage("", message: L("USER_LOCATION_TOO_FAR"))
				Analytics.UserLocation.didLocateUserTooFar.send()
			}
		}
	}
}

// MARK: - Functionalities

extension BMMapView {

	/**
	Function called when the user did select a new PICKUP location.
	This function add a new annotation on the map, display the views to set the destination.
	It also fetch the address of the current pickup location and displays it.
	*/
	private func didSetPickUpLocation() {
		if let centerCoordinate = self.mapView?.centerCoordinate {
			// Add a new annotation at the center of the map.
			self.addPickupAnnotation(coordinate: centerCoordinate)

			UIView.animate(withDuration: 0.3, animations: {
				// Hide the location button and its text
				self.locationButton?.alpha = 0
				self.pinDescriptionLabel?.alpha = 0

			}, completion: { (finished: Bool) in
				// Show waiting HUD
				self.coordinator?.showWaitingHUD()
				// Analytics
				Analytics.PinLocation.didSetStart.send()
				// Fetch the address of the location
				let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
				self.routeDataSource?.address(forLocation: location, completion: { (address: String?) in
					// Show the address in the dedicated view.
					self.pickUpInfoView?.update(withAddress: address)
					// Set the location button and text to the destination state.
					self.locationButton?.setImage(UIImage(named: "destinationLocation"), for: .normal)
					self.pinDescriptionLabel?.text = L("PIN_DESTINATION_LOCATION")
					UIView.animate(withDuration: 0.5, animations: {
						// Show UI elements
						self.locationButton?.alpha = 1
						self.pinDescriptionLabel?.alpha = 1
						self.cancelPickUpButton?.alpha = 1
						// Show the destination address view.
						self.destinationInfoView?.backgroundColor = .white
						self.destinationInfoViewTopConstraint?.constant += ((self.destinationInfoView?.frame.height ?? 0) * 0.5)
						// Move the map up North a bit.
						self.moveMapViewNorthFromCoordinate(coordinate: centerCoordinate)
						// Hide waiting HUD
						self.coordinator?.hideWaitingHUD()
					})
				})
			})
		}
	}

	/**
	Function called when the user did select a new DESTINATION location.
	This function updates the mapView with a new annotation, search for the address of the destination location.
	It also starts the process to search for routes between the two annotations.
	*/
	private func didSetDestinationLocation() {
		if let centerCoordinate = self.mapView?.centerCoordinate {
			// Add a new destination pin at the center of the map.
			self.addDestinationAnnotation(coordinate: centerCoordinate)

			UIView.animate(withDuration: 0.3, animations: {
				// Hide the location button and its text
				self.locationButton?.alpha = 0
				self.pinDescriptionLabel?.alpha = 0
				self.cancelDestinationButton?.alpha = 1
				self.cancelPickUpButton?.alpha = 0

			}, completion: { (finished: Bool) in
				// Show waiting HUD
				self.coordinator?.showWaitingHUD()
				// Analytics
				Analytics.PinLocation.didSetDestination.send()
				// Fetch the address of the location
				let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
				self.routeDataSource?.address(forLocation: location, completion: { [weak self] (address: String?) in
					// Show the address in the dedicated view.
					self?.destinationInfoView?.update(withAddress: address)

					// Search for all available routes between the two locations.
					guard
						let start = self?.startAnnotation?.coordinate,
						let destination = self?.destinationAnnotation?.coordinate else {
							return
					}

					self?.routeDataSource?.routes(between: start, and: destination, completion: { [weak self] in
						self?.contentViewDelegate?.reloadContentView()
					})
				})
			})
		}
	}
}
