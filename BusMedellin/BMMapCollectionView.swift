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

class BMMapCollectionView                       : UICollectionReusableView {

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

class BMMapView                                 : UIView {

    @IBOutlet weak var mapView                  : MKMapView?
    @IBOutlet weak var nearMeButton             : BMLocateButton?
    @IBOutlet weak var locationButton           : UIButton?
    @IBOutlet weak var pinDescriptionLabel      : UILabel?
    @IBOutlet weak var pickUpInfoView           : BMAddressView?
    @IBOutlet weak var destinationInfoView      : BMAddressView?
    @IBOutlet weak var cancelDestinationButton  : UIButton?
    @IBOutlet weak var cancelPickUpButton       : UIButton?
    @IBOutlet weak var destinationInfoViewTopConstraint : NSLayoutConstraint?

    private let locationManager                 = CLLocationManager()
    private var startAnnotation                 : BMAnnotation?
    private var destinationAnnotation           : BMAnnotation?

    var didFetchAvailableRoutesBlock            : ((routes: [Route]) -> Void)?
    var showErrorPopupBlock                     : ((error: NSError?) -> Void)?

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
            // Setup 'locate me' button.
            self.nearMeButton?.setup(self.mapView)
            // Setup address views
            self.pickUpInfoView?.setupWithState(.PickUp)
            self.destinationInfoView?.setupWithState(.Destination)
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
            annotationView?.animatesDrop = false
            annotationView?.pinColor = annotation.pinColor
            annotationView?.canShowCallout = false
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

    @IBAction func cancelPickUpButtonPressed() {

        UIView.animateWithDuration(0.3, animations: {
            // Hide UI elements
            self.locationButton?.alpha = 1
            self.pinDescriptionLabel?.alpha = 1
            self.cancelPickUpButton?.alpha = 0
            self.pickUpInfoView?.updateWithAddress(nil)
            // Show the destination address view.
            self.destinationInfoView?.backgroundColor = UIColor(230, g: 230, b: 230)
            self.destinationInfoViewTopConstraint?.constant -= ((self.destinationInfoView?.frameHeight ?? 0) * 0.5)
            // Reset map
            self.removeDrawnRoutes()
            self.mapView?.removeAnnotation(safe: self.startAnnotation)
            self.startAnnotation = nil
            // Reset map indicator
            self.locationButton?.setImage(UIImage(named: "pickupLocation"), forState: .Normal)
            self.pinDescriptionLabel?.text = "SET PICKUP LOCATION"
        })
    }

    @IBAction func cancelDestinationButtonPressed() {

        UIView.animateWithDuration(0.3, animations: {
            // Hide UI elements
            self.locationButton?.alpha = 1
            self.pinDescriptionLabel?.alpha = 1
            self.cancelDestinationButton?.alpha = 0
            self.cancelPickUpButton?.alpha = 1
            self.destinationInfoView?.updateWithAddress(nil)
            // Reset map
            self.removeDrawnRoutes()
            self.mapView?.removeAnnotation(safe: self.destinationAnnotation)
            self.destinationAnnotation = nil
            // Reset map indicator
            self.locationButton?.setImage(UIImage(named: "destinationLocation"), forState: .Normal)
            self.pinDescriptionLabel?.text = "SET DESTINATION"
        })
    }

    @IBAction func locationButtonPressed() {

        if (self.startAnnotation == nil) {
            self.didSetPickUpLocation()
        } else if (self.destinationAnnotation == nil) {
            self.didSetDestinationLocation()
        }
    }

    @IBAction func locateMeButtonPressed() {
        if let location = self.checkLocationAuthorizationStatus() {
            self.centerMapOnLocation(location)
        }
    }
}

// MARK: - Functionalities

extension BMMapView {

    private func didSetPickUpLocation() {
        if let centerCoordinate = self.mapView?.centerCoordinate {
            // Add a new annotation at the center of the map.
            self.startAnnotation = BMStartAnnotation.createWithCoordinates(centerCoordinate)
            self.mapView?.addAnnotation(safe: self.startAnnotation)

            UIView.animateWithDuration(0.3, animations: {
                // Hide the location button and its text
                self.locationButton?.alpha = 0
                self.pinDescriptionLabel?.alpha = 0

                }, completion: { (finished: Bool) in
                    // Fetch the address of the location
                    let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    self.fetchAddressForLocation(location, completion: { (address) in

                        // Show the address in the dedicated view.
                        self.pickUpInfoView?.updateWithAddress(address)
                        // Set the location button and text to the destination state.
                        self.locationButton?.setImage(UIImage(named: "destinationLocation"), forState: .Normal)
                        self.pinDescriptionLabel?.text = "SET DESTINATION"
                        UIView.animateWithDuration(0.5, animations: {
                            // Show UI elements
                            self.locationButton?.alpha = 1
                            self.pinDescriptionLabel?.alpha = 1
                            self.cancelPickUpButton?.alpha = 1
                            // Show the destination address view.
                            self.destinationInfoView?.backgroundColor = UIColor.whiteColor()
                            self.destinationInfoViewTopConstraint?.constant += ((self.destinationInfoView?.frameHeight ?? 0) * 0.5)
                            // Move the map up North a bit.
                            let newLocation = CLLocation(latitude: centerCoordinate.latitude + Map.DeltaAfterSearch, longitude: centerCoordinate.longitude)
                            let regionRadius: CLLocationDistance = self.defaultZoomRadius
                            let coordinateRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
                            self.mapView?.setRegion(coordinateRegion, animated: true)
                        })
                    })
            })
        }
    }

    private func didSetDestinationLocation() {
        if let centerCoordinate = self.mapView?.centerCoordinate {
            // Add a new destination pin at the center of the map.
            self.destinationAnnotation = BMDestinationAnnotation.createWithCoordinates(centerCoordinate)
            self.mapView?.addAnnotation(safe: self.destinationAnnotation)

            UIView.animateWithDuration(0.3, animations: {
                // Hide the location button and its text
                self.locationButton?.alpha = 0
                self.pinDescriptionLabel?.alpha = 0
                self.cancelDestinationButton?.alpha = 1
                self.cancelPickUpButton?.alpha = 0

                }, completion: { (finished: Bool) in
                    // Fetch the address of the location
                    let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    self.fetchAddressForLocation(location, completion: { (address) in
                        // Show the address in the dedicated view.
                        self.destinationInfoView?.updateWithAddress(address)
                        //
                        self.searchForRoutesBetweenAnnotations({ (routes: [Route]) in
                            // Draw the first route as example.
                            if let routeCode = routes.first?.code {
                                self.fetchAndDrawRoute(routeCode)
                            }
                            // Notify and reload the collection view with the new results.
                            self.didFetchAvailableRoutesBlock?(routes: routes)
                        })
                    })
            })
        }
    }

    private func searchForRoutesBetweenAnnotations(completion: ((routes: [Route]) -> Void)?) {

        if let pickUpCoordinate = self.startAnnotation?.coordinate {
            // Fetch all routes passing by the pick up location.
            self.fetchRoutesForCoordinates(pickUpCoordinate, completion: { (pickUpRoutes: [Route]) in

                if let destinationCoordinate = self.destinationAnnotation?.coordinate {
                    // Fetch all routes passing by the destination location.
                    self.fetchRoutesForCoordinates(destinationCoordinate, completion: { (destinationRoutes: [Route]) in

                        // Filter the routes to only the ones matching.
                        var commonRoutes = [Route]()
                        for pickUpRoute in pickUpRoutes {
                            for destinationRoute in destinationRoutes
                                where (destinationRoute.code == pickUpRoute.code) {
                                    commonRoutes.append(destinationRoute)
                            }
                        }
                        completion?(routes: commonRoutes)
                    })
                }
            })
        }
    }
}

// MARK: - Data Management

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

    /**
     Fetch all bus routes around given coordinates.

     - parameter coordinates:   The coordinates to search for routes around.
     - parameter completion:    Block having as parameter an array of routes passing by the given coordinates.
     */
    private func fetchRoutesForCoordinates(coordinates: CLLocationCoordinate2D, completion: ((routes: [Route]) -> Void)?) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.fetchRoutesForLocation(location, completion: completion)
    }

    /**
     Fetch all bus routes around a given location.

     - parameter location:   The location to search for routes around it.
     - parameter completion: Block having as parameter an array of routes passing by the given location.
     */
    private func fetchRoutesForLocation(location: CLLocation, completion: ((routes: [Route]) -> Void)?) {
        APIManager.routesAroundLocation(location) { (routes, error) in
            UIAlertController.showErrorPopup(error)
            completion?(routes: routes)
        }
    }

    /**
     Fetch the real address of a location using the CLGeocoder.

     - parameter location:   The location to find the address.
     - parameter completion: Block having as optional parameter the address of the given location.
     */
    func fetchAddressForLocation(location: CLLocation, completion: ((address: String?) -> Void)?) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
            placemarks?.forEach({ (placemark: CLPlacemark) in
                DKLog(Verbose.PinAddress, "Address found: \(placemark.addressDictionary ?? [:])")
                let street = placemark.addressDictionary?[Map.Address.Street] as? String
                completion?(address: street)
            })
        }
    }
}
