//
//  RoutePageControllerHandler.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

// TODO: Document and extract protocols.

protocol RoutePageControllerDataSource {

	var initialRouteController 		: RouteViewController?  { get }

	var numberOfRouteControllers	: Int { get }

	func index(of routeController: RouteViewController) -> Int?

	func viewController(before viewController: RouteViewController?) -> RouteViewController?

	func viewController(after viewController: RouteViewController?) -> RouteViewController?
}

protocol RoutePageControllerDelegate {

	func didMove(to routeController: RouteViewController)
}

class RoutePageControllerHandler	: RoutePageControllerDataSource, RoutePageControllerDelegate {

	private var routeControllers	: [RouteViewController]
	private var delegate			: RouteManagerDelegate?

	init(availableRoutes routes: [Route], delegate: RouteManagerDelegate?) {
		self.delegate = delegate
		self.routeControllers = []

		for route in routes {
			let storyboard = UIStoryboard(name: Storyboard.Routes, bundle: nil)
			let controller = storyboard.instantiateViewController(withIdentifier: Storyboard.Controller.Route)
			if let routeController = controller as? RouteViewController {
				routeController.route = route
				self.routeControllers.append(routeController)
			}
		}
	}
}

// MARK: - RoutePageController DataSource

extension RoutePageControllerHandler {

	var initialRouteController 			: RouteViewController? {
		return self.routeControllers.first
	}

	var numberOfRouteControllers		: Int {
		return self.routeControllers.count
	}

	func index(of routeController		: RouteViewController) -> Int? {
		return self.routeControllers.index(of: routeController)
	}

	func viewController(before viewController: RouteViewController?) -> RouteViewController? {
		guard
			(self.numberOfRouteControllers > 1),
			let routeViewController = viewController,
			let index = self.index(of: routeViewController) else {
				return nil
		}

		let previousIndex = (index - 1)

		// User is on the first view controller and swiped left to loop to the last view controller.
		guard (previousIndex >= 0) else {
			return self.routeControllers.last
		}

		guard (self.numberOfRouteControllers > previousIndex) else {
			return nil
		}

		return self.routeControllers[previousIndex]
	}

	func viewController(after viewController: RouteViewController?) -> RouteViewController? {
		guard
			(self.numberOfRouteControllers > 1),
			let routeViewController = viewController,
			let index = self.index(of: routeViewController) else {
				return nil
		}

		let nextIndex = (index + 1)

		// User is on the last view controller and swiped right to loop to the first view controller.
		guard (self.numberOfRouteControllers != nextIndex) else {
			return self.routeControllers.first
		}

		guard (self.numberOfRouteControllers > nextIndex) else {
			return nil
		}

		return self.routeControllers[nextIndex]
	}
}

// MARK: RoutePageController Delegate

extension RoutePageControllerHandler {

	func didMove(to routeController: RouteViewController) {
		guard let route = routeController.route else {
			return
		}

		self.delegate?.select(route: route)
	}
}
