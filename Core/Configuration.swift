//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

#if DEBUG
    private let isDebug     = true
    private let isRelease   = false
#else
    private let isDebug     = false
    private let isRelease   = true
#endif

struct Configuration: Decodable {

	private enum CodingKeys: String, CodingKey {
		case apiBaseUrl
		case appIdentifier
		case buglifeIdentifier
		case fusionTableIdentifier
		case fusionTableKey
		case hockeyAppIdentifier
	}

	let apiBaseUrl				: String
	let appIdentifier			: String
	let buglifeIdentifier		: String
	let fusionTableIdentifier	: String
	let fusionTableKey			: String
	let hockeyAppIdentifier		: String

    static let debugAppirater	: Bool = (false && isDebug)
    static let analyticsEnabled	: Bool = (true && isRelease)

	init() {
		guard
			let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist"),
			let data = try? Data(contentsOf: url),
			let config = try? PropertyListDecoder().decode(Configuration.self, from: data) else {
				preconditionFailure("Invalid Configuration")
		}

		self = config
		print(self)
	}
}

struct Verbose {

    static let PinAddress           : Bool = false

    struct Manager {

        static let API              : Bool = false
        static let Analytics        : Bool = false
    }
}
