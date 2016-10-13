//
//  BMLocateButton.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum LocateButtonState {
    case Inactive
    case Available
    case Active
}

class BMLocateButton    : UIButton {

    var locationState   : LocateButtonState = .Inactive {
        didSet {
            switch self.locationState {
            case .Inactive:
                let img = UIImage(named: "NearMe")?.imageWithRenderingMode(.AlwaysTemplate)
                self.setImage(img, forState: .Normal)
                self.tintColor = BMColor.Gray
            case .Available:
                let img = UIImage(named: "NearMe")?.imageWithRenderingMode(.AlwaysTemplate)
                self.setImage(img, forState: .Normal)
                self.tintColor = BMColor.Blue
            case .Active:
                let img = UIImage(named: "NearMeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
                self.setImage(img, forState: .Normal)
                self.tintColor = BMColor.Blue
            }
        }
    }

    func setup(mapView: MKMapView? = nil) {
        if ((CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways)
        && mapView?.userLocation.location != nil) {
            self.locationState = .Available
        } else {
            self.locationState = .Inactive
        }
    }
}