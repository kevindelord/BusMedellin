//
//  RoutePageController.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutePageController 	: UIPageViewController {

	var handler 			: RoutePageControllerHandler?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.dataSource = self
		self.delegate = self.handler

		self.configurePageControl()
	}

	func reload(with handler: RoutePageControllerHandler?) {
		self.handler = handler

		guard let initialController = self.handler?.initialRouteController else {
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

// MARK: - UIPageViewControllerDataSource

extension RoutePageController : UIPageViewControllerDataSource {

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		return self.handler?.viewController(before: viewController as? RouteViewController)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		return self.handler?.viewController(after: viewController as? RouteViewController)
	}
}

// MARK: - Page Control

extension RoutePageController {

	private func configurePageControl() {
		let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
		pageControl.currentPageIndicatorTintColor = .black
		pageControl.pageIndicatorTintColor = UIColor.lightGray
		pageControl.backgroundColor = .white
		pageControl.hidesForSinglePage = true
	}

	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return (self.handler?.numberOfRouteControllers ?? 0)
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		guard
			let routeViewController = pageViewController.viewControllers?.first as? RouteViewController,
			let index = self.handler?.index(of: routeViewController) else {
				return 0
		}

		return index
	}
}
