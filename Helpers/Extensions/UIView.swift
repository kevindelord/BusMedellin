//
//  UIView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

extension UIView {

	func roundRect(radius: CGFloat) {
		self.layer.cornerRadius = radius
		self.layer.masksToBounds = true
	}

	/// Add a subview to the current object if the given one is not nil.
	///
	/// - Parameter view: Optional UIView object. Will not be added if nil.
	func addSubview(safe view: UIView?) {
		guard let view = view else {
			return
		}

		self.addSubview(view)
	}

	static func load(from nibName: String) -> UIView? {
		let bundle = Bundle.main
		guard (bundle.url(forResource: nibName, withExtension: ".xib") != nil || bundle.url(forResource: nibName, withExtension:".nib") != nil) else {
			return nil
		}

		return bundle.loadNibNamed(nibName, owner: nil, options: nil)?.first as? UIView
	}

	/// View controller owning the current UIView instance, usually the first view controller on the responder chain. 
	var viewController: UIViewController? {
		var responder: UIResponder? = self
		while (responder is UIViewController == false) {
			responder = responder?.next
			if (responder == nil) {
				break
			}
		}

		return (responder as? UIViewController)
	}
}
