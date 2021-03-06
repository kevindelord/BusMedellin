//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

struct Configuration: Decodable {

	private enum CodingKeys: String, CodingKey {
		case appIdentifier
		case buglifeIdentifier
		case defaultLatitude
		case defaultLongitude
	}

	let appIdentifier			: String
	let buglifeIdentifier		: String
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
