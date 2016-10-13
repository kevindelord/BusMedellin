//
//  BMConstants.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import UIKit

struct BMPlist {

    static let AppId            = "AppId"
    static let APIBaseURL       = "APIBaseURL"

    struct FusionTable {
        static let Identifier   = "FusionTableId"
        static let Key          = "FusionTableKey"
    }

    static let MapDefault       = "MapDefault"

    struct CityCenter {
        static let Latitude     = "Latitude"
        static let Longitude    = "Longitude"
        static let Radius       = "Radius"
    }
}


struct API {

    struct Response {

        struct Key {
            static let Rows         = "rows"
            static let Coordinates  = "coordinates"
            static let Geometry     = "geometry"
        }
    }
}

struct Map {

    static let DefaultSearchRadius  = 500.0
}

struct BMColor {

    static let Blue             = UIColor(33, g: 150, b: 243)
    static let Gray             = UIColor(149, g: 165, b: 166)
    static let Black            = UIColor.blackColor()
}