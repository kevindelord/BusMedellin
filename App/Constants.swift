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

struct Segue {

	static let settings				= "openSettings"

	struct Embed {

		struct Container {

			static let Footer		= "embedFooterView"
			static let Map			= "embedMapContainer"
			static let Routes		= "embedRoutesContainer"
		}

		struct ViewController {

			static let Page			= "embedPageViewController"
			static let Address 		= "embedAddressViewController"
			static let Map 			= "embedMapViewController"
			static let ActionPin	= "embedPinLocationViewController"
			static let UserLocation	= "embedUserLocationViewController"
		}

		struct View {

			static let PageControl	= "embedPageControl"
		}
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
