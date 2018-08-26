//
//  BMCellView.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

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
