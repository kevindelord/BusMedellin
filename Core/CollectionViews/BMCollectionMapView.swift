//
//  BMCollectionMapView.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import UIKit

class BMCollectionMapView	: UICollectionReusableView {

	var mapContainer		: BMMapView?

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.clipsToBounds = true
		self.interfaceInitialisation()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.interfaceInitialisation()
	}

	private func interfaceInitialisation() {
		self.mapContainer = UIView.load(from: XibFile.mapView) as? BMMapView
		self.mapContainer?.frame = self.bounds
		self.addSubview(safe: self.mapContainer)
	}
}
