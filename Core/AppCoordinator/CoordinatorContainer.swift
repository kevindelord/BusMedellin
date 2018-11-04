//
//  CoordinatorContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

protocol CoordinatorContainer {

	/// Coordinator object managing what is displayed on to the UI.
	var coordinator: Coordinator { get }

	/// Main UIView element (used to present the HUD).
	var view: UIView! { get }

	/// Required override of the native SDK functions to load the embed views.
	func performSegue(withIdentifier identifier: String, sender: Any?)
}

