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

    @IBOutlet private weak var appTitle     : UILabel?
    @IBOutlet private weak var routeTitle   : UILabel?
    @IBOutlet private weak var subtitle     : UILabel?
    @IBOutlet private weak var totalRoutes  : UILabel?
    @IBOutlet private weak var infoButton   : UIButton?
    @IBOutlet private weak var titleBottomConstraint : NSLayoutConstraint?

    func updateContent(availableRoutes: [Route]?, drawnRoute: Route?) {
        if (availableRoutes == nil || availableRoutes?.isEmpty == true) {
            self.showAppTitle()

        } else if let route = drawnRoute {
            // Title
            self.routeTitle?.text = route.name
            self.appTitle?.text = ""
            self.infoButton?.alpha = 0
            // Subtitle
            self.configureSubtitle(route)
            // Other Routes
            self.configureOtherRoutes(availableRoutes)
        }
    }

    private func configureOtherRoutes(availableRoutes: [Route]?) {
        if let routes = availableRoutes where (routes.count > 1) {
            self.totalRoutes?.text = "\(routes.count) bus routes available."
        }
    }

    private func configureSubtitle(route: Route) {
        if (route.district != "") {
            var subtitleString = route.district
            if (route.area != "") {
                subtitleString += ", \(route.area)"
            }
            self.subtitle?.text = subtitleString
            self.titleBottomConstraint?.constant = 40
        } else {
            self.subtitle?.text = ""
            self.titleBottomConstraint?.constant = 0
        }
    }

    private func showAppTitle() {
        self.appTitle?.text = "Bus Medellin"
        self.infoButton?.alpha = 1
        self.routeTitle?.text = ""
        self.subtitle?.text = ""
        self.totalRoutes?.text = ""
    }
}