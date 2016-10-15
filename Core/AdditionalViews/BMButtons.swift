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
    case Active
}

class BMLocateButton    : UIButton {

    var locationState   : MBButtonState = .Inactive {
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

class BMDestinationButton   : UIButton {

    var destinationState    : MBButtonState = .Inactive {
        didSet {
            let img = UIImage(named: "buttonFinishLine")?.imageWithRenderingMode(.AlwaysTemplate)
            self.setImage(img, forState: .Normal)

            switch self.destinationState {
            case .Inactive:             self.tintColor = BMColor.Gray
            case .Available, .Active:   self.tintColor = BMColor.Black
            }
        }
    }

    func toggleState() {
        if (self.destinationState == .Inactive) {
            self.destinationState = .Active
        } else {
            self.destinationState = .Inactive
        }
    }
}

class BMStartButton         : UIButton {

    var startState          : MBButtonState = .Inactive {
        didSet {
            let img = UIImage(named: "buttonStart")?.imageWithRenderingMode(.AlwaysTemplate)
            self.setImage(img, forState: .Normal)

            switch self.startState {
            case .Inactive:             self.tintColor = BMColor.Gray
            case .Available, .Active:   self.tintColor = BMColor.Black
            }
        }
    }

    func toggleState() {
        if (self.startState == .Inactive) {
            self.startState = .Active
        } else {
            self.startState = .Inactive
        }
    }
}
