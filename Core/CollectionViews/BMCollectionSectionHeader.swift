//
//  BMCollectionSectionHeader.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

class BMCollectionViewSectionHeader     : UICollectionReusableView {

    var headerContainer                 : BMHeaderView?

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
        self.headerContainer = UIView.load(from: XibFile.BMHeaderView) as? BMHeaderView
        self.headerContainer?.frame = self.bounds
        self.headerContainer?.layer.borderWidth = 1
        self.headerContainer?.layer.borderColor = BMColor.viewBorder.cgColor
        self.addSubview(safe: self.headerContainer)
    }
}
