//
//  BMFooterView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class BMFooterView										: UIView {

	// MARK: - Outlets

	@IBOutlet private weak var appTitle					: UILabel?

	// MARK: - Attributes

	var coordinator										: Coordinator?

	override func awakeFromNib() {
		super.awakeFromNib()

		self.appTitle?.text = L("APP_TITLE")
	}

	// MARK: - Interface actions

	@IBAction private func infoButtonPressed() {
		self.coordinator?.openSettings()
	}
}
