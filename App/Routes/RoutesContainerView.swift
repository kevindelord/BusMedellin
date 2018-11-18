//
//  RoutesContainerView.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutesContainerView						: UIView, RoutesContainer, ContentView, RoutePageViewControllerDelegate {

	@IBOutlet private weak var totalRoutes		: UILabel?

	// RouteContainer Protocol
	var routePageController						: RoutePageController?
	var routePageControl 						: RoutePageControl?

	// ContentView Protocol
	var coordinator								: Coordinator?
	var delegate								: (RouteManagerDelegate & ContentViewDelegate)?
}

// MARK: - RoutePageViewControllerDelegate

extension RoutesContainerView {

	func didMove(to routeDetailPage: RouteDetailPage, at index: Int) {
		guard let route = routeDetailPage.route else {
			return
		}

		self.routePageControl?.update(currentPage: index)
		self.delegate?.select(route: route)
		Analytics.Route.didSelectRoute.send(routeCode: route.code, rounteCount: 1)
	}
}

// MARK: - RouteContainer

extension RoutesContainerView {

	func reload(availableRouteDetailPages pages: [RouteDetailPage]) {
		self.routePageControl?.reload(numberOfPages: pages.count)
		self.routePageController?.handler = nil

		guard (pages.isEmpty == false) else {
			self.routePageController?.reload(with: nil)
			return
		}

		let handler = RoutePageControllerHandler(availableRouteDetailPages: pages, delegate: self)
		self.routePageController?.reload(with: handler)
	}
}

// MARK: - ContentView

extension RoutesContainerView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		self.configureViewTitle(routeCount: availableRoutes.count)
		let availableRouteDetailPages = self.detailPages(for: availableRoutes)
		self.reload(availableRouteDetailPages: availableRouteDetailPages)
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

	/// Create view controllers to display in the UIPageController.
	/// Returns objects conforming to protocol instead of UIViewControllers.
	///
	/// This function is only one "knowing" that the PageController displays instances of RouteDetailViewController.
	///
	/// - Parameter routes: Available Bus Routes.
	/// - Returns: Array of object conforming to the RouteDetailPage protocol.
	private func detailPages(for routes: [Route]) -> [RouteDetailPage] {
		var pages = [RouteDetailPage]()

		for route in routes {
			let storyboard = UIStoryboard(name: Storyboard.Routes, bundle: nil)
			let controller = storyboard.instantiateViewController(withIdentifier: Storyboard.Controller.Route)
			if let routeController = controller as? RouteDetailViewController {
				routeController.route = route
				pages.append(routeController)
			}
		}

		return pages
	}
}
