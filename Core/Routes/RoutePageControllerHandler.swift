//
//  RoutePageControllerHandler.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

protocol RoutePageControllerDataSource {

	var initialRouteController 		: RouteViewController?  { get }

	var numberOfRouteControllers	: Int { get }

	func index(of routeController: RouteViewController) -> Int?
}

class RoutePageControllerHandler 	: NSObject {

	private var routeControllers	: [RouteViewController]

	override init() {
		self.routeControllers = []

		super.init()
	}

	convenience init(availableRoutes routes: [Route]) {
		self.init()

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

extension RoutePageControllerHandler	: RoutePageControllerDataSource {

	var initialRouteController 			: RouteViewController? {
		return self.routeControllers.first
	}

	var numberOfRouteControllers		: Int {
		return self.routeControllers.count
	}

	func index(of routeController		: RouteViewController) -> Int? {
		return self.routeControllers.index(of: routeController)
	}
}

// MARK: Delegate

extension RoutePageControllerHandler: UIPageViewControllerDelegate {

	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

		if let firstViewController = pageViewController.viewControllers?.first as? RouteViewController,
			let index = self.index(of: firstViewController) {
			print("new index: \(index)")
			//				tutorialDelegate?.tutorialPageViewController(self, didUpdatePageIndex: index)
		}
	}
}

// MARK: DataSource

extension RoutePageControllerHandler {

	func viewController(before viewController: RouteViewController?) -> RouteViewController? {
		guard
			(self.routeControllers.count > 1),
			let routeViewController = viewController,
			let index = self.index(of: routeViewController) else {
				return nil
		}

		let previousIndex = (index - 1)

		// User is on the first view controller and swiped left to loop to the last view controller.
		guard (previousIndex >= 0) else {
			return self.routeControllers.last
		}

		guard (self.routeControllers.count > previousIndex) else {
			return nil
		}

		return self.routeControllers[previousIndex]
	}

	func viewController(after viewController: RouteViewController?) -> RouteViewController? {
		guard
			(self.routeControllers.count > 1),
			let routeViewController = viewController,
			let index = self.index(of: routeViewController) else {
				return nil
		}

		let nextIndex = (index + 1)

		// User is on the last view controller and swiped right to loop to the first view controller.
		guard (self.routeControllers.count != nextIndex) else {
			return self.routeControllers.first
		}

		guard (self.routeControllers.count > nextIndex) else {
			return nil
		}

		return self.routeControllers[nextIndex]
	}
}
