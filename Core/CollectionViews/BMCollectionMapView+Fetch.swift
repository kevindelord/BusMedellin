//
//  BMCollectionMapView+Fetch.swift
//  BusMedellin
//
//  Created by Kevin Delord on 25/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Data Management

extension BMMapView {

    /**
     Fetch coordinates of the given route and display it on the map.

     - parameter route: The Route entity to fetch and to display.
     - parameter completion: Closure called when the route has been fetched and displayed on the map.
     */
    func fetchAndDrawRoute(route: Route, completion: (() -> Void)?) {
        self.fetchAndDrawRoute(routeCode: route.code, completion: completion)
    }

    /**
     Transform an array of latitudes and longitudes into an array of CLLocationCoordinate2D.

     - parameter coordinates: Array of latitudes and longitudes.

     - returns: Array of CLLocationCoordinate2D.
     */
    private func createLocations(fromCoordinates coordinates: [[Double]]) -> [CLLocationCoordinate2D] {
        var pointsToUse = [CLLocationCoordinate2D]()
        coordinates.forEach { (values: [Double]) in
            if
                let y = values[safe: 0],
                let x = values[safe: 1] {
                pointsToUse += [CLLocationCoordinate2DMake(CLLocationDegrees(x), CLLocationDegrees(y))]
            }
        }

        return pointsToUse
    }

    /**
     Fetch coordinates of a route using its identifier (aka route code) and display it on the map.

     - parameter routeCode: The route identifier used to fetch the coordinates.
     - parameter completion: Closure called when the route has been fetched and displayed on the map.
     */
    func fetchAndDrawRoute(routeCode: String, completion: (() -> Void)?) {
        APIManager.coordinates(forRouteCode: routeCode, completion: { (coordinates: [[Double]], error: NSError?) in
            UIAlertController.showErrorPopup(error)
            let locationCoordinates = self.createLocations(fromCoordinates: coordinates)
            self.drawRouteForCoordinates(locationCoordinates)
            // Analytics
            Analytics.Route.DidDrawRoute.send(routeCode: routeCode, rounteCount: 1)
            completion?()
        })
    }

    /**
     Fetch all bus routes around given coordinates.

     - parameter coordinates:   The coordinates to search for routes around.
     - parameter completion:    Block having as parameter an array of routes passing by the given coordinates.
     */
    func fetchRoutes(forCoordinates coordinates: CLLocationCoordinate2D, completion: ((_ routes: [Route]) -> Void)?) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.fetchRoutes(forLocation: location, completion: completion)
    }

    /**
     Fetch all bus routes around a given location.

     - parameter location:   The location to search for routes around it.
     - parameter completion: Block having as parameter an array of routes passing by the given location.
     */
    private func fetchRoutes(forLocation location: CLLocation, completion: ((_ routes: [Route]) -> Void)?) {
        APIManager.routes(aroundLocation: location) { (routes: [Route], error: NSError?) in
            UIAlertController.showErrorPopup(error)
            completion?(routes)
        }
    }

    /**
     Fetch the real address of a location using the CLGeocoder.

     - parameter location:   The location to find the address.
     - parameter completion: Block having as optional parameter the address of the given location.
     */
    func fetchAddress(forLocation location: CLLocation, completion: ((_ address: String?) -> Void)?) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
            placemarks?.forEach({ (placemark: CLPlacemark) in
                DKLog(Verbose.PinAddress, "Address found: \(placemark.addressDictionary ?? [:])")
                let street = placemark.addressDictionary?[Map.Address.Street] as? String
                completion?(address: street)
            })
        }
    }
}
