//
//  Constants.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import UIKit

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

struct Color {

	static let red					= (UIColor(red: 255, green: 59, blue: 48) ?? .red)
	static let green				= (UIColor(red: 76, green: 217, blue: 100) ?? .green)
	static let blue					= (UIColor(red: 33, green: 150, blue: 243) ?? .blue)
	static let gray					= (UIColor(red: 149, green: 165, blue: 166) ?? .gray)
	static let white				= UIColor.white
	static let black				= UIColor.black
	static let lightGray			= (UIColor(red: 230, green: 230, blue: 230) ?? .lightGray)
	static let darkGray				= (UIColor(red: 150, green: 150, blue: 150) ?? .darkGray)
}
