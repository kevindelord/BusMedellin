//
//  RouteViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RouteViewController								: UIViewController {

	@IBOutlet private weak var containerView			: UIView?
	@IBOutlet private weak var titleLabel				: UILabel?
	@IBOutlet private weak var subtitleLabel			: UILabel?

	var route											: Route?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.containerView?.layer.borderWidth = 1.0
		self.containerView?.layer.borderColor = BMColor.darkGray.cgColor
		self.containerView?.roundRect(radius: 5)

		self.updateContent()
	}

	private func updateContent() {
		guard let route = self.route else {
			return
		}

		// Title
		self.titleLabel?.text = route.name

		// Subtitle
		if (route.district != "") {
			var subtitleString = route.district
			if (route.area != "") {
				subtitleString += ", \(route.area)"
			}

			self.subtitleLabel?.text = subtitleString
			self.subtitleLabel?.isHidden = false
		} else {
			self.subtitleLabel?.text = ""
			self.subtitleLabel?.isHidden = true
		}
	}
}
