//
//  RoutesContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

/// Search Result Container displaying available routes.
protocol RoutesContainer: AnyObject {

	/// Page Controller to display all avaialble routes from a specific search.
	var routePageController : RoutePageController? { get set }

	/// Page Control to display the current index
	var routePageControl : RoutePageControl? { get set }

	/// Load and display new available routes.
	func reload(availableRouteDetailPages: [RouteDetailPage])
}
