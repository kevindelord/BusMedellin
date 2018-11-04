//
//  AppCoordinatorViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MBProgressHUD

// TODO: re-integrate for connection internet required.

protocol ViewContainer {

	/// Coordinator object managing what is displayed on to the UI.
	var coordinator: Coordinator { get }

	/// Basic view presenting the contained content.
	var view: UIView! { get }

	/// Required override of the native SDK functions to load the embed views.
	func performSegue(withIdentifier identifier: String, sender: Any?)
}

protocol ContentViewDelegate {

	/// Tells the delegate to reload all content views.
	func reloadContentViews()

	/// Tells the delegate to reload all content views with a specific selected route.
	func reloadContentViewsForSelectedRoute()
}

/// Define basic structure for displayed Content Views.
protocol ContentView {

	/// Function called when a search result has been processed and need to be displayed.
	func update(availableRoutes: [Route], selectedRoute: Route?)

	/// Action coordinator.
	var coordinator: Coordinator? { get set }

	/// Delegate to reload displayed content.
	var delegate: (RouteManagerDelegate & ContentViewDelegate)? { get set }
}

protocol Coordinator {

	/// Redirect the user to the settings flow.
	func openSettings()

	/// Show Waiting HUD on MapView.
	func showWaitingHUD()

	/// Hide Waiting HUD on MapView.
	func hideWaitingHUD()

	/// Initialize the segue's destination view controller depending on its type and the current state of the app.
	func prepare(for segue: UIStoryboardSegue, on container: ViewContainer)
}

protocol SearchResultCoordinator {

	/// View Height Constraint
	var searchResultConstraint: NSLayoutConstraint? { get set }

	/// Show the container view displaying the search results.
	func showSearchResults()

	/// Hide the container view displaying the search results.
	func hideSearchResults()
}

class AppCoordinator {

	var searchResultConstraint	: NSLayoutConstraint?

	private let routeManager	= RouteManager()
	private var container 		: ViewContainer? // TODO: what is this ?
	private var mapView			: ContentView?
	private var routesContainer	: ContentView?
}

extension AppCoordinator: SearchResultCoordinator {

	func showSearchResults() {
		self.searchResultConstraint?.constant = 150
	}

	func hideSearchResults() {
		self.searchResultConstraint?.constant = 0
	}
}

extension AppCoordinator: Coordinator {

	// TODO: refactor and improve this function.
	func prepare(for segue: UIStoryboardSegue, on container: ViewContainer) {
		if (segue.identifier == Segue.Embed.FooterView), let _ = segue.destination as? BMFooterViewController {
			// TODO: do nothing ?
			return

		} else if (segue.identifier == Segue.Embed.MapView), let viewController = segue.destination as? BMMapViewController {
			self.mapView = (viewController.view as? ContentView)
			self.mapView?.coordinator = self
			self.mapView?.delegate = self
			(self.mapView as? BMMapView)?.routeDataSource = self.routeManager

		} else if (segue.identifier == Segue.Embed.RoutesView), let viewController = segue.destination as? RoutesViewController {
			self.routesContainer = (viewController.view as? ContentView)
			self.routesContainer?.coordinator = self
			self.routesContainer?.delegate = self
		}

		self.container = container
		// TODO: what is this reload content for?
		self.reloadContentViews()
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

extension AppCoordinator: ContentViewDelegate {

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

extension AppCoordinator: RouteManagerDelegate {

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

class AppCoordinatorViewController	: UIViewController, ViewContainer {

	var coordinator					: Coordinator

	@IBOutlet private weak var searchResultHeight : NSLayoutConstraint?

	required init?(coder aDecoder: NSCoder) {
		// Init coordinator depending on local needs.
		self.coordinator = AppCoordinator()

		super.init(coder: aDecoder)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		(self.coordinator as? AppCoordinator)?.searchResultConstraint = self.searchResultHeight
		self.coordinator.prepare(for: segue, on: self)

	}
}
