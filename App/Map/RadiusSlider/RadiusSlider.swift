//
//  RadiusSlider.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import UIKit

class RadiusSlider : UISlider {

	static let standardHeight = CGFloat(4.0)

	override func awakeFromNib() {
		super.awakeFromNib()

		self.minimumValue = Float(Map.minimumSearchRadius)
		self.maximumValue = Float(Map.maximumSearchRadius)
		self.value = Float(Map.defaultSearchRadius)
		self.tintColor = Color.blue
	}

	override func trackRect(forBounds bounds: CGRect) -> CGRect {
		var newBounds = super.trackRect(forBounds: bounds)
		newBounds.size.height = RadiusSlider.standardHeight
		return newBounds
	}
}
