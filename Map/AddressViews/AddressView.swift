//
//  AddressView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 19/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

class AddressView									: UIView, UITextFieldDelegate {

	@IBOutlet private weak var addressTextField 	: UITextField?
	@IBOutlet private weak var dotIndicator 		: UIView?

	private var location							: Location = .PickUp
	private var delegate							: MapActionDelegate?

	func setup(as location: Location, delegate: MapActionDelegate?) {
		self.location = location
		self.delegate = delegate
		self.addressTextField?.placeholder = self.location.localizedPlaceholder
		self.dotIndicator?.backgroundColor = self.location.dotColor
		self.dotIndicator?.roundRect(radius: 8)

		// Borders
		self.layer.borderWidth = 1
		self.layer.borderColor = BMColor.lightGray.cgColor
		self.dotIndicator?.layer.borderWidth = 1
		self.dotIndicator?.layer.borderColor = BMColor.darkGray.cgColor
	}

	func update(withAddress address: String?) {
		self.addressTextField?.text = address
		self.addressTextField?.clearButtonMode = (address?.isEmpty == false ? .always : .never)
	}
}

// MARK: - IBActions

extension AddressView {

	@IBAction private func clearSearch() {
		// Notify the delegate to coordinate other elements.
		self.delegate?.cancel(location: self.location)
	}
}

// MARK: - UITextFieldDelegate

extension AddressView {

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return false
	}

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		// Inform the delegate that the clear button of the text field has been pressed.
		self.delegate?.cancel(location: self.location)
		return true
	}
}
