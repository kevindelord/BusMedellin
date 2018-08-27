//
//  Localization.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
func L(_ key: String) -> String {
	let defaultValue = "__Unique_Default_String__"
	let localizedString = NSLocalizedString(key, tableName: nil, bundle: Bundle.main, value: defaultValue, comment: "")
	guard (defaultValue != localizedString) else {
		DKLog(true, "Warning: Localized string with key '\(key)' can't be found!")
		return key
	}

	return localizedString
}

// swiftlint:enable identifier_name
