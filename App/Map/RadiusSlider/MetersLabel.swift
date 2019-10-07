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
		self.layer.cornerRadius = 10.0
		self.layer.masksToBounds = true
		self.layer.borderWidth = 1
		self.layer.borderColor = Color.lightGray.cgColor
		self.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
	}
}
