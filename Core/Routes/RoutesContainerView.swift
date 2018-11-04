//
//  RoutesContainerView.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutesContainerView						: UIView, RouteContainer, ContentView {

	@IBOutlet private weak var totalRoutes		: UILabel?
	// TODO: integrate custom page control to deal with too many search results.

	// RouteContainer Protocol
	var routePageController						: RoutePageController?

	// ContentView Protocol
	var coordinator								: Coordinator?
	var delegate								: (RouteManagerDelegate & ContentViewDelegate)?
}

// MARK: - RouteContainer

extension RoutesContainerView {

	func reloadAvailableRoutes(_ availableRoutes: [Route]) {
		self.routePageController?.handler = nil
		guard (availableRoutes.isEmpty == false) else {
			self.routePageController?.reload(with: nil)
			return
		}

		let handler = RoutePageControllerHandler(availableRoutes: availableRoutes, delegate: self.delegate)
		self.routePageController?.reload(with: handler)
	}
}

// MARK: - ContentView

extension RoutesContainerView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		self.configureViewTitle(routeCount: availableRoutes.count)
		self.reloadAvailableRoutes(availableRoutes)
	}

	private func configureViewTitle(routeCount: Int) {
		guard (routeCount > 0) else {
			// At this stage there has been no search but the RoutesContainer is nonetheless already initialized.
			// Therefore this view also gets initialized with empty values.
			self.totalRoutes?.text = ""
			return
		}

		self.totalRoutes?.text = String(format: L("NUMBER_ROUTES_AVAILABLE"), routeCount)
	}
}
