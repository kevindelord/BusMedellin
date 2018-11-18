//
//  HUDContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

/// Protocol integrating the `HUDView` attribute and related in/out functions.
protocol HUDContainer {

	/// Computed property of an optional HUDView UI element.
	var progressView : HUDView? { get }

	/// Start the animation on the related computed progress view.
	func showWaitingHUD()

	/// Stop the animation on the related computed progress view.
	func hideWaitingHUD()
}

// MARK: - Protocol Extension

extension HUDContainer {

	/// Show and animate the progress view.
	func showWaitingHUD() {
		DispatchQueue.main.async {
			self.progressView?.startAnimation()
		}
	}

	/// Hide Progress View.
	func hideWaitingHUD() {
		DispatchQueue.main.async {
			print("should hide HUD")
//			self.progressView?.stopAnimation()
		}
	}
}
