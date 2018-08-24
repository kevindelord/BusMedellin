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

enum MBButtonState {
    case Inactive
    case Available
}

class BMLocateButton    : UIButton {

    var locationState   : MBButtonState = .Inactive {
        didSet {
            switch self.locationState {
            case .Inactive:
                let img = UIImage(named: "NearMe")?.withRenderingMode(.alwaysTemplate)
                self.setImage(img, for: .normal)
                self.tintColor = BMColor.Gray
            case .Available:
                let img = UIImage(named: "NearMe")?.withRenderingMode(.alwaysTemplate)
                self.setImage(img, for: .normal)
                self.tintColor = BMColor.Blue
            }
        }
    }

    func setup(mapView: MKMapView? = nil) {
        if ((CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways)
        && mapView?.userLocation.location != nil) {
            self.locationState = .Available
        } else {
            self.locationState = .Inactive
        }
    }
}
