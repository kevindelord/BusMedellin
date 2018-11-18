//
//  HUD.swift
//  BusMedellin
//
//  Created by kevindelord on 18/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

struct HUD {

	static let standardHeight			= CGFloat(5.0)
	static let indicatorColor			= Color.blue
	static let reducedSizeRatio			= CGFloat(0.6)
	static let slidedOriginRatio		= CGFloat(0.3)
	static let firstSlideDuration		= TimeInterval(0.7)
	static let secondSlideDuration		= TimeInterval(0.7)
	static let secondSlideDelay			= TimeInterval(0.5)
	static let inBetweenInterval		= TimeInterval(0.3)
	static let lockQueueIdentifier		= "io.kevindelord.buspaisa.hudview"
}
