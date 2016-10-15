//
//  BMMapCollectionView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit
import DKHelper
import CSStickyHeaderFlowLayout

class BMMapCollectionView                   : UICollectionReusableView {

    var mapContainer                        : BMMapView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.interfaceInitialisation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.interfaceInitialisation()
    }

    private func interfaceInitialisation() {
        self.mapContainer = UIView.loadFromNib(XibFile.BMMapView) as? BMMapView
        self.mapContainer?.frame = self.bounds
        self.addSubview(safe: self.mapContainer)
    }
}

class BMMapView                             : UIView {

    @IBOutlet weak var mapView              : MKMapView?
    @IBOutlet weak var nearMeButton         : BMLocateButton?
    @IBOutlet weak var destinationButton    : BMDestinationButton?
    @IBOutlet weak var startButton          : BMStartButton?

    private let locationManager             = CLLocationManager()
    private var startAnnotation             : BMAnnotation?
    private var destinationAnnotation       : BMAnnotation?

    var didFetchAvailableRoutesBlock        : ((routes: [Route]) -> Void)?
    var showErrorPopupBlock                 : ((error: NSError?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private static var __onceToken: dispatch_once_t = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        // Initialise the interface that way only once.
        dispatch_once(&BMMapView.__onceToken) {
            // By default show Medellin city center
            self.centerMapOnLocation(self.cityCenterLocation)
            // Setup 'locate me', 'Destination' and 'Start' buttons.
            self.nearMeButton?.setup(self.mapView)
            self.startButton?.startState = .Inactive
            self.destinationButton?.destinationState = .Inactive
        }
    }

    private var cityCenterLocation : CLLocation {
        let info = NSBundle.entryInPListForKey(BMPlist.MapDefault) as? [String:String]
        let latitude = (Double(info?[BMPlist.CityCenter.Latitude] ?? "0") ?? 0)
        let longitude = (Double(info?[BMPlist.CityCenter.Longitude] ?? "0") ?? 0)
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    private var defaultZoomRadius : CLLocationDistance {
        let info = NSBundle.entryInPListForKey(BMPlist.MapDefault) as? [String:String]
        let radius = Double(info?[BMPlist.CityCenter.Radius] ?? "0")
        return (radius ?? 0)
    }
}

// MARK: - MapView

extension BMMapView: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BMAnnotation {

            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotation.reuseId) as? MKPinAnnotationView
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.reuseId)
            }
            annotationView?.annotation = annotation
            annotationView?.animatesDrop = true
            annotationView?.pinColor = annotation.pinColor
            annotationView?.canShowCallout = true
            return annotationView
        }
        return nil
    }

    private func checkLocationAuthorizationStatus() -> CLLocation? {
        if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
            self.mapView?.showsUserLocation = true
            let userLocation = self.mapView?.userLocation.location
            return userLocation
        } else {
            self.locationManager.requestWhenInUseAuthorization()
            return nil
        }
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // If the location suddenly become available adapt the location button.
        if (userLocation.location == nil) {
            self.nearMeButton?.locationState = .Inactive
        } else if (self.nearMeButton?.locationState == .Inactive) {
            self.nearMeButton?.locationState = .Available
        }
    }

    /**
     Center the map on a specific location.

     - parameter location: Location to center the map to.
     */
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = self.defaultZoomRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView?.setRegion(coordinateRegion, animated: true)
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let lineView = MKPolylineRenderer(overlay: overlay)
        lineView.strokeColor = BMColor.Blue
        lineView.lineWidth = 1.5
        return lineView
    }

    private func drawRouteForCoordinates(coordinates: [CLLocationCoordinate2D]) {

        if (coordinates.isEmpty == true) {
            return
        }

        // A 'var' is required by MKGeodesicPolyline()
        var pointsToUse = coordinates
        let myPolyline = MKGeodesicPolyline(coordinates: &pointsToUse, count: coordinates.count)
        // Remove previous overlays
        self.removeDrawnRoutes()
        // Add new overlay
        self.mapView?.addOverlay(myPolyline, level: MKOverlayLevel.AboveLabels)
    }

    private func removeDrawnRoutes() {
        self.mapView?.removeOverlays(self.mapView?.overlays ?? [])
    }

    private func createLocationsFromCoordinates(coordinates: [[Double]]) -> [CLLocationCoordinate2D] {
        var pointsToUse = [CLLocationCoordinate2D]()
        coordinates.forEach { (values: [Double]) in
            if let
                y = values[safe: 0],
                x = values[safe: 1] {
                    pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(x), CLLocationDegrees(y))]
            }
        }
        return pointsToUse
    }
}

// MARK: - Interface Builder Action

extension BMMapView {

    @IBAction func destinationButtonlocatePressed() {
        self.destinationButton?.toggleState()

        if (self.destinationAnnotation != nil) {
            // Remove destination pin.
            self.mapView?.removeAnnotation(safe: self.destinationAnnotation)
            self.destinationAnnotation = nil

        } else if let centerCoordinate = self.mapView?.centerCoordinate {
            // Add a new destination pin at the center of the map.
            self.destinationAnnotation = BMDestinationAnnotation.createWithCoordinates(centerCoordinate)
            self.mapView?.addAnnotation(safe: self.destinationAnnotation)
        }
    }

    @IBAction func startButtonlocatePressed() {
        // UI change
        self.startButton?.toggleState()

        if (self.startAnnotation != nil) {
            // Remove current annotation
            self.mapView?.removeAnnotation(safe: self.startAnnotation)
            self.startAnnotation = nil
            // Remove previous routes
            self.removeDrawnRoutes()
            // Reset the collection view
            self.didFetchAvailableRoutesBlock?(routes: [])

        } else if let centerCoordinate = self.mapView?.centerCoordinate {
            // Add a new annotation at the center of the map.
            self.startAnnotation = BMStartAnnotation.createWithCoordinates(centerCoordinate)
            self.mapView?.addAnnotation(safe: self.startAnnotation)

            // Fetch routes around that location
            self.fetchRoutesForCoordinates(centerCoordinate, completion: { (routes) in
                // Draw the first route as example.
                if let routeCode = routes.first?.code {
                    self.fetchAndDrawRoute(routeCode)
                }
                // Notify and reload the collection view with the new results.
                self.didFetchAvailableRoutesBlock?(routes: routes)
            })

        }
    }

    @IBAction func locateMeButtonPressed() {
        if let location = self.checkLocationAuthorizationStatus() {
            self.centerMapOnLocation(location)
        }
    }
}

// MARK: - Data

extension BMMapView {

    /**
     Fetch coordinates of the given route and display it on the map.

     - parameter route: The Route entity to fetch and to display.
     */
    func fetchAndDrawRoute(route: Route) {
        self.fetchAndDrawRoute(route.code)
    }

    /**
     Fetch coordinates of a route using its identifier (aka route code) and display it on the map.

     - parameter routeCode: The route identifier used to fetch the coordinates.
     */
    private func fetchAndDrawRoute(routeCode: String) {
        APIManager.coordinatesForRouteCode(routeCode, completion: { (coordinates, error) in
            UIAlertController.showErrorPopup(error)
            let locationCoordinates = self.createLocationsFromCoordinates(coordinates)
            self.drawRouteForCoordinates(locationCoordinates)
        })
    }

    private func fetchRoutesForCoordinates(coordinates: CLLocationCoordinate2D, completion: ((routes: [Route]) -> Void)?) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.fetchRoutesForLocation(location, completion: completion)
    }

    private func fetchRoutesForLocation(location: CLLocation, completion: ((routes: [Route]) -> Void)?) {
        APIManager.routesAroundLocation(location) { (routes, error) in
            UIAlertController.showErrorPopup(error)
            completion?(routes: routes)
        }
    }
}

// MARK: - Debug

extension BMMapView {

    private func fetchRoutesForPoints() {

        // start point  lat: 6.19608, lng: -75.5751 -> 19 Lineas
        // end point    lat: 6.20623, lng: -75.5855 -> 20 lineas

        let firstLocation = CLLocation(latitude: 6.196077726336638, longitude: -75.57505116931151)
        APIManager.routesAroundLocation(firstLocation) { (routes, error) in
            if (routes.count == 19) {
                print("start point success")
            }
        }

        let secondLocation = CLLocation(latitude: 6.206232183494578, longitude: -75.58550066406245)
        APIManager.routesAroundLocation(secondLocation) { (routes, error) in
            if (routes.count == 20) {
                print("end point success")
            }
        }
    }
}

