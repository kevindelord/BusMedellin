//
//  AppCoordinator.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import MBProgressHUD

class AppCoordinator			: SearchResultCoordinator, Coordinator, ContentViewDelegate, RouteManagerDelegate {

	var searchResultConstraint	: NSLayoutConstraint?

	private let routeManager	= RouteManager()

	// Main App View Container owning the different UI elements.
	private var container 		: CoordinatorContainer?

	// Contained Content Views that must be retained in order to coordinate the app.
	// Depending on user actions the retained content views must be regurlarly updated.
	private var mapView			: ContentView?
	private var routesContainer	: ContentView?
}

// MARK: - SearchResultCoordinator

extension AppCoordinator {

	func showSearchResults() {
		self.searchResultConstraint?.constant = 150
	}

	func hideSearchResults() {
		self.searchResultConstraint?.constant = 0
	}
}

// MARK: - Coordinator

extension AppCoordinator {

	func prepare(for segue: UIStoryboardSegue, on container: CoordinatorContainer) {
		self.container = container

		// All containers view should conform to the ContentView protocol.
		var contentView = (segue.destination.view as? ContentView)
		contentView?.coordinator = self
		contentView?.delegate = self

		// Retain the map and routes containers
		if (segue.identifier == Segue.Embed.MapView) {
			(contentView as? BMMapView)?.routeDataSource = self.routeManager
			self.mapView = contentView
		}

		if (segue.identifier == Segue.Embed.RoutesView) {
			self.routesContainer = contentView
		}
	}

	func openSettings() {
		self.container?.performSegue(withIdentifier: Segue.settings, sender: nil)
	}

	func showWaitingHUD() {
		guard let view = self.container?.view else {
			return
		}

		DispatchQueue.main.async {
			let hud = MBProgressHUD.showAdded(to: view, animated: true)
			hud.bezelView.color = UIColor.black
			hud.contentColor = UIColor.white
		}
	}

	func hideWaitingHUD() {
		guard let view = self.container?.view else {
			return
		}

		DispatchQueue.main.async {
			MBProgressHUD.hide(for: view, animated: true)
		}
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
			self.showSearchResults()
		} else {
			self.hideSearchResults()
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
		self.hideSearchResults()
	}
}
