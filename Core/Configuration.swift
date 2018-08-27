//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

#if DEBUG
private let isDebug		= true
private let isRelease	= false
#else
private let isDebug		= false
private let isRelease	= true
#endif

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
	}

	let apiBaseUrl				: String
	let appIdentifier			: String
	let buglifeIdentifier		: String
	let fusionTableIdentifier	: String
	let fusionTableKey			: String
	let hockeyAppIdentifier		: String
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

	static let debugAppirater	: Bool = (false && isDebug)
	static let analyticsEnabled	: Bool = (true && isRelease)

	struct Verbose {

		static let pinAddress	: Bool = false
		static let api			: Bool = false
		static let analytics	: Bool = false
	}
}
