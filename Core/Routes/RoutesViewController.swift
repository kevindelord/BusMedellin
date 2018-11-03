//
//  RoutesViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutesViewController : UIViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)

		if (segue.identifier == Segue.Embed.PageController), let viewController = segue.destination as? RoutePageController {
			var routeContainer = (self.view as? RouteContainer)
			routeContainer?.routePageController = viewController
		}
	}
}
