//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

// TODO: fix all swiftlint warnings

struct Configuration: Decodable {

	private enum CodingKeys: String, CodingKey {
		case apiBaseUrl
		case appIdentifier
		case buglifeIdentifier
		case fusionTableIdentifier
		case fusionTableKey
		case defaultLatitude
		case defaultLongitude
	}

	let apiBaseUrl				: String
	let appIdentifier			: String
	let buglifeIdentifier		: String
	let fusionTableIdentifier	: String
	let fusionTableKey			: String
	let defaultLatitude			: String
	let defaultLongitude		: String

	init() {
		guard
			let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist"),
			let data = try? Data(contentsOf: url),
			let config = try? PropertyListDecoder().decode(Configuration.self, from: data) else {
				preconditionFailure("Invalid Configuration")
		}

		self = config
	}
}

extension Configuration {

	private enum XCConfigKey: String {
		case isLogEnabled = "isLogEnabled"
		case isAppiraterDebug = "isAppiraterDebug"
		case isAnalyticsEnabled = "isAnalyticsEnabled"

		var boolValue: Bool {
			// Values from a .xcconfig file can only be automatically added to the main bundle info plist.
			return (Bundle.main.object(forInfoDictionaryKey: self.rawValue) as? String == "YES")
		}
	}

	static var isLogEnabled			: Bool {
		return XCConfigKey.isLogEnabled.boolValue
	}

	static var isAppiraterDebug		: Bool {
		return XCConfigKey.isAppiraterDebug.boolValue
	}

	static var isAnalyticsEnabled	: Bool {
		return XCConfigKey.isAnalyticsEnabled.boolValue
	}
}
