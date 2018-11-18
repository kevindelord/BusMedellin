//
//  RoutePageControllerHandler.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutePageControllerHandler	: RoutePageControllerDataSource {

	private var routeDetailPages	: [RouteDetailPage]
	private(set) weak var delegate	: RoutePageViewControllerDelegate?

	init(availableRouteDetailPages routeDetailPages: [RouteDetailPage], delegate: RoutePageViewControllerDelegate?) {
		self.delegate = delegate
		self.routeDetailPages = routeDetailPages
	}
}

// MARK: - RoutePageController DataSource

extension RoutePageControllerHandler {

	var initialRouteDetailPage: RouteDetailPage? {
		return self.routeDetailPages.first
	}

	var numberOfRouteDetailPages: Int {
		return self.routeDetailPages.count
	}

	func index(of routeDetailPage: RouteDetailPage) -> Int? {
		// In Swift 4.2 it is not possible to get the index of an element within an array or protocols.
		// That said protocol could only be used as a generic constraint because it has Self or associated type requirements.
		for (index, object) in self.routeDetailPages.enumerated() {
			if (object.isEqual(routeDetailPage)) {
				return index
			}
		}

		return nil
	}

	func routeDetailPage(before routeDetailPage: RouteDetailPage?) -> RouteDetailPage? {
		guard
			(self.numberOfRouteDetailPages > 1),
			let routeDetailPage = routeDetailPage,
			let index = self.index(of: routeDetailPage),
			(self.numberOfRouteDetailPages > (index - 1)) else {
				return nil
		}

		return self.routeDetailPages[safe: (index - 1)]
	}

	func routeDetailPage(after routeDetailPage: RouteDetailPage?) -> RouteDetailPage? {
		guard
			(self.numberOfRouteDetailPages > 1),
			let routeDetailPage = routeDetailPage,
			let index = self.index(of: routeDetailPage),
			(self.numberOfRouteDetailPages > (index + 1)) else {
				return nil
		}

		return self.routeDetailPages[safe: (index + 1)]
	}
}
