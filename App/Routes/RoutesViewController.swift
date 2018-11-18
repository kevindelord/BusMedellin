//
//  RoutesViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

/// Initial View Controller from the Routes.storyboard used to setup the view containers.
class RoutesViewController : UIViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		// There is no need to check the segue's identifier as each destination controller conforms to dedicated protocols.
		if let pageController = segue.destination as? RoutePageController {
			var routeContainer = (self.view as? RoutesContainer)
			routeContainer?.routePageController = pageController
		}

		if let pageControl = segue.destination.view as? RoutePageControl {
			var routeContainer = (self.view as? RoutesContainer)
			routeContainer?.routePageControl = pageControl
		}
	}
}
