//
//  Constants.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

// Most UI instances are being identified using protocols instead of static identifiers.
// Only those constants are used to get storyboard elements via their identifier.
enum Storyboard				: String {

	case routes				= "Routes"

	enum Controller 		: String {

		case route			= "RouteViewController"
	}

	enum Segue 				: String {

		case openSettings	= "openSettings"
	}
}
