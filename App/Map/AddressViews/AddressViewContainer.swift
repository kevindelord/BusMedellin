//
//  AddressViewContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// When conforming to this protocol, an object is supposed to handled UI views to show address Locations.
/// How the UI is or how the address are shown to the user is not relevant.
protocol AddressViewContainer {

	/// Update the UI elements related to a given location with an address text.
	///
	/// - Parameters:
	///   - location: Location that should be updated.
	///   - address: Related address selected by the user for a given location.
	func update(location: Location, withAddress address: String?)

	/// Present the UI elements related to a given location.
	///
	/// - Parameter location: Location that should be displayed/highlighted to the user.
	func show(viewForLocation location: Location)
}
