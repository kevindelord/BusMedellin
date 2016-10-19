//
//  BMAddressView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 19/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

enum BMAddressViewState {
    case PickUp
    case Destination

    func dotColor() -> UIColor {
        switch self {
        case .PickUp:       return UIColor.greenColor()
        case .Destination:  return UIColor.redColor()
        }
    }

    func defaultText() -> String {
        switch self {
        case .PickUp:       return "Choose pickup location"
        case .Destination:  return "Choose destination"
        }
    }
}

class BMAddressView                         : UIView {

    @IBOutlet private weak var addressLabel : UILabel?
    @IBOutlet private weak var dotIndicator : UIView?

    private var state : BMAddressViewState = .PickUp

    func setupWithState(state: BMAddressViewState) {
        self.state = state
        self.addressLabel?.text = self.state.defaultText()
        self.dotIndicator?.backgroundColor = self.state.dotColor()
        self.dotIndicator?.roundRect(radius: 5)
    }

    func updateWithAddress(address: String?) {
        self.addressLabel?.text = (address ?? self.state.defaultText())
    }
}