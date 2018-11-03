//
//  RoutesContainerView.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

protocol RouteContainer {

	var routePageController						: RoutePageController? { get set }

//	var routePageControllerHandler				: RoutePageControllerHandler? { get set }

	func reloadAvailableRoutes(_ availableRoutes: [Route])
}

class RoutesContainerView						: UIView {

	@IBOutlet private weak var totalRoutes		: UILabel?

	// RouteContainer Protocol
	var routePageController						: RoutePageController?
//	var availableRoutes							= [Route]()

	// ContentView Protocol
	var coordinator								: Coordinator?
	var delegate								: ContentViewDelegate?

	private func configureViewTitle(routeCount: Int) {
		guard (routeCount > 0) else {
			self.totalRoutes?.text = "TODO"
			return
		}

		self.totalRoutes?.text = String(format: L("NUMBER_ROUTES_AVAILABLE"), routeCount)
	}
}

extension RoutesContainerView : RouteContainer {

	func reloadAvailableRoutes(_ availableRoutes: [Route]) {
		self.routePageController?.handler = nil
		guard (availableRoutes.isEmpty == false) else {
			self.routePageController?.reload(with: nil)
			return
		}

		let handler = RoutePageControllerHandler(availableRoutes: availableRoutes)
		self.routePageController?.reload(with: handler)
	}
}

extension RoutesContainerView : ContentView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		self.configureViewTitle(routeCount: availableRoutes.count)
		self.reloadAvailableRoutes(availableRoutes)
	}
}
