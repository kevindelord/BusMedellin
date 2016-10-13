//
//  BMAnnotation.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

class BMAnnotation  : NSObject, MKAnnotation {

    let title       : String?
    let subtitle    : String?
    let coordinate  : CLLocationCoordinate2D
    let reuseId     : String
    let pinColor    : MKPinAnnotationColor

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, reuseId: String, pinColor: MKPinAnnotationColor) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.reuseId = reuseId
        self.pinColor = pinColor
        super.init()
    }
}

class BMStartAnnotation : BMAnnotation {

    static func createWithCoordinates(coordinates: CLLocationCoordinate2D) -> BMStartAnnotation {
        return BMStartAnnotation(title: "Starting Point", subtitle: "Where you want to take a bus.", coordinate: coordinates, reuseId: "STARTSTART", pinColor: .Green)
    }
}

class BMDestinationAnnotation : BMAnnotation {

    static func createWithCoordinates(coordinates: CLLocationCoordinate2D) -> BMStartAnnotation {
        return BMStartAnnotation(title: "Destination Point", subtitle: "Where you want to arrive.", coordinate: coordinates, reuseId: "BMDestinationBMDestination", pinColor: .Red)
    }
}