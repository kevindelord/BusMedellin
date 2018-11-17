//
//  BMMapView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

// TODO: extract & document protocols
// TODO: fully extract location Manager
// TODO: fix with successful search but address not displayed in addressView
// TODO: fix with successful search but routes list not displayed.

protocol MapContainer {

	var routeDataSource			: RouteManagerDataSource? { get set }

	var map				 		: (MapCoordinatedElement & MapViewContainer)? { get set }

	var addressLocation			: (MapCoordinatedElement & AddressViewContainer)? { get set }

	var pinLocation				: (MapCoordinatedElement & PinLocationContainer)? { get set }
}

protocol MapActionDelegate {

	func cancel(location: Location)

	func pinPoint(location: Location)
}

protocol MapCoordinatedElement {

	var delegate: MapActionDelegate? { get set }

	func didCancel(location: Location)
}

protocol MapViewContainer: HUDContainer {

	func addAnnotation(forLocation location: Location) -> CLLocationCoordinate2D?

	func draw(selectedRoute: Route, routeDataSource: RouteManagerDataSource)
}

protocol AddressViewContainer {

	func update(location: Location, withAddress address: String?)

	func show(viewForLocation location: Location)
}

protocol PinLocationContainer {

	func configureInterface(forLocation location: Location)

	func show()

	func hide()
}

class BMMapView											: UIView, MKMapViewDelegate, MapCoordinatedElement, MapViewContainer, HUDContainer {

	@IBOutlet weak private var mapView					: MKMapView?
	@IBOutlet weak private var nearMeButton				: BMLocateButton?

	private let locationManager							= CLLocationManager()
	private var startAnnotation							: BMAnnotation?
	private var destinationAnnotation					: BMAnnotation?
	private var startCircle								: BMMapCircle?
	private var destinationCircle						: BMMapCircle?

	var delegate 										: MapActionDelegate?

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
	}()
}

// MARK: - MapViewContainer

extension BMMapView {

	func addAnnotation(forLocation location: Location) -> CLLocationCoordinate2D? {
		guard let coordinate = self.mapView?.centerCoordinate else {
			return nil
		}

		// Add a new annotation at the center of the map.
		switch location {
		case .PickUp:
			self.addPickupAnnotation(coordinate: coordinate)
			// Move the map up North a bit.
			self.moveMapViewNorthFromCoordinate(coordinate: coordinate)
		case .Destination:
			self.addDestinationAnnotation(coordinate: coordinate)
		}

		return coordinate
	}

	func draw(selectedRoute: Route, routeDataSource: RouteManagerDataSource) {
		routeDataSource.routeCoordinates(for: selectedRoute.code, completion: { [weak self] (coordinates: [CLLocationCoordinate2D], _ error: Error?) in
			self?.drawRouteForCoordinates(coordinates: coordinates)
			// Analytics
			Analytics.Route.didDrawRoute.send(routeCode: selectedRoute.code, rounteCount: 1)
			// Hide waiting HUD
			self?.hideWaitingHUD()
		})
	}
}

// MARK: - MapCoordinatedElement

extension BMMapView {

	func didCancel(location: Location) {
		self.removeDrawnRoutes()

		switch location {
		case .PickUp:
			self.cancelPickUp()
			self.cancelDestination()
		case .Destination:
			self.cancelDestination()
		}
	}

	private func cancelDestination() {
		self.mapView?.removeAnnotation(safe: self.destinationAnnotation)
		self.mapView?.removeOverlay(safe: self.destinationCircle)
		self.destinationAnnotation = nil
	}

	private func cancelPickUp() {
		self.mapView?.removeAnnotation(safe: self.startAnnotation)
		self.mapView?.removeOverlay(safe: self.startCircle)
		self.startAnnotation = nil
	}
}

// MARK: - MapView Delegate functions

extension BMMapView {

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

	/// Center the map on a specific location.
	///
	/// - Parameter location: Location to center the map to.
	private func centerMap(on location: CLLocation) {
		let regionRadius: CLLocationDistance = Map.defaultZoomRadius
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
		self.mapView?.setRegion(coordinateRegion, animated: true)
	}

	/// Draw a new route on the map using a set of coordinates.
	///
	/// This function also removes all already drawn routes from the mapView.
	///
	/// - Parameter coordinates: Array of coordinates representing the route to display.
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

	/// Remove any drawn routes from the mapView.
	private func removeDrawnRoutes() {
		self.mapView?.overlays.forEach { (overlay: MKOverlay) in
			if (overlay is MKGeodesicPolyline) {
				self.mapView?.remove(overlay)
			}
		}
	}

	/// Add a new start/pickup annotation on the map.
	///
	/// - Parameter coordinate: Coordinate of the annotation.
	private func addPickupAnnotation(coordinate: CLLocationCoordinate2D) {
		self.startAnnotation = BMStartAnnotation.create(withCoordinates: coordinate)
		self.mapView?.addAnnotation(safe: self.startAnnotation)
		self.startCircle = BMMapCircle.createStartCircle(centerCoordinate: coordinate)
		self.mapView?.addOverlay(safe: self.startCircle)
	}

	/// Add a new destination annotation on the map.
	///
	/// - Parameter coordinate: Coordinate of the annotation.
	private func addDestinationAnnotation(coordinate: CLLocationCoordinate2D) {
		self.destinationAnnotation = BMDestinationAnnotation.create(withCoordinates: coordinate)
		self.mapView?.addAnnotation(safe: self.destinationAnnotation)
		self.destinationCircle = BMMapCircle.createDestinationCircle(centerCoordinate: coordinate)
		self.mapView?.addOverlay(safe: self.destinationCircle)
	}

	/// Move the mapView up North from the given coordinates.
	///
	/// - Parameters:
	///   - coordinate: Coordinate from where to move/scroll north.
	///   - delta: Delta to move the map.
	private func moveMapViewNorthFromCoordinate(coordinate: CLLocationCoordinate2D, delta: Double = Map.deltaAfterSearch) {
		let newLocation = CLLocation(latitude: coordinate.latitude + delta, longitude: coordinate.longitude)
		let regionRadius: CLLocationDistance = Map.defaultZoomRadius
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
		self.mapView?.setRegion(coordinateRegion, animated: true)
	}
}

// MARK: - Interface Builder Action

extension BMMapView {

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

