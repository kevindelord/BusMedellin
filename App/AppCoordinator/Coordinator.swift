//
//  Coordinator.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {

	/// Redirect the user to the settings flow.
	func openSettings()

	/// Initialize the segue's destination view controller depending on its type and the current state of the app.
	func prepare(for segue: UIStoryboardSegue, on container: (AppCoordinatorContainer & SearchResultCoordinator))
}
