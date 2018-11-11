//
//  RoutePageViewControllerDelegate.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

protocol RoutePageViewControllerDelegate {

	/// Function called after the user did scroll to a new page within a PageViewController.
	///
	/// - Parameters:
	///   - routeDetailPage: The new current RouteDetailPage.
	///   - index: The new index of the current page.
	func didMove(to routeDetailPage: RouteDetailPage, at index: Int)
}
