//
//  BMMapContainerViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import Reachability
import MBProgressHUD

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

	func openSettings()

	/// Show Waiting HUD on MapView.
	func showWaitingHUD()

	/// Hide Waiting HUD on MapView.
	func hideWaitingHUD()
}

class MapCoordinator {

	private let routeManager	= RouteManager()

	private var container 		: ViewContainer?
	private var mapView			: ContentView?
	private var routeHeader		: ContentView?


	func prepare(for segue: UIStoryboardSegue, on container: ViewContainer) {
		if (segue.identifier == "embedHeaderView"), let viewController = segue.destination as? BMHeaderViewController {
			self.routeHeader = (viewController.view as? ContentView)
			self.routeHeader?.coordinator = self

		} else if (segue.identifier == "embedMapView"), let viewController = segue.destination as? BMMapViewController {
			self.mapView = (viewController.view as? ContentView)
			self.mapView?.coordinator = self
			(self.mapView as? BMMapView)?.routeDataSource = self.routeManager
			(self.mapView as? BMMapView)?.contentViewDelegate = self
		}

		self.container = container
		self.reloadContentView()
	}
}

extension MapCoordinator: Coordinator {

	func openSettings() {
		self.container?.performSegue(withIdentifier: "openSettingsViewController", sender: nil)
	}

	/// Show Waiting HUD on MapView.
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

	/// Hide Waiting HUD on MapView.
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

protocol ViewContainer {

	var view: UIView! { get }

	func performSegue(withIdentifier identifier: String, sender: Any?)
}

class BMMapContainerViewController	: UIViewController, ViewContainer {

	private var coordinator			= MapCoordinator()

	override func viewDidLoad() {
		super.viewDidLoad()
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
