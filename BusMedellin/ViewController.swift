//
//  ViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // start point  lat: 6.196077726336638, lng: -75.57505116931151 -> 18 Lineas
        // end point    lat: 6.206232183494578, lng: -75.58550066406245 -> 20 lineas

        APIManager.routesAroundCoordinates(lat: 6.196077726336638, lng: -75.57505116931151) { (routes, error) in
            if (routes.count == 18) {
                print("start point success")
            }
        }

        APIManager.routesAroundCoordinates(lat: 6.206232183494578, lng: -75.58550066406245) { (routes, error) in
            if (routes.count == 20) {
                print("end point success")
            }
        }
//        APIManager.coordinatesForRouteName("RU130RA", completion: { (coordinates, error) in
//            UIAlertController.showErrorPopup(error)
////            print(coordinates)
//        })
    }
}

