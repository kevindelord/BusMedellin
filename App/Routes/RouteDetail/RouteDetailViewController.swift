//
//  RouteDetailViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RouteDetailViewController							: UIViewController, RouteDetailPage {

	@IBOutlet private weak var containerView			: UIView?
	@IBOutlet private weak var titleLabel				: UILabel?
	@IBOutlet private weak var subtitleLabel			: UILabel?

	var route											: Route?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add a rounded box.
		self.containerView?.layer.borderWidth = 1.0
		self.containerView?.layer.borderColor = Color.darkGray.cgColor
		self.containerView?.roundRect(radius: 5)

		// Hide the subtitle by default.
		self.subtitleLabel?.isHidden = true

		// Display the Route name.
		self.updateContent()
	}

	private func updateContent() {
		guard let route = self.route else {
			return
		}

		// Title
		self.titleLabel?.text = route.name
		// Subtitle
		self.subtitleLabel?.text = route.description
		self.subtitleLabel?.isHidden = (route.description.isEmpty == true)
	}
}
