//
//  MKMapView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {

    /**
     Adds the specified annotation to the map view.

     - parameter annotation: Optional annotation. If nil nothing happens.
     */
    func addAnnotation(safe annotation: MKAnnotation?) {
        if let _annotation = annotation {
            self.addAnnotation(_annotation)
        }
    }

    /**
     Removes the specified annotation object from the map view.

     - parameter annotation: Optional annotation. If nil nothing happens.
     */
    func removeAnnotation(safe annotation: MKAnnotation?) {
        if let _annotation = annotation {
            self.removeAnnotation(_annotation)
        }
    }

    /**
     Adds a single overlay object to the map.

     - parameter overlay: Optional overlay. If nil nothing happens.
     */
    public func addOverlay(safe overlay: MKOverlay?) {
        if let _overlay = overlay {
            self.addOverlay(_overlay)
        }
    }

    /**
     Removes a single overlay object from the map.

     - parameter overlay: Optional overlay. If nil nothing happens.
     */
    public func removeOverlay(safe overlay: MKOverlay?) {
        if let _overlay = overlay {
            self.removeOverlay(_overlay)
        }
    }
}
