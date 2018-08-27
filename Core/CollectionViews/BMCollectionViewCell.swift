//
//  BMCollectionViewCell.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

class BMCollectionViewCell	: UICollectionViewCell {

	var cellContainer		: BMCellView?

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
		self.cellContainer = UIView.load(from: XibFile.BMCellView) as? BMCellView
		self.cellContainer?.frame = self.bounds
		self.cellContainer?.layer.borderWidth = 1
		self.cellContainer?.layer.borderColor = BMColor.viewBorder.cgColor
		self.addSubview(safe: self.cellContainer)
	}
}
