//
//  MapView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

class MapView											: UIView, MKMapViewDelegate, MapContainedElement, MapViewContainer, HUDContainer, UserLocationDataSource {

	@IBOutlet weak private var mapView					: MKMapView?

	private var startAnnotation							: Annotation?
	private var destinationAnnotation					: Annotation?
	private var startCircle								: MapCircle?
	private var destinationCircle						: MapCircle?

	weak var delegate									: MapActionDelegate?

	override func layoutSubviews() {
		super.layoutSubviews()

		// Initialize the interface that way only once.
		_ = initializationProcess
	}

	private lazy var initializationProcess: Void = {
		// On start center the map onto the city center
		self.centerMap(on: Map.cityCenterLocation)
		// If enabled and authorized, show the user location's blue annotation.
		self.mapView?.showsUserLocation = (CLLocationManager.authorizationAccepted == true)
	}()
}

// MARK: - MapViewContainer

extension MapView {

	func addAnnotation(forLocation location: Location) -> CLLocationCoordinate2D? {
		guard let coordinate = self.mapView?.centerCoordinate else {
			return nil
		}

		// Add a new annotation at the center of the map.
		switch location {
		case .PickUp:
			self.addPickupAnnotation(coordinate: coordinate)
			// Move a bit the map up North to easily understand to transition to the .Destination Location.
			self.moveMapView(from: coordinate)
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

	func centerMap(on location: CLLocation) {
		let regionRadius: CLLocationDistance = Map.defaultZoomRadius
		// swiftlint:disable explicit_init
		let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
		// swiftlint:enable explicit_init
		self.mapView?.setRegion(coordinateRegion, animated: true)
	}
}

// MARK: - UserLocationDataSource

extension MapView {

	// The user wants to see his location annotation on the map.
	// If the access has been authorized, enable the mapView's user location and returned the processed location.
	var currentUserLocation: MKUserLocation? {
		self.mapView?.showsUserLocation = (CLLocationManager.authorizationAccepted == true)
		return self.mapView?.userLocation
	}
}

// MARK: - MapContainedElement

extension MapView {

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

extension MapView {

	/// Force the map to stay close to the city center.
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		if (Map.cityCenterLocation.distance(from: mapCenter) > Map.maxScrollDistance) {
			self.centerMap(on: Map.cityCenterLocation)
		}
	}

	/// Create new Pin Annotation.
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? Annotation else {
			return nil
		}

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

	/// If the location suddenly become available adapt the location button.
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		self.mapView?.showsUserLocation = (CLLocationManager.authorizationAccepted == true)
		self.delegate?.updateUserLocation(userLocation)
	}

	/// Draw a map overlay, either a bus route or a circle around a pin annotation.
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if (overlay is MKGeodesicPolyline) {
			let lineView = MKPolylineRenderer(overlay: overlay)
			lineView.strokeColor = Color.blue
			lineView.lineWidth = Map.polylineWidth
			return lineView

		} else if let circle = overlay as? MapCircle {
			let circleRenderer = MKCircleRenderer(overlay: overlay)
			circleRenderer.fillColor = (circle.color ?? Color.blue).withAlphaComponent(Map.circleColorAlpha)
			circleRenderer.strokeColor = (circle.color ?? Color.blue)
			circleRenderer.lineWidth = 1
			return circleRenderer
		}

		return MKOverlayRenderer()
	}
}

// MARK: - MapView Utility functions

extension MapView {

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
		self.mapView?.addOverlay(myPolyline, level: MKOverlayLevel.aboveLabels)
	}

	/// Remove any drawn routes from the mapView.
	private func removeDrawnRoutes() {
		self.mapView?.overlays.forEach { (overlay: MKOverlay) in
			if (overlay is MKGeodesicPolyline) {
				self.mapView?.removeOverlay(overlay)
			}
		}
	}

	/// Add a new start/pickup annotation on the map.
	///
	/// - Parameter coordinate: Coordinate of the annotation.
	private func addPickupAnnotation(coordinate: CLLocationCoordinate2D) {
		self.startAnnotation = StartAnnotation.create(withCoordinates: coordinate)
		self.mapView?.addAnnotation(safe: self.startAnnotation)
		self.startCircle = MapCircle.createStartCircle(centerCoordinate: coordinate)
		self.mapView?.addOverlay(safe: self.startCircle)
	}

	/// Add a new destination annotation on the map.
	///
	/// - Parameter coordinate: Coordinate of the annotation.
	private func addDestinationAnnotation(coordinate: CLLocationCoordinate2D) {
		self.destinationAnnotation = DestinationAnnotation.create(withCoordinates: coordinate)
		self.mapView?.addAnnotation(safe: self.destinationAnnotation)
		self.destinationCircle = MapCircle.createDestinationCircle(centerCoordinate: coordinate)
		self.mapView?.addOverlay(safe: self.destinationCircle)
	}

	/// Move the mapView up North from the given coordinates.
	///
	/// - Parameters:
	///   - coordinate: Coordinate from where to move/scroll north.
	///   - delta: Delta to move the map.
	private func moveMapView(from coordinate: CLLocationCoordinate2D, delta: Double = Map.deltaAfterSearch) {
		guard var region = self.mapView?.region else {
			return
		}

		let northCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + delta, longitude: coordinate.longitude)
		region.center = northCoordinate
		self.mapView?.setRegion(region, animated: true)
	}
}
