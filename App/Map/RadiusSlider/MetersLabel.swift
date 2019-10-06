//
//  MetersLabel.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import UIKit

class MetersLabel : UILabel {

	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
		self.backgroundColor = .white
		self.textAlignment = .center
		// TODO: set text font
		// TODO: add border, round corners and shadow
	}
}
