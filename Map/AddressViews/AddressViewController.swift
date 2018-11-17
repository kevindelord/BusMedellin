//
//  AddressViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class AddressViewController 									: UIViewController, MapCoordinatedElement, AddressViewContainer {

	@IBOutlet weak private var pickUpInfoView					: AddressView?
	@IBOutlet weak private var destinationInfoView				: AddressView?
	@IBOutlet weak private var destinationInfoViewPosition 		: NSLayoutConstraint?

	var delegate												: MapActionDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup address views
		self.pickUpInfoView?.setup(as: .PickUp, delegate: self.delegate)
		self.destinationInfoView?.setup(as: .Destination, delegate: self.delegate)
		self.show(viewForLocation: .PickUp)
	}
}

// MARK: - AddressViewContainer

extension AddressViewController {

	func update(location: Location, withAddress address: String?) {
		switch location {
		case .PickUp: self.pickUpInfoView?.update(withAddress: address)
		case .Destination: self.destinationInfoView?.update(withAddress: address)
		}
	}

	func show(viewForLocation location: Location) {
		UIView.animate(withDuration: 0.3, animations: {
			switch location {
			case .PickUp:
				self.destinationInfoView?.backgroundColor = BMColor.lightGray
				self.destinationInfoViewPosition?.isActive = false
				self.destinationInfoView?.isUserInteractionEnabled = false
				self.destinationInfoView?.update(withAddress: nil)

			case .Destination:
				self.destinationInfoView?.backgroundColor = .white
				self.destinationInfoView?.isUserInteractionEnabled = true
				self.destinationInfoViewPosition?.isActive = true
			}
		})
	}
}

// MARK: - MapCoordinatedElement

extension AddressViewController {

	func didCancel(location: Location) {
		self.show(viewForLocation: location)

		UIView.animate(withDuration: 0.3, animations: {
			switch location {
			case .PickUp:		self.pickUpInfoView?.update(withAddress: nil)
			case .Destination:	self.destinationInfoView?.update(withAddress: nil)
			}
		})
	}
}
