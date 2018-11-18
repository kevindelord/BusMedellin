//
//  AppCoordinator.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class AppCoordinator			: Coordinator, ContentViewDelegate, RouteManagerDelegate {

	private let routeManager	= RouteManager()

	// Main App View Container owning the different UI elements.
	private var container		: (AppCoordinatorContainer & SearchResultCoordinator)?

	// Contained Content Views that must be retained in order to coordinate the app.
	// Depending on user actions the retained content views must be regurlarly updated.
	private var mapView			: (ContentView & MapContainer)?
	private var routesContainer	: (ContentView & RoutesContainer)?
}

// MARK: - Coordinator

extension AppCoordinator {

	func prepare(for segue: UIStoryboardSegue, on container: (AppCoordinatorContainer & SearchResultCoordinator)) {
		self.container = container

		// All containers should conform to the ContentView protocol.
		var contentView = (segue.destination.view as? ContentView)
		contentView?.coordinator = self
		contentView?.delegate = self

		// Map Container
		var mapContainer = (segue.destination.view as? MapContainer)
		mapContainer?.routeDataSource = self.routeManager

		// Retain the map and routes containers
		if let mapContentView = segue.destination.view as? (ContentView & MapContainer) {
			self.mapView = mapContentView
		}

		if let routesContentView = segue.destination.view as? (ContentView & RoutesContainer) {
			self.routesContainer = routesContentView
		}
	}

	func openSettings() {
		self.container?.performSegue(withIdentifier: Storyboard.Segue.openSettings.rawValue, sender: nil)
	}
}

// MARK: - ContentViewDelegate

extension AppCoordinator {

	/// Update/Reload all content views (Map and Routes Containers)
	func reloadContentViews() {
		let availableRoutes = self.routeManager.availableRoutes
		let selectedRoute = self.routeManager.selectedRoute

		self.mapView?.update(availableRoutes: availableRoutes, selectedRoute: selectedRoute)
		self.routesContainer?.update(availableRoutes: availableRoutes, selectedRoute: selectedRoute)

		if (availableRoutes.isEmpty == false) {
			self.container?.showSearchResults()
		} else {
			self.container?.hideSearchResults()
		}
	}

	/// Only update/reload the map content view.
	/// The routesContainer should not be updated as it is the input view for the user to select a new route.
	/// The routesContainer is already shown.
	func reloadContentViewsForSelectedRoute() {
		let availableRoutes = self.routeManager.availableRoutes
		let selectedRoute = self.routeManager.selectedRoute

		self.mapView?.update(availableRoutes: availableRoutes, selectedRoute: selectedRoute)
	}
}

// MARK: - RouteManagerDelegate

extension AppCoordinator {

	func select(route: Route) {
		self.routeManager.select(route: route)
		self.reloadContentViewsForSelectedRoute()
	}

	func cancelSearch() {
		self.routeManager.cancelSearch()
		self.reloadContentViews()
	}
}
