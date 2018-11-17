//
//  UIColor.swift
//  BusMedellin
//
//  Created by kevindelord on 24/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

extension UIColor {

	convenience init?(red: Int, green: Int, blue: Int) {
		func minmax(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
			return ((value <= min) ? min : (value >= max) ? (max) : value)
		}

		self.init(red: minmax(value: CGFloat(red) / 255.0, min: 0.0, max: 1.0),
				  green: minmax(value: CGFloat(green) / 255.0, min: 0.0, max: 1.0),
				  blue: minmax(value: CGFloat(blue) / 255.0, min: 0.0, max: 1.0),
				  alpha: 1.0)
	}
}
