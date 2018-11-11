//
//  AddressViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

// TODO: Review animation duration, previous duration: 0.5
// TODO: Fix bug when using the cancel buttons.
// TODO: Change cancel button. Find something nicer.

class AddressViewController 									: UIViewController, MapCoordinatedElement, AddressViewContainer {

	@IBOutlet weak private var pickUpInfoView					: AddressView?
	@IBOutlet weak private var destinationInfoView				: AddressView?
	@IBOutlet weak private var cancelDestinationButton			: UIButton?
	@IBOutlet weak private var cancelPickUpButton				: UIButton?
	@IBOutlet weak private var destinationInfoViewPosition 		: NSLayoutConstraint?

	var delegate												: MapActionDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup address views
		self.pickUpInfoView?.setup(as: .PickUp)
		self.destinationInfoView?.setup(as: .Destination)
		// Setup cancel buttons
		let imageInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
		self.cancelPickUpButton?.imageEdgeInsets = imageInset
		self.cancelDestinationButton?.imageEdgeInsets = imageInset
	}
}

// MARK: - AddressViewContainer

extension AddressViewController {

	func update(location: Location, withAddress address: String?) {
		let view = (location == .PickUp ? self.pickUpInfoView : self.destinationInfoView)
		view?.update(withAddress: address)

	}

	func show(viewForLocation location: Location) {
		UIView.animate(withDuration: 0.3, animations: {
			if (location == .PickUp) {
				self.cancelDestinationButton?.alpha = 0
				self.cancelPickUpButton?.alpha = 0
				self.destinationInfoView?.backgroundColor = BMColor.lightGray
				self.destinationInfoViewPosition?.isActive = false

			} else if (location == .Destination) {
				self.cancelDestinationButton?.alpha = 0
				self.cancelPickUpButton?.alpha = 1
				self.destinationInfoView?.backgroundColor = .white
				self.destinationInfoViewPosition?.isActive = true
			}
		})
	}
}

// MARK: - MapCoordinatedElement

extension AddressViewController {

	func didCancel(location: Location) {
		UIView.animate(withDuration: 0.3, animations: {
			if (location == .PickUp) {
				self.cancelPickUpButton?.alpha = 0
				self.pickUpInfoView?.update(withAddress: nil)
			} else if (location == .Destination) {
				self.destinationInfoView?.update(withAddress: nil)
				self.show(viewForLocation: .PickUp)
			}
		})
	}
}

// MARK: - IBAction

extension AddressViewController {

	/// Function called when the user presses the 'x' to cancel the PICKUP location.
	@IBAction private func cancelPickUpButtonPressed() {
		// Notify the delegate to coordinate other elements.
		self.delegate?.cancel(location: .PickUp)
	}

	/// Function called when the user presses the 'x' to cancel the DESTINATION location.
	@IBAction private func cancelDestinationButtonPressed() {
		// Notify the delegate to coordinate other elements.
		self.delegate?.cancel(location: .Destination)
	}
}
