//
//  ContentView.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

/// Define basic structure for displayed Content Views.
protocol ContentView {

	/// Function called when a search result has been processed and need to be displayed.
	func update(availableRoutes: [Route], selectedRoute: Route?)

	/// Action coordinator.
	var coordinator: Coordinator? { get set }

	/// Delegate to reload displayed content.
	var delegate: (RouteManagerDelegate & ContentViewDelegate)? { get set }
}

