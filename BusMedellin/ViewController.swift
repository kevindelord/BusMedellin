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

class ViewController: UIViewController {

    @IBOutlet weak var mapView : MKMapView?

    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locateMeButtonPressed()
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

    private func checkLocationAuthorizationStatus() -> CLLocation {
        if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
            self.mapView?.showsUserLocation = true
            let userLocation = self.mapView?.userLocation.location
            return (userLocation ?? self.cityCenterLocation)
        } else {
            self.locationManager.requestWhenInUseAuthorization()
            return self.cityCenterLocation
        }
    }

    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = self.defaultZoomRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView?.setRegion(coordinateRegion, animated: true)
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {

        let lineView = MKPolylineRenderer(overlay: overlay)
        lineView.strokeColor = Map.RouteColor
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

// MARK: - Interface Action

extension ViewController {

    @IBAction func locateMeButtonPressed() {
        let location = self.checkLocationAuthorizationStatus()
        self.centerMapOnLocation(location)
        self.fetchRoutesForLocation(location)
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

