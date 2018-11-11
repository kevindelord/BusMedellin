//
//  Location.swift
//  BusMedellin
//
//  Created by kevindelord on 11/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

enum Location {
	case PickUp
	case Destination

	var dotColor: UIColor {
		switch self {
		case .PickUp		: return BMColor.green
		case .Destination	: return BMColor.red
		}
	}

	var localizedPlaceholder: String {
		switch self {
		case .PickUp		: return L("LOCATION_VIEW_PICKUP")
		case .Destination	: return L("LOCATION_VIEW_DESTINATION")
		}
	}

	var pinImageName: String {
		switch self {
		case .PickUp		: return "pickupLocation"
		case .Destination	: return "destinationLocation"
		}
	}

	var pinLocalizedText: String {
		switch self {
		case .PickUp		: return L("PIN_PICKUP_LOCATION")
		case .Destination	: return L("PIN_DESTINATION_LOCATION")
		}
	}
}
