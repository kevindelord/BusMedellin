//
//  RouteContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// Search Result Container displaying available routes.
protocol RouteContainer {

	/// Page Controller displayed all avaialble routes from a specific search.
	var routePageController : RoutePageController? { get set }

	/// Load and display new available routes.
	func reloadAvailableRoutes(_ availableRoutes: [Route])
}
