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
		case .PickUp		: return BMColor.green
		case .Destination	: return BMColor.red
		}
	}

	func defaultText() -> String {
		switch self {
		case .PickUp		: return L("LOCATION_VIEW_PICKUP")
		case .Destination	: return L("LOCATION_VIEW_DESTINATION")
		}
	}
}

class BMAddressView			: UIView {

	@IBOutlet private weak var addressLabel : UILabel?
	@IBOutlet private weak var dotIndicator : UIView?

	private var state		: BMAddressViewState = .PickUp

	func setupWithState(state: BMAddressViewState) {
		self.state = state
		self.addressLabel?.text = self.state.defaultText()
		self.dotIndicator?.backgroundColor = self.state.dotColor()
		self.dotIndicator?.roundRect(radius: 5)

		// Borders
		self.layer.borderWidth = 1
		self.layer.borderColor = BMColor.viewBorder.cgColor
		self.dotIndicator?.layer.borderWidth = 1
		self.dotIndicator?.layer.borderColor = BMColor.dotBorder.cgColor
	}

	func update(withAddress address: String?) {
		self.addressLabel?.text = (address ?? self.state.defaultText())
	}
}
