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

class AppCoordinatorViewController					: UIViewController, AppCoordinatorContainer, SearchResultCoordinator {

	var coordinator									: Coordinator

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

// MARK: - SearchResultCoordinator

extension AppCoordinatorViewController {

	func showSearchResults() {
		UIView.animate(withDuration: 0.3) {
			self.footerContainer.isHidden = true
			self.routesContainer.isHidden = false
			self.view.layoutIfNeeded()
		}
	}

	func hideSearchResults() {
		UIView.animate(withDuration: 0.3) {
			self.footerContainer.isHidden = false
			self.routesContainer.isHidden = true
			self.view.layoutIfNeeded()
		}
	}
}
