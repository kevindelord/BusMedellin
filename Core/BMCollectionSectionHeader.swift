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
        self.headerContainer = UIView.loadFromNib(XibFile.BMHeaderView) as? BMHeaderView
        self.headerContainer?.frame = self.bounds
        self.headerContainer?.layer.borderWidth = 1
        self.headerContainer?.layer.borderColor = BMColor.ViewBorder.CGColor
        self.addSubview(safe: self.headerContainer)
    }
}

class BMHeaderView                          : UIView {

    @IBOutlet private weak var title        : UILabel?
    @IBOutlet private weak var subtitle     : UILabel?
    @IBOutlet private weak var infoButton   : UIButton?

    func updateContent(availableRoutes: [Route]?, drawnRoute: Route?) {
        if (availableRoutes == nil) {
            self.title?.text = "Bus Medellin"
            self.infoButton?.alpha = 1
            self.subtitle?.text = ""
        } else if (availableRoutes?.isEmpty == false && drawnRoute == nil) {
            self.title?.text = "\((availableRoutes?.count ?? 0)) bus routes available"
            self.infoButton?.alpha = 0
        } else if (availableRoutes?.isEmpty == false && drawnRoute != nil) {
            self.subtitle?.text = "\((availableRoutes?.count ?? 0)) bus routes available"
            self.title?.text = (drawnRoute?.name ?? "")
            self.infoButton?.alpha = 0
        }
    }
}