//
//  RouteCollector+Errors.swift
//  BusMedellin
//
//  Created by kevindelord on 30/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

extension RouteCollector {

	enum Invalid {
		case json
		case coordinates
		case routes

		var localizedError				: Error {
			let domain = (Bundle.main.bundleIdentifier ?? "BusPaisa")
			return NSError(domain: domain, code: self.code, userInfo: [NSLocalizedDescriptionKey: self.message])
		}

		private var code				: Int {
			switch self {
			case .json					: return 3000
			case .coordinates			: return 3001
			case .routes				: return 3002
			}
		}

		private var message				: String {
			switch self {
			case .json, .coordinates	: return String(format: L("NUMBER_ROUTES_AVAILABLE"), 0)
			case .routes				: return L("NO_ROUTE_FOUND")
			}
		}
	}
}
