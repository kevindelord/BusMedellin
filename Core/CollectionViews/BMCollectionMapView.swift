//
//  BMCollectionMapView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit
import DKHelper
import CSStickyHeaderFlowLayout
import MBProgressHUD
import CoreLocation

class BMCollectionMapView                               : UICollectionReusableView {

    var mapContainer                                    : BMMapView?

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

class BMMapView                                         : UIView {

    @IBOutlet weak private var mapView                  : MKMapView?
    @IBOutlet weak private var nearMeButton             : BMLocateButton?
    @IBOutlet weak private var locationButton           : UIButton?
    @IBOutlet weak private var pinDescriptionLabel      : UILabel?
    @IBOutlet weak private var pickUpInfoView           : BMAddressView?
    @IBOutlet weak private var destinationInfoView      : BMAddressView?
    @IBOutlet weak private var cancelDestinationButton  : UIButton?
    @IBOutlet weak private var cancelPickUpButton       : UIButton?
    @IBOutlet weak private var destinationInfoViewTopConstraint : NSLayoutConstraint?
    @IBOutlet weak private var linkBetweenDots          : UIView?

    private let locationManager                         = CLLocationManager()
    private var startAnnotation                         : BMAnnotation?
    private var destinationAnnotation                   : BMAnnotation?
    private var startCircle                             : BMMapCircle?
    private var destinationCircle                       : BMMapCircle?

    var didFetchAvailableRoutesBlock                    : ((routes: [Route]?) -> Void)?
    var showErrorPopupBlock                             : ((error: NSError?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private static var _onceToken: dispatch_once_t = 0
    override func layoutSubviews() {
        super.layoutSubviews()

        // Initialise the interface that way only once.
        dispatch_once(&BMMapView._onceToken) {
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

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        // Force the map to stay close to the city center.
        if (self.cityCenterLocation.distanceFromLocation(mapCenter) > Map.MaxScrollDistance) {
            self.centerMapOnLocation(self.cityCenterLocation)
        }
    }

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
            if (userLocation == nil) {
                self.showPopupToRedirectToSettings()
            }
            return userLocation
        } else if (CLLocationManager.authorizationStatus() == .Denied) {
            self.showPopupToRedirectToSettings()
            return nil
        } else {
            self.locationManager.requestWhenInUseAuthorization()
            return nil
        }
    }

    private func showPopupToRedirectToSettings() {
        let presentingViewController = UIApplication.sharedApplication().windows.first?.rootViewController
        let ac = UIAlertController(title: L("LOCATION_ERROR_TITLE"), message: L("LOCATION_ERROR_MESSAGE"), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: L("LOCATION_ERROR_CANCEL"), style: .Default, handler: nil))
        ac.addAction(UIAlertAction(title: L("LOCATION_ERROR_SETTINGS"), style: .Cancel, handler: { (action: UIAlertAction) in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }))
        presentingViewController?.presentViewController(ac, animated: true, completion: nil)
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

        if (overlay is MKGeodesicPolyline) {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = BMColor.Blue
            lineView.lineWidth = 1.5
            return lineView

        } else if let circle = overlay as? BMMapCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = (circle.color ?? UIColor.blueColor()).colorWithAlphaComponent(0.2)
            circleRenderer.strokeColor = (circle.color ?? UIColor.blueColor())
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer()
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
        self.mapView?.overlays.forEach { (overlay: MKOverlay) in
            if (overlay is MKGeodesicPolyline) {
                self.mapView?.removeOverlay(overlay)
            }
        }
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
            self.destinationInfoView?.backgroundColor = BMColor.ViewBorder
            self.destinationInfoViewTopConstraint?.constant -= ((self.destinationInfoView?.frameHeight ?? 0) * 0.5)
            self.linkBetweenDots?.alpha = 0
            // Reset map
            self.removeDrawnRoutes()
            self.mapView?.removeAnnotation(safe: self.startAnnotation)
            self.mapView?.removeOverlay(safe: self.startCircle)
            self.startAnnotation = nil
            // Reset map indicator
            self.locationButton?.setImage(UIImage(named: "pickupLocation"), forState: .Normal)
            self.pinDescriptionLabel?.text = L("PIN_PICKUP_LOCATION")
            // Notify and reload the collection view.
            self.didFetchAvailableRoutesBlock?(routes: nil)
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
            self.mapView?.removeOverlay(safe: self.destinationCircle)
            self.destinationAnnotation = nil
            // Reset map indicator
            self.locationButton?.setImage(UIImage(named: "destinationLocation"), forState: .Normal)
            self.pinDescriptionLabel?.text = L("PIN_DESTINATION_LOCATION")
            // Notify and reload the collection view with the new results.
            self.didFetchAvailableRoutesBlock?(routes: nil)
        })
    }

    @IBAction func setLocationButtonPressed() {
        if (self.startAnnotation == nil) {
            self.didSetPickUpLocation()
        } else if (self.destinationAnnotation == nil) {
            self.didSetDestinationLocation()
        }
    }

    @IBAction func locateMeButtonPressed() {
        if let userLocation = self.checkLocationAuthorizationStatus() {
            // Disable the locate me feature if the user is too far away from the city center.
            if (self.cityCenterLocation.distanceFromLocation(userLocation) < Map.MaxScrollDistance) {
                self.centerMapOnLocation(userLocation)
            } else {
                UIAlertController.showInfoMessage("", message: L("USER_LOCATION_TOO_FAR"))
            }
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
            self.startCircle = BMMapCircle.createStartCircle(centerCoordinate: centerCoordinate)
            self.mapView?.addOverlay(safe: self.startCircle)

            UIView.animateWithDuration(0.3, animations: {
                // Hide the location button and its text
                self.locationButton?.alpha = 0
                self.pinDescriptionLabel?.alpha = 0

                }, completion: { (finished: Bool) in
                    // Show waiting HUD
                    self.showWaitingHUD()
                    // Fetch the address of the location
                    let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    self.fetchAddressForLocation(location, completion: { (address: String?) in

                        // Show the address in the dedicated view.
                        self.pickUpInfoView?.updateWithAddress(address)
                        // Set the location button and text to the destination state.
                        self.locationButton?.setImage(UIImage(named: "destinationLocation"), forState: .Normal)
                        self.pinDescriptionLabel?.text = L("PIN_DESTINATION_LOCATION")
                        UIView.animateWithDuration(0.5, animations: {
                            // Show UI elements
                            self.locationButton?.alpha = 1
                            self.pinDescriptionLabel?.alpha = 1
                            self.cancelPickUpButton?.alpha = 1
                            // Show the destination address view.
                            self.destinationInfoView?.backgroundColor = UIColor.whiteColor()
                            self.destinationInfoViewTopConstraint?.constant += ((self.destinationInfoView?.frameHeight ?? 0) * 0.5)
                            self.linkBetweenDots?.alpha = 1
                            // Move the map up North a bit.
                            let newLocation = CLLocation(latitude: centerCoordinate.latitude + Map.DeltaAfterSearch, longitude: centerCoordinate.longitude)
                            let regionRadius: CLLocationDistance = self.defaultZoomRadius
                            let coordinateRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
                            self.mapView?.setRegion(coordinateRegion, animated: true)
                            // Hide waiting HUD
                            self.hideWaitingHUD()
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
            self.destinationCircle = BMMapCircle.createDestinationCircle(centerCoordinate: centerCoordinate)
            self.mapView?.addOverlay(safe: self.destinationCircle)

            UIView.animateWithDuration(0.3, animations: {
                // Hide the location button and its text
                self.locationButton?.alpha = 0
                self.pinDescriptionLabel?.alpha = 0
                self.cancelDestinationButton?.alpha = 1
                self.cancelPickUpButton?.alpha = 0

                }, completion: { (finished: Bool) in
                    // Show waiting HUD
                    self.showWaitingHUD()
                    // Fetch the address of the location
                    let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    self.fetchAddressForLocation(location, completion: { (address: String?) in
                        // Show the address in the dedicated view.
                        self.destinationInfoView?.updateWithAddress(address)
                        // Search for all available routes between the two locations.
                        self.searchForRoutesBetweenAnnotations({ (routes: [Route]) in
                            // Draw the first route as example.
                            if let routeCode = routes.first?.code {
                                self.fetchAndDrawRoute(routeCode, completion: {
                                    // Notify and reload the collection view with the new results.
                                    self.didFetchAvailableRoutesBlock?(routes: routes)
                                    // Hide waiting HUD
                                    self.hideWaitingHUD()
                                })
                            }
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

// MARK: - Waiting HUD

extension BMMapView {

    private func showWaitingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
        hud.bezelView.color = UIColor.blackColor()
        hud.contentColor = UIColor.whiteColor()
    }

    private func hideWaitingHUD() {
        MBProgressHUD.hideHUDForView(self, animated: true)
    }
}

// MARK: - Data Management

extension BMMapView {

    /**
     Fetch coordinates of the given route and display it on the map.

     - parameter route: The Route entity to fetch and to display.
     - parameter completion: Closure called when the route has been fetched and displayed on the map.
     */
    func fetchAndDrawRoute(route: Route, completion: (() -> Void)?) {
        self.fetchAndDrawRoute(route.code, completion: completion)
    }

    /**
     Fetch coordinates of a route using its identifier (aka route code) and display it on the map.

     - parameter routeCode: The route identifier used to fetch the coordinates.
     - parameter completion: Closure called when the route has been fetched and displayed on the map.
     */
    private func fetchAndDrawRoute(routeCode: String, completion: (() -> Void)?) {
        APIManager.coordinatesForRouteCode(routeCode, completion: { (coordinates: [[Double]], error: NSError?) in
            UIAlertController.showErrorPopup(error)
            let locationCoordinates = self.createLocationsFromCoordinates(coordinates)
            self.drawRouteForCoordinates(locationCoordinates)
            completion?()
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
        APIManager.routesAroundLocation(location) { (routes: [Route], error: NSError?) in
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
