//
//  AddressView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 19/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

class AddressView							: UIView {

	@IBOutlet private weak var addressLabel : UILabel?
	@IBOutlet private weak var dotIndicator : UIView?

	private var location					: Location = .PickUp

	func setup(as location: Location) {
		self.location = location
		self.addressLabel?.text = self.location.localizedPlaceholder
		self.dotIndicator?.backgroundColor = self.location.dotColor
		self.dotIndicator?.roundRect(radius: 5)

		// Borders
		self.layer.borderWidth = 1
		self.layer.borderColor = BMColor.lightGray.cgColor
		self.dotIndicator?.layer.borderWidth = 1
		self.dotIndicator?.layer.borderColor = BMColor.darkGray.cgColor
	}

	func update(withAddress address: String?) {
		self.addressLabel?.text = (address ?? self.location.localizedPlaceholder)
	}
}
