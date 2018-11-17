//
//  HUDContainer.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol HUDContainer {

	/// Show Waiting HUD on MapView.
	func showWaitingHUD()

	/// Hide Waiting HUD on MapView.
	func hideWaitingHUD()
}

extension HUDContainer where Self: UIView {

	func showWaitingHUD() {
		DispatchQueue.main.async {
			let hud = MBProgressHUD.showAdded(to: self, animated: true)
			hud.bezelView.color = UIColor.black
			hud.contentColor = UIColor.white
		}
	}

	func hideWaitingHUD() {
		DispatchQueue.main.async {
			MBProgressHUD.hide(for: self, animated: true)
		}
	}
}
