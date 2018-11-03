//
//  RouteManagerDelegate.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

protocol RouteManagerDelegate {

	/// Cancel the search and reset the attributes.
	func cancelSearch()

	/// Manually set the selected Route
	func select(route: Route)
}
