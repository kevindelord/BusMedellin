//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

// TODO: Replace #if debug #else #endif with xcconfig
// TODO: migrate to new Xcode version
// TODO: fix all swiftlint warnings

struct Configuration: Decodable {

	private enum CodingKeys: String, CodingKey {
		case apiBaseUrl
		case appIdentifier
		case buglifeIdentifier
		case fusionTableIdentifier
		case fusionTableKey
		case hockeyAppIdentifier
		case defaultLatitude
		case defaultLongitude
		case isLogEnabled
		case isAppiraterDebug
		case isAnalyticsEnabled
	}

	let apiBaseUrl				: String
	let appIdentifier			: String
	let buglifeIdentifier		: String
	let fusionTableIdentifier	: String
	let fusionTableKey			: String
	let hockeyAppIdentifier		: String
	let defaultLatitude			: String
	let defaultLongitude		: String
	let isLogEnabled			: String
	let isAppiraterDebug		: String
	let isAnalyticsEnabled		: String

	init() {
		guard
			let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist"),
			let data = try? Data(contentsOf: url),
			let config = try? PropertyListDecoder().decode(Configuration.self, from: data) else {
				preconditionFailure("Invalid Configuration")
		}

		self = config
	}

	struct Verbose {

		static let pinAddress	: Bool = false
		static let api			: Bool = true
		static let analytics	: Bool = false
	}
}

extension String {

	var boolValue: Bool {
		return (self == "YES")
	}
}
