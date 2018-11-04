//
//  RouteViewController.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RouteViewController								: UIViewController {

	@IBOutlet private weak var titleLabel				: UILabel?
	@IBOutlet private weak var subtitleLabel			: UILabel?
	@IBOutlet private weak var titleBottomConstraint	: NSLayoutConstraint?
	// TODO: connect `titleBottomConstraint` and add shade box.

	var route											: Route?

	override func viewDidLoad() {
		super.viewDidLoad()

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
			self.titleBottomConstraint?.constant = 20
		} else {
			self.subtitleLabel?.text = ""
			self.titleBottomConstraint?.constant = 0
		}
	}
}
