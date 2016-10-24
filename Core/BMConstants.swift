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
    static let BuglifeID        = "BuglifeID"

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

struct StaticHeight {

    struct CollectionView {

        static let Cell             : CGFloat = 80
        static let SectionHeader    : CGFloat = 80
    }
}

struct Map {

    static let DefaultSearchRadius  = 500.0
    static let DeltaAfterSearch     = 0.007
    static let MaxScrollDistance    : Double = 12000.0

    struct Address {

        static let Street           = "Street"
    }
}

struct Segue {

    static let Settings         = "openSettingsViewController"
}

struct XibFile {

    static let BMMapView        = "BMMapView"
    static let BMHeaderView     = "BMHeaderView"
    static let BMCellView       = "BMCellView"
}

struct ReuseId {

    static let ParallaxHeader   = "MapCollectionView_ParallaxHeader"
    static let SectionHeader    = "CollectionView_SectionHeader"
    static let ResultCell       = "CollectionView_ResultCell"
    static let PickUpPin        = "PickUpAnnotaion_Id"
    static let DestinationPin   = "DestinationAnnotaion_Id"
}

struct BMColor {

    static let Red              = UIColor(255, g: 59, b: 48)
    static let Green            = UIColor(76, g: 217, b: 100)
    static let Blue             = UIColor(33, g: 150, b: 243)
    static let Gray             = UIColor(149, g: 165, b: 166)
    static let Black            = UIColor.blackColor()
    static let ViewBorder       = UIColor(230, g: 230, b: 230)
    static let DotBorder        = UIColor(150, g: 150, b: 150)
}

struct BMExternalLink {

    static let Project          = "https://github.com/kevindelord/BusMedellin"
    static let ThibaultDurand   = "https://github.com/tdurand"
    static let TwitterTDurand   = "https://twitter.com/tibbb"
    static let WebVersion       = "http://tdurand.github.io/mapamedellin"
    static let KevinDelord      = "https://github.com/kevindelord"
}
