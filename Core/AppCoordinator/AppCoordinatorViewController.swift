//
//  AppCoordinatorViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

// TODO: re-integrate for connection internet required.
// TODO: review localised strings

class AppCoordinatorViewController					: UIViewController, AppCoordinatorContainer {

	var coordinator									: Coordinator

	@IBOutlet internal weak var stackView			: UIStackView!
	@IBOutlet internal weak var routesContainer		: UIView!
	@IBOutlet internal weak var footerContainer		: UIView!

	required init?(coder aDecoder: NSCoder) {
		self.coordinator = AppCoordinator()

		super.init(coder: aDecoder)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		self.coordinator.prepare(for: segue, on: self)
	}
}

// MARK: - AppCoordinatorContainer

extension AppCoordinatorViewController {

	func layoutIfNeeded() {
		self.view.layoutIfNeeded()
	}
}
