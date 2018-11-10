//
//  Constants.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import UIKit

struct API {

	struct Response {

		struct Key {

			static let rows			= "rows"
			static let coordinates	= "coordinates"
			static let geometry		= "geometry"
			static let geometries	= "geometries"
		}

		// 'Sin Nombre' and 'sn' are known invalid values coming from the API.
		static let invalidValues	= ["Sin Nombre", "sn"]
	}
}

struct Map {

	static let defaultSearchRadius	= 500.0
	static let defaultZoomRadius	: Double = 3300
	static let deltaAfterSearch		= 0.007
	static let maxScrollDistance	: Double = 12000.0
	static let circleColorAlpha		: CGFloat = 0.3
	static let polylineWidth		: CGFloat = 2

	struct Address {

		static let street			= "Street"
	}
}

struct Segue {

	static let settings				= "openSettings"

	struct Embed {

		static let FooterView		= "embedFooterView"
		static let MapView			= "embedMapView"
		static let RoutesView		= "embedRoutesView"
		static let PageController	= "embedPageController"
		static let PageControl		= "embedPageControl"
	}
}

extension UIPageControl {

	static let maximumPageCount		= 15
}

struct Storyboard {

	static let Routes				= "Routes"

	struct Controller {

		static let Route 			= "RouteViewController"
	}
}

struct ReuseId {

	static let pickUpPin			= "PickUpAnnotaion_Id"
	static let destinationPin		= "DestinationAnnotaion_Id"
}

struct BMColor {

	static let red					= (UIColor(red: 255, green: 59, blue: 48) ?? .red)
	static let green				= (UIColor(red: 76, green: 217, blue: 100) ?? .green)
	static let blue					= (UIColor(red: 33, green: 150, blue: 243) ?? .blue)
	static let gray					= (UIColor(red: 149, green: 165, blue: 166) ?? .gray)
	static let black				= UIColor.black
	static let lightGray			= (UIColor(red: 230, green: 230, blue: 230) ?? .lightGray)
	static let darkGray				= (UIColor(red: 150, green: 150, blue: 150) ?? .darkGray)
}

struct BMExternalLink {

	static let project				= "https://github.com/kevindelord/BusMedellin"
	static let thibaultDurand		= "https://github.com/tdurand"
	static let twitterTDurand		= "https://twitter.com/tibbb"
	static let webVersion			= "http://tdurand.github.io/mapamedellin"
	static let kevinDelord			= "https://github.com/kevindelord"
}
