//
//  AppCoordinatorViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

class AppCoordinatorViewController					: UIViewController, AppCoordinatorContainer, SearchResultCoordinator {

	var coordinator									: Coordinator

	@IBOutlet private weak var routesContainer		: UIView!
	@IBOutlet private weak var footerContainer		: UIView!

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
		// Only trigger the animation when necessary.
		guard (self.routesContainer.isHidden == true) else {
			return
		}

		UIView.animate(withDuration: 0.3) {
			self.footerContainer.isHidden = true
			self.routesContainer.isHidden = false
			self.view.layoutIfNeeded()
		}
	}

	func hideSearchResults() {
		// Only trigger the animation when necessary.
		guard (self.routesContainer.isHidden == false) else {
			return
		}

		UIView.animate(withDuration: 0.3) {
			self.footerContainer.isHidden = false
			self.routesContainer.isHidden = true
			self.view.layoutIfNeeded()
		}
	}
}
