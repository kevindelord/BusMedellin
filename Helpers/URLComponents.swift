//
//  URLComponents.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

extension URLComponents {

	mutating func addQueryItems(from parameters: [String: String?]) {
		self.queryItems = parameters.compactMap { (key: String, value: String?) -> URLQueryItem? in
			guard let value = value else {
				return nil
			}

			return URLQueryItem(name: key, value: value)
		}
	}
}
