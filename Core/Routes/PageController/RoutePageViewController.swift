//
//  RoutePageViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutePageViewController 	: UIPageViewController, RoutePageController {

	var handler 				: RoutePageControllerHandler?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.dataSource = self
		self.delegate = self
	}
}

// MARK: - RoutePageController

extension RoutePageViewController {

	func reload(with handler: RoutePageControllerHandler?) {
		self.handler = handler

		guard let initialController = self.handler?.initialRouteDetailPage as? UIViewController else {
			self.resetViewControllers()
			return
		}

		self.setViewControllers([initialController], direction: .forward, animated: true, completion: nil)
	}

	/// Overwrite the displayed controller in the memory.
	private func resetViewControllers() {
		if (self.viewControllers?.isEmpty == false) {
			self.setViewControllers([UIViewController()], direction: .forward, animated: true, completion: nil)
		}
	}
}

// MARK: - UIPageViewControllerDelegate

extension RoutePageViewController : UIPageViewControllerDelegate {

	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

		guard
			let routeDetailPage = pageViewController.viewControllers?.first as? RouteDetailPage,
			let index = self.handler?.index(of: routeDetailPage) else {
				return
		}

		self.handler?.delegate?.didMove(to: routeDetailPage, at: index)
	}
}

// MARK: - UIPageViewControllerDataSource

extension RoutePageViewController : UIPageViewControllerDataSource {

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		return self.handler?.routeDetailPage(before: viewController as? RouteDetailPage) as? UIViewController
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		return self.handler?.routeDetailPage(after: viewController as? RouteDetailPage) as? UIViewController
	}
}
