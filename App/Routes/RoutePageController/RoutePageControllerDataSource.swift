//
//  RoutePageControllerDataSource.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// Extract the DataSource logic out of a UIPageViewController instance.
protocol RoutePageControllerDataSource: AnyObject {

	/// Initial route detail page used to setup the first page of a UIPageViewController stack.
	var initialRouteDetailPage: RouteDetailPage? { get }

	/// Total number of pages.
	var numberOfRouteDetailPages: Int { get }

	/// Returns the index of a given page.
	///
	/// - Parameter routeDetailPage: Displayed RouteDetailPage to find the index of.
	/// - Returns: Index of the given page; nil if not found.
	func index(of routeDetailPage: RouteDetailPage) -> Int?

	/// Returns the previous RouteDetailPage before the given one.
	func routeDetailPage(before routeDetailPage: RouteDetailPage?) -> RouteDetailPage?

	/// Returns the next RouteDetailPage after the given one.
	func routeDetailPage(after routeDetailPage: RouteDetailPage?) -> RouteDetailPage?
}
