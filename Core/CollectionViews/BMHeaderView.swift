//
//  BMHeaderView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class BMHeaderView										: UIView {

	// MARK: - Outlets

	@IBOutlet private weak var appTitle					: UILabel?
	@IBOutlet private weak var routeTitle				: UILabel?
	@IBOutlet private weak var subtitle					: UILabel?
	@IBOutlet private weak var totalRoutes				: UILabel?
	@IBOutlet private weak var infoButton				: UIButton?
	@IBOutlet private weak var logoImageView			: UIImageView?
	@IBOutlet private weak var titleBottomConstraint	: NSLayoutConstraint?

	// MARK: - Attributes

	var coordinator										: Coordinator?

	// MARK: - Interface actions

	@IBAction private func infoButtonPressed() {
		self.coordinator?.openSettings()
	}
}

// MARK: - ContentView

extension BMHeaderView: ContentView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		guard
			let route = selectedRoute,
			(availableRoutes.isEmpty == false) else {
				self.showAppTitle()
				return
		}

		self.showRouteDetail(availableRoutes, route: route)
	}
}

// MARK: - UI Update

extension BMHeaderView {

	private func showRouteDetail(_ availableRoutes: [Route], route: Route) {
		// Title
		self.routeTitle?.text = route.name
		self.appTitle?.text = ""
		self.infoButton?.alpha = 0
		self.logoImageView?.alpha = 0
		// Subtitle
		self.configureSubtitle(route: route)
		// Other Routes
		self.configureOtherRoutes(availableRoutes: availableRoutes)
	}

	private func configureOtherRoutes(availableRoutes: [Route]?) {
		guard
			let routes = availableRoutes,
			(routes.count > 1) else {
				return
		}

		self.totalRoutes?.text = String(format: L("NUMBER_ROUTES_AVAILABLE"), routes.count)
	}

	private func configureSubtitle(route: Route) {
		if (route.district != "") {
			var subtitleString = route.district
			if (route.area != "") {
				subtitleString += ", \(route.area)"
			}

			self.subtitle?.text = subtitleString
			self.titleBottomConstraint?.constant = 40
		} else {
			self.subtitle?.text = ""
			self.titleBottomConstraint?.constant = 0
		}
	}

	private func showAppTitle() {
		self.appTitle?.text = L("APP_TITLE")
		self.infoButton?.alpha = 1
		self.logoImageView?.alpha = 1
		self.routeTitle?.text = ""
		self.subtitle?.text = ""
		self.totalRoutes?.text = ""
	}
}
