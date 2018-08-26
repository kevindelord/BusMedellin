//
//  Bundle.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

extension Bundle {

	func stringEntryInPList(for key: String) -> String? {
		return self.entryInPList(for: key) as String?
	}

	func entryInPList<T>(for key: String) -> T? {
		return self.object(forInfoDictionaryKey: key) as? T
	}
}
