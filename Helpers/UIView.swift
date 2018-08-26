//
//  UIView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

extension UIView {

    func roundRect(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    /**
     Add a subview to the current object if the given one is not nil.

     - parameter view: Optional UIView object. Will not be added if nil.
     */
    func addSubview(safe view: UIView?) {
        guard let view = view else {
			return
		}

		self.addSubview(view)
    }
}
