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

		if (segue.identifier == Segue.Embed.PageController), let pageController = segue.destination as? RoutePageController {
			var routeContainer = (self.view as? RoutesContainer)
			routeContainer?.routePageController = pageController
		}

		if (segue.identifier == Segue.Embed.PageControl), let pageControl = segue.destination.view as? RoutePageControl {
			var routeContainer = (self.view as? RoutesContainer)
			routeContainer?.routePageControl = pageControl
		}
	}
}
