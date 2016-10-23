//
//  BMSettingsViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 23/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import DKHelper

class BMSettingsViewController              : UIViewController {

    @IBOutlet private weak var versionLabel : UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Information"
        self.versionLabel?.text = appVersion()
    }

    @IBAction func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
