//
//  BMMapCircle.swift
//  BusMedellin
//
//  Created by Kevin Delord on 24/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

class BMMapCircle   : MKCircle {

    var color       : UIColor?

    class func create(centerCoordinate coord: CLLocationCoordinate2D, radius: CLLocationDistance, color: UIColor) -> BMMapCircle {
        let circle = BMMapCircle(centerCoordinate: coord, radius: radius)
        circle.color = color
        return circle
    }

    class func createStartCircle(centerCoordinate coord: CLLocationCoordinate2D) -> BMMapCircle {
        return BMMapCircle.create(centerCoordinate: coord, radius: Map.DefaultSearchRadius, color: BMColor.Green)
    }

    class func createDestinationCircle(centerCoordinate coord: CLLocationCoordinate2D) -> BMMapCircle {
        return BMMapCircle.create(centerCoordinate: coord, radius: Map.DefaultSearchRadius, color: BMColor.Red)
    }
}
