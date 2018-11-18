//
//  PinLocationContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 17/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// When conforming to this protocol, an object is supposed to handled UI views to let the user know where the annotation pins will be set.
protocol PinLocationContainer: AnyObject {

	/// Configure the current interface to adapt to a new Location.
	///
	/// - Parameter location: Location interface to show the user.
	func configureInterface(forLocation location: Location)

	/// Show the indicator (with its current configuration) to the user.
	func show()

	/// Show the indicator from the user.
	func hide()
}
