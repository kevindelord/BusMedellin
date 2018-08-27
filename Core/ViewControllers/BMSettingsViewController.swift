//
//  BMSettingsViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 23/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

class BMSettingsViewController					: UIViewController {

	@IBOutlet private weak var versionLabel		: UILabel?
	@IBOutlet private weak var aboutTitleLabel	: UILabel?
	@IBOutlet private weak var aboutTextView	: UITextView?
	@IBOutlet private weak var bugTitleLabel	: UILabel?
	@IBOutlet private weak var bugTextLabel		: UILabel?
	@IBOutlet private weak var madeByTextView	: UITextView?

	// MARK: - Lifeview cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		// Screen title
		self.title = L("SETTINGS_VC_TITLE")

		// Labels
		self.configureVersionLabel()
		self.aboutTitleLabel?.text = L("SETTINGS_ABOUT_TITLE")
		self.bugTitleLabel?.text = L("SETTINGS_BUG_TITLE")
		self.bugTextLabel?.text = L("SETTINGS_BUG_TEXT")

		// Text views
		self.setupAboutTextView()
		self.setupMadeByTextView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		Analytics.send(screenView: .settings)
	}

	// MARK: - UI Setup functions

	private func configureVersionLabel() {
		guard
			let info = Bundle.main.infoDictionary,
			let shortVersion = info["CFBundleShortVersionString"] as? String,
			let bundleVersion = info["CFBundleVersion"] as? String else {
				self.versionLabel?.text = ""
				return
		}

		// TODO: localize
		self.versionLabel?.text = "Version \(shortVersion) (\(bundleVersion))"
	}

	private var textViewFont : UIFont {
		var font = (UIFont(name: "Helvetica Neue Light", size: 15) ?? UIFont.systemFont(ofSize: 15))
		if #available(iOS 8.2, *) {
			font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
		}

		return font
	}

	private func setupAboutTextView() {
		let str = L("SETTINGS_ABOUT_TEXT")
		let attrStr = NSMutableAttributedString(string: L("SETTINGS_ABOUT_TEXT"))

		let anchors : [(text: String, url: String)] = [
			(L("SETTINGS_ABOUT_ANCHOR_1"), BMExternalLink.project),
			(L("SETTINGS_ABOUT_ANCHOR_2"), BMExternalLink.thibaultDurand),
			(L("SETTINGS_ABOUT_ANCHOR_3"), BMExternalLink.twitterTDurand),
			(L("SETTINGS_ABOUT_ANCHOR_4"), BMExternalLink.webVersion)
		]

		for anchor in anchors {
			attrStr.addAttribute(.link, value: anchor.url, range: (str as NSString).range(of: anchor.text))
		}

		attrStr.addAttribute(.font, value: self.textViewFont, range: NSRange(location: 0, length: str.count))
		self.aboutTextView?.attributedText = attrStr
	}

	private func setupMadeByTextView() {
		let str = L("SETTINGS_MADE_BY")
		let attrStr = NSMutableAttributedString(string: L("SETTINGS_MADE_BY"))

		let tuple = (anchor: L("SETTINGS_MADE_BY_ANCHOR"), url: BMExternalLink.kevinDelord)
		attrStr.addAttribute(.link, value: tuple.url, range: (str as NSString).range(of: tuple.anchor))
		attrStr.addAttribute(.link, value: self.textViewFont, range: NSRange(location: 0, length: str.count))
		// Center text
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		attrStr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: str.count))

		self.madeByTextView?.attributedText = attrStr
	}

	// MARK: - Interface Actions

	@IBAction private func closeButtonPressed() {
		self.dismiss(animated: true, completion: nil)
	}
}
