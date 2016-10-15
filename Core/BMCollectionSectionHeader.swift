//
//  BMCollectionSectionHeader.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

class BMCollectionViewSectionHeader: UICollectionReusableView {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.addSubview(self.label)
        self.label.frame = self.bounds
        self.label.text = UICollectionElementKindSectionHeader
    }
}
