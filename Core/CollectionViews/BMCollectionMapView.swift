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
import Reachability

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
            self.pinDescriptionLabel?.text = L("PIN_PICKUP_LOCATION")
            self.pickUpInfoView?.setupWithState(.PickUp)
            self.destinationInfoView?.setupWithState(.Destination)
            // Setup cancel buttons
            let imageInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
            self.cancelPickUpButton?.imageEdgeInsets = imageInset
            self.cancelDestinationButton?.imageEdgeInsets = imageInset
        }
    }

    /// Default city center location
    private var cityCenterLocation : CLLocation {
        let info = NSBundle.entryInPListForKey(BMPlist.MapDefault) as? [String:String]
        let latitude = (Double(info?[BMPlist.CityCenter.Latitude] ?? "0") ?? 0)
        let longitude = (Double(info?[BMPlist.CityCenter.Longitude] ?? "0") ?? 0)
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Default zoom radius of the mapView.
    private var defaultZoomRadius : CLLocationDistance {
        let info = NSBundle.entryInPListForKey(BMPlist.MapDefault) as? [String:String]
        let radius = Double(info?[BMPlist.CityCenter.Radius] ?? "0")
        return (radius ?? 0)
    }
}

// MARK: - MapView Delegate functions

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

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // If the location suddenly become available adapt the location button.
        if (userLocation.location == nil) {
            self.nearMeButton?.locationState = .Inactive
        } else if (self.nearMeButton?.locationState == .Inactive) {
            self.nearMeButton?.locationState = .Available
        }
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
}

// MARK: - User Location functions

extension BMMapView {

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
            Analytics.UserLocation.DidAskForUserLocation.send()
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
        Analytics.UserLocation.DidAskForSettings.send()
    }
}

// MARK: - MapView Utility functions

extension BMMapView {

    /**
     Center the map on a specific location.

     - parameter location: Location to center the map to.
     */
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = self.defaultZoomRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView?.setRegion(coordinateRegion, animated: true)
    }

    /**
     Draw a new route on the map using a set of coordinates.

     This function also removes all already drawn routes from the mapView.

     - parameter coordinates: Array of coordinates representing the route to display.
     */
    func drawRouteForCoordinates(coordinates: [CLLocationCoordinate2D]) {

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

    /**
     Remove any drawn routes from the mapView.
     */
    private func removeDrawnRoutes() {
        self.mapView?.overlays.forEach { (overlay: MKOverlay) in
            if (overlay is MKGeodesicPolyline) {
                self.mapView?.removeOverlay(overlay)
            }
        }
    }

    /**
     Add a new start/pickup annotation on the map.

     - parameter coordinate: Coordinate of the annotation.
     */
    private func addPickupAnnotation(coordinate: CLLocationCoordinate2D) {
        self.startAnnotation = BMStartAnnotation.createWithCoordinates(coordinate)
        self.mapView?.addAnnotation(safe: self.startAnnotation)
        self.startCircle = BMMapCircle.createStartCircle(centerCoordinate: coordinate)
        self.mapView?.addOverlay(safe: self.startCircle)
    }

    /**
     Add a new destination annotation on the map.

     - parameter coordinate: Coordinate of the annotation.
     */
    private func addDestinationAnnotation(coordinate: CLLocationCoordinate2D) {
        self.destinationAnnotation = BMDestinationAnnotation.createWithCoordinates(coordinate)
        self.mapView?.addAnnotation(safe: self.destinationAnnotation)
        self.destinationCircle = BMMapCircle.createDestinationCircle(centerCoordinate: coordinate)
        self.mapView?.addOverlay(safe: self.destinationCircle)
    }

    /**
     Move the mapView up North from the given coordinates.

     - parameter coordinate: Coordinate from where to move/scroll north.
     - parameter delta:      Delta to move the map.
     */
    private func moveMapViewNorthFromCoordinate(coordinate: CLLocationCoordinate2D, delta: Double = Map.DeltaAfterSearch) {
        let newLocation = CLLocation(latitude: coordinate.latitude + delta, longitude: coordinate.longitude)
        let regionRadius: CLLocationDistance = self.defaultZoomRadius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius, regionRadius)
        self.mapView?.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - Interface Builder Action

extension BMMapView {

    /**
     Function called when the user presses the 'x' to cancel the PICKUP location.
     */
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
            // Analytics
            Analytics.PinLocation.DidCancelStart.send()
        })
    }

    /**
     Function called when the user presses the 'x' to cancel the DESTINATION location.
     */
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
            // Analytics
            Analytics.PinLocation.DidCancelDestination.send()
        })
    }

    /**
     Function called when the user selects a pickup or destination location.
     This function checks what needs to be set and forward the process to a more dedicated function.
     */
    @IBAction func setLocationButtonPressed() {
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

    /**
     Function called when the user presses the 'near me' (or aka 'locate me') button.
     */
    @IBAction func locateMeButtonPressed() {
        if let userLocation = self.checkLocationAuthorizationStatus() {
            // Disable the locate me feature if the user is too far away from the city center.
            if (self.cityCenterLocation.distanceFromLocation(userLocation) < Map.MaxScrollDistance) {
                self.centerMapOnLocation(userLocation)
                Analytics.UserLocation.DidLocateUser.send()
            } else {
                UIAlertController.showInfoMessage("", message: L("USER_LOCATION_TOO_FAR"))
                Analytics.UserLocation.DidLocateUserTooFar.send()
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
            self.addPickupAnnotation(centerCoordinate)

            UIView.animateWithDuration(0.3, animations: {
                // Hide the location button and its text
                self.locationButton?.alpha = 0
                self.pinDescriptionLabel?.alpha = 0

                }, completion: { (finished: Bool) in
                    // Show waiting HUD
                    self.showWaitingHUD()
                    // Analytics
                    Analytics.PinLocation.DidSetStart.send()
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
                            self.moveMapViewNorthFromCoordinate(centerCoordinate)
                            // Hide waiting HUD
                            self.hideWaitingHUD()
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
            self.addDestinationAnnotation(centerCoordinate)

            UIView.animateWithDuration(0.3, animations: {
                // Hide the location button and its text
                self.locationButton?.alpha = 0
                self.pinDescriptionLabel?.alpha = 0
                self.cancelDestinationButton?.alpha = 1
                self.cancelPickUpButton?.alpha = 0

                }, completion: { (finished: Bool) in
                    // Show waiting HUD
                    self.showWaitingHUD()
                    // Analytics
                    Analytics.PinLocation.DidSetDestination.send()
                    // Fetch the address of the location
                    let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                    self.fetchAddressForLocation(location, completion: { (address: String?) in
                        // Show the address in the dedicated view.
                        self.destinationInfoView?.updateWithAddress(address)
                        // Search for all available routes between the two locations.
                        self.searchForRoutesBetweenAnnotations()
                    })
            })
        }
    }

    /**
     Fetch routes around both PICKUP and DESTINATION annotations.
     */
    private func searchForRoutesBetweenAnnotations() {
        if let pickUpCoordinate = self.startAnnotation?.coordinate {
            // Fetch all routes passing by the pick up location.
            self.fetchRoutesForCoordinates(pickUpCoordinate, completion: { (pickUpRoutes: [Route]) in
                // Analytics
                Analytics.Route.DidSearchForStartRoutes.send(routeCode: nil, rounteCount: pickUpRoutes.count)

                if let destinationCoordinate = self.destinationAnnotation?.coordinate {
                    // Fetch all routes passing by the destination location.
                    self.fetchRoutesForCoordinates(destinationCoordinate, completion: { (destinationRoutes: [Route]) in
                        // Analytics
                        Analytics.Route.DidSearchForDestinationRoutes.send(routeCode: nil, rounteCount: destinationRoutes.count)

                        // Filter the routes to only the ones matching.
                        let matchingRoutes = self.findMatchingRoutes(pickUpRoutes: pickUpRoutes, destinationRoutes: destinationRoutes)
                        self.didFindMatchingRoutes(matchingRoutes)
                    })
                }
            })
        }
    }

    /**
     If any draw the first matching route and send them all to the collection view to reload the list.

     - parameter matchingRoutes: Array of routes that go through both PICKUP and DESTINATION annotation areas.
     */
    private func didFindMatchingRoutes(matchingRoutes: [Route]) {
        // Analytics
        Analytics.Route.DidSearchForMatchingRoutes.send(routeCode: nil, rounteCount: matchingRoutes.count)
        // Draw the first route as example.
        if let routeCode = matchingRoutes.first?.code {
            self.fetchAndDrawRoute(routeCode, completion: {
                self.didFinishFetchingAndDrawingNewRoutes(matchingRoutes)
            })
        } else {
            self.didFinishFetchingAndDrawingNewRoutes(matchingRoutes)
        }

    }

    /**
     Filter the available routes to only the ones going through both PICKUP and DESTINATION annotation areas.

     - parameter pickUpRoutes:      All routes going through the PICKUP annotation area.
     - parameter destinationRoutes: All routes going through the DESTINATION annotation area.

     - returns: Array of matching routes that go through both PICKUP and DESTINATION annotation areas.
     */
    private func findMatchingRoutes(pickUpRoutes pickUpRoutes: [Route], destinationRoutes: [Route]) -> [Route] {
        var commonRoutes = [Route]()
        for pickUpRoute in pickUpRoutes {
            for destinationRoute in destinationRoutes
                where (destinationRoute.code == pickUpRoute.code) {
                    commonRoutes.append(destinationRoute)
            }
        }
        return commonRoutes
    }

    /**
     Send all matching routes to the collection view to reload the list.
     This function also Hides any waiting HUD on the mapView.

     - parameter routes: Array of routes that go through both PICKUP and DESTINATION annotation areas.
     */
    private func didFinishFetchingAndDrawingNewRoutes(routes: [Route]) {
        // Notify and reload the collection view with the new results.
        self.didFetchAvailableRoutesBlock?(routes: routes)
        // Hide waiting HUD
        self.hideWaitingHUD()
    }
}

// MARK: - Waiting HUD

extension BMMapView {

    /**
     Show Waiting HUD on MapView.
     */
    private func showWaitingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
        hud.bezelView.color = UIColor.blackColor()
        hud.contentColor = UIColor.whiteColor()
    }

    /**
     Hide Waiting HUD on MapView.
     */
    private func hideWaitingHUD() {
        MBProgressHUD.hideHUDForView(self, animated: true)
    }
}
