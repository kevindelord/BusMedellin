//
//  BMCollectionViewCell.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

class BMCollectionViewCell                      : UICollectionViewCell {

    var cellContainer                           : BMCellView?

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
        self.cellContainer = UIView.loadFromNib(XibFile.BMCellView) as? BMCellView
        self.cellContainer?.frame = self.bounds
        self.cellContainer?.layer.borderWidth = 1
        self.cellContainer?.layer.borderColor = BMColor.ViewBorder.CGColor
        self.addSubview(safe: self.cellContainer)
    }
}

class BMCellView                                : UICollectionViewCell {

    @IBOutlet private weak var titleLabel       : UILabel?
    @IBOutlet private weak var subtitleLabel    : UILabel?
    @IBOutlet private weak var titleBottomConstraint : NSLayoutConstraint?

    func updateContent(route: Route) {
        // Title
        self.titleLabel?.text = route.name

        // Subtitle
        if (route.district != "") {
            var subtitleString = route.district
            if (route.area != "") {
                subtitleString += ", \(route.area)"
            }
            self.subtitleLabel?.text = subtitleString
            self.titleBottomConstraint?.constant = 20
        } else {
            self.subtitleLabel?.text = ""
            self.titleBottomConstraint?.constant = 0
        }
    }
}
