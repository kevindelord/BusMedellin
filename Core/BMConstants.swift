//
//  BMConstants.swift
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
	}
}

struct StaticHeight {

	struct CollectionView {

		static let cell				: CGFloat = 80
		static let sectionHeader	: CGFloat = 80
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

	static let settings				= "openSettingsViewController"
}

struct XibFile {

	static let mapView				= "BMMapView"
	static let headerView			= "BMHeaderView"
	static let cellView				= "BMCellView"
}

struct ReuseId {

	static let parallaxHeader		= "MapCollectionView_ParallaxHeader"
	static let sectionHeader		= "CollectionView_SectionHeader"
	static let resultCell			= "CollectionView_ResultCell"
	static let pickUpPin			= "PickUpAnnotaion_Id"
	static let destinationPin		= "DestinationAnnotaion_Id"
}

struct BMColor {

	static let red					= (UIColor(red: 255, green: 59, blue: 48) ?? .red)
	static let green				= (UIColor(red: 76, green: 217, blue: 100) ?? .green)
	static let blue					= (UIColor(red: 33, green: 150, blue: 243) ?? .blue)
	static let gray					= (UIColor(red: 149, green: 165, blue: 166) ?? .gray)
	static let black				= UIColor.black
	static let viewBorder			= (UIColor(red: 230, green: 230, blue: 230) ?? .lightGray)
	static let dotBorder			= (UIColor(red: 150, green: 150, blue: 150) ?? .darkGray)
}

struct BMExternalLink {

	static let project				= "https://github.com/kevindelord/BusMedellin"
	static let thibaultDurand		= "https://github.com/tdurand"
	static let twitterTDurand		= "https://twitter.com/tibbb"
	static let webVersion			= "http://tdurand.github.io/mapamedellin"
	static let kevinDelord			= "https://github.com/kevindelord"
}
