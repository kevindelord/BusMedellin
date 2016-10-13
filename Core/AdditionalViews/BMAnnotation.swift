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

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate

        super.init()
    }
}