//
//  FooterView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class FooterView										: UIView {

	// MARK: - Outlets

	@IBOutlet private weak var appTitle					: UILabel?

	// MARK: - Attributes

	weak var coordinator								: Coordinator?
	weak var delegate									: (ContentViewDelegate & RouteManagerDelegate)?

	override func awakeFromNib() {
		super.awakeFromNib()

		self.appTitle?.text = L("APP_TITLE")
	}
}

extension FooterView {

	@IBAction private func infoButtonPressed() {
		self.coordinator?.openSettings()
	}
}

extension FooterView : ContentView {

	// Conforming to protocol. No feature to implement in this footer.
	func update(availableRoutes: [Route], selectedRoute: Route?) {
	}
}
