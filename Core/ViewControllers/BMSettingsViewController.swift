//
//  BMSettingsViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 23/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import DKHelper

class BMSettingsViewController                  : UIViewController {

    @IBOutlet private weak var versionLabel     : UILabel?
    @IBOutlet private weak var aboutTitleLabel  : UILabel?
    @IBOutlet private weak var aboutTextView    : UITextView?
    @IBOutlet private weak var bugTitleLabel    : UILabel?
    @IBOutlet private weak var bugTextLabel     : UILabel?
    @IBOutlet private weak var madeByTextView   : UITextView?

    // MARK: - Lifeview cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Screen title
        self.title = L("SETTINGS_VC_TITLE")

        // Labels
        self.versionLabel?.text = appVersion()
        self.aboutTitleLabel?.text = L("SETTINGS_ABOUT_TITLE")
        self.bugTitleLabel?.text = L("SETTINGS_BUG_TITLE")
        self.bugTextLabel?.text = L("SETTINGS_BUG_TEXT")

        // Text views
        self.setupAboutTextView()
        self.setupMadeByTextView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.sendScreenView(.Settings)
    }

    // MARK: - UI Setup functions

    private var textViewFont : UIFont {
        var font = (UIFont(name: "Helvetica Neue Light", size: 15) ?? UIFont.systemFontOfSize(15))
        if #available(iOS 8.2, *) {
            font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
        }
        return font
    }

    private func setupAboutTextView() {
        let str : NSString = L("SETTINGS_ABOUT_TEXT")
        let attrStr = NSMutableAttributedString(string: L("SETTINGS_ABOUT_TEXT"))

        [(L("SETTINGS_ABOUT_ANCHOR_1"), BMExternalLink.Project),
            (L("SETTINGS_ABOUT_ANCHOR_2"), BMExternalLink.ThibaultDurand),
            (L("SETTINGS_ABOUT_ANCHOR_3"), BMExternalLink.TwitterTDurand),
            (L("SETTINGS_ABOUT_ANCHOR_4"), BMExternalLink.WebVersion)
            ].forEach { (tuple: (anchor: String, url: String)) in
                attrStr.addAttribute(NSLinkAttributeName, value: tuple.url, range: str.rangeOfString(tuple.anchor))
        }
        attrStr.addAttribute(NSFontAttributeName, value: self.textViewFont, range: NSRange(location: 0, length: str.length))
        self.aboutTextView?.attributedText = attrStr
    }

    private func setupMadeByTextView() {
        let str : NSString = L("SETTINGS_MADE_BY")
        let attrStr = NSMutableAttributedString(string: L("SETTINGS_MADE_BY"))

        let tuple = (anchor: L("SETTINGS_MADE_BY_ANCHOR"), url: BMExternalLink.KevinDelord)
        attrStr.addAttribute(NSLinkAttributeName, value: tuple.url, range: str.rangeOfString(tuple.anchor))
        attrStr.addAttribute(NSFontAttributeName, value: self.textViewFont, range: NSRange(location: 0, length: str.length))
        // Center text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        attrStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: str.length))

        self.madeByTextView?.attributedText = attrStr
    }

    // MARK: - Interface Actions

    @IBAction func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
