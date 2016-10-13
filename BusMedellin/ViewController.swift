//
//  ViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit
import DKHelper

class ViewController                        : UIViewController {

    @IBOutlet weak var mapView              : MKMapView?
    @IBOutlet weak var nearMeButton         : BMLocateButton?
    @IBOutlet weak var destinationButton    : BMDestinationButton?
    @IBOutlet weak var startButton          : BMStartButton?

    private let locationManager             = CLLocationManager()
    private var startAnnotation             : BMAnnotation?
    private var destinationAnnotation       : BMAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // By default show Medellin city center
        self.centerMapOnLocation(self.cityCenterLocation)
        // Setup 'locate me', 'Destination' and 'Start' buttons.
        self.nearMeButton?.setup(self.mapView)
        self.startButton?.startState = .Inactive
        self.destinationButton?.destinationState = .Inactive
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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

extension ViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BMAnnotation {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.reuseId)
            annotationView.animatesDrop = true
            annotationView.pinColor = annotation.pinColor
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
        lineView.lineWidth = 1
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
        self.mapView?.removeOverlays(self.mapView?.overlays ?? [])
        // Add new overlay
        self.mapView?.addOverlay(myPolyline, level: MKOverlayLevel.AboveLabels)
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

extension ViewController {

    @IBAction func destinationButtonlocatePressed() {
        self.destinationButton?.toggleState()

        if (self.destinationAnnotation != nil) {
            self.mapView?.removeAnnotation(safe: self.destinationAnnotation)
            self.destinationAnnotation = nil
        } else if let centerCoordinate = self.mapView?.centerCoordinate {
            self.destinationAnnotation = BMDestinationAnnotation.createWithCoordinates(centerCoordinate)
            self.mapView?.addAnnotation(safe: self.destinationAnnotation)
        }
    }

    @IBAction func startButtonlocatePressed() {
        self.startButton?.toggleState()

        if (self.startAnnotation != nil) {
            self.mapView?.removeAnnotation(safe: self.startAnnotation)
            self.startAnnotation = nil
        } else if let centerCoordinate = self.mapView?.centerCoordinate {
            self.startAnnotation = BMStartAnnotation.createWithCoordinates(centerCoordinate)
            self.mapView?.addAnnotation(safe: self.startAnnotation)
        }
    }

    @IBAction func locateMeButtonPressed() {
        if let location = self.checkLocationAuthorizationStatus() {
            self.nearMeButton?.locationState = .Active
            self.centerMapOnLocation(location)
            self.fetchRoutesForLocation(location)
        } else {
            self.nearMeButton?.locationState = .Inactive
        }
    }
}

// MARK: - Data

extension ViewController {

    private func fetchCoordinatesForRouteName(routeName: String) {

        APIManager.coordinatesForRouteName(routeName, completion: { (coordinates, error) in
            UIAlertController.showErrorPopup(error)
            let locationCoordinates = self.createLocationsFromCoordinates(coordinates)
            self.drawRouteForCoordinates(locationCoordinates)
        })
    }

    private func fetchRoutesForLocation(location: CLLocation) {

        APIManager.routesAroundLocation(location) { (routes, error) in
            UIAlertController.showErrorPopup(error)
            if let routeName = routes.first?.code {
                self.fetchCoordinatesForRouteName(routeName)
            }
        }
    }
}

// MARK: - Debug

extension ViewController {

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

