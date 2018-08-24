//
//  BMCollectionSectionHeader.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import DKHelper

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
        self.headerContainer = UIView.load(fromNib: XibFile.BMHeaderView) as? BMHeaderView
        self.headerContainer?.frame = self.bounds
        self.headerContainer?.layer.borderWidth = 1
        self.headerContainer?.layer.borderColor = BMColor.ViewBorder.cgColor
        self.addSubview(safe: self.headerContainer)
    }
}

class BMHeaderView                          : UIView {

    // MARK: - Outlets

    @IBOutlet private weak var appTitle                 : UILabel?
    @IBOutlet private weak var routeTitle               : UILabel?
    @IBOutlet private weak var subtitle                 : UILabel?
    @IBOutlet private weak var totalRoutes              : UILabel?
    @IBOutlet private weak var infoButton               : UIButton?
    @IBOutlet private weak var logoImageView            : UIImageView?
    @IBOutlet private weak var titleBottomConstraint    : NSLayoutConstraint?

    // MARK: - Attributes

    var openSettingsBlock                   : (() -> Void)?

    // MARK: - Setup Functions

    func updateContent(availableRoutes: [Route]?, drawnRoute: Route?) {
        if (availableRoutes == nil || availableRoutes?.isEmpty == true) {
            self.showAppTitle()

        } else if let route = drawnRoute {
            // Title
            self.routeTitle?.text = route.name
            self.appTitle?.text = ""
            self.infoButton?.alpha = 0
            self.logoImageView?.alpha = 0
            // Subtitle
            self.configureSubtitle(route: route)
            // Other Routes
            self.configureOtherRoutes(availableRoutes: availableRoutes)
        }
    }

    private func configureOtherRoutes(availableRoutes: [Route]?) {
        guard
            let routes = availableRoutes,
            (routes.count > 1) else {
                return
        }
        
        self.totalRoutes?.text = String(format: L("NUMBER_ROUTES_AVAILABLE"), routes.count)
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
        self.appTitle?.text = L("APP_TITLE")
        self.infoButton?.alpha = 1
        self.logoImageView?.alpha = 1
        self.routeTitle?.text = ""
        self.subtitle?.text = ""
        self.totalRoutes?.text = ""
    }

    // MARK: - Interface actions

    @IBAction func infoButtonPressed() {
        self.openSettingsBlock?()
    }
}
