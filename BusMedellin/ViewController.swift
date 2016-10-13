//
//  ViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView : MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
//        CLLocationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func fetchCoordinatesForRouteName() {
        APIManager.coordinatesForRouteName("RU130RA", completion: { (coordinates, error) in
            UIAlertController.showErrorPopup(error)
            print(coordinates)
        })
    }

    private func fetchRoutesForPoints() {

        // start point  lat: 6.19608, lng: -75.5751 -> 19 Lineas
        // end point    lat: 6.20623, lng: -75.5855 -> 20 lineas

        APIManager.routesAroundCoordinates(lat: 6.196077726336638, lng: -75.57505116931151) { (routes, error) in
            if (routes.count == 19) {
                print("start point success")
            }
        }

        APIManager.routesAroundCoordinates(lat: 6.206232183494578, lng: -75.58550066406245) { (routes, error) in
            if (routes.count == 20) {
                print("end point success")
            }
        }
    }
}

