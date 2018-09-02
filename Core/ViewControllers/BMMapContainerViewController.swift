//
//  BMMapContainerViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import MBProgressHUD

// TODO: add documentation for each protocol function.
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

	func reloadContentView()

	func select(route: Route)

	func cancelSearch()
}

protocol ContentView {

	func update(availableRoutes: [Route], selectedRoute: Route?)

	var coordinator: Coordinator? { get set }
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

class MapCoordinator {

	private let routeManager	= RouteManager()
	private var container 		: ViewContainer?
	private var mapView			: ContentView?
	private var routeHeader		: ContentView?
}

extension MapCoordinator: Coordinator {

	func prepare(for segue: UIStoryboardSegue, on container: ViewContainer) {
		if (segue.identifier == Segue.Embed.headerView), let viewController = segue.destination as? BMHeaderViewController {
			self.routeHeader = (viewController.view as? ContentView)
			self.routeHeader?.coordinator = self

		} else if (segue.identifier == Segue.Embed.MapView), let viewController = segue.destination as? BMMapViewController {
			self.mapView = (viewController.view as? ContentView)
			self.mapView?.coordinator = self
			(self.mapView as? BMMapView)?.routeDataSource = self.routeManager
			(self.mapView as? BMMapView)?.contentViewDelegate = self
		}

		self.container = container
		self.reloadContentView()
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

extension MapCoordinator: ContentViewDelegate {

	func reloadContentView() {
		let availableRoutes = self.routeManager.availableRoutes
		let selectedRoute = self.routeManager.selectedRoute

		self.mapView?.update(availableRoutes: availableRoutes, selectedRoute: selectedRoute)
		self.routeHeader?.update(availableRoutes: availableRoutes, selectedRoute: selectedRoute)
	}

	func select(route: Route) {
		print("TODO: display new selected route on map view")
	}

	func cancelSearch() {
		self.routeManager.selectedRoute = nil
		self.reloadContentView()
	}
}

class BMMapContainerViewController	: UIViewController, ViewContainer {

	var coordinator					: Coordinator

	required init?(coder aDecoder: NSCoder) {
		// Init coordinator depending on local needs.
		self.coordinator = MapCoordinator()

		super.init(coder: aDecoder)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		self.coordinator.prepare(for: segue, on: self)
	}
}

class BMMapViewController : UIViewController {

}

class BMHeaderViewController : UIViewController {

}
