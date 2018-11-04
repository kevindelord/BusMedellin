//
//  AppCoordinatorViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

// TODO: re-integrate for connection internet required.

class AppCoordinatorViewController					: UIViewController, CoordinatorContainer {

	var coordinator									: Coordinator

	@IBOutlet private weak var searchResultHeight 	: NSLayoutConstraint?

	required init?(coder aDecoder: NSCoder) {
		self.coordinator = AppCoordinator()

		super.init(coder: aDecoder)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		(self.coordinator as? AppCoordinator)?.searchResultConstraint = self.searchResultHeight
		self.coordinator.prepare(for: segue, on: self)
	}
}
