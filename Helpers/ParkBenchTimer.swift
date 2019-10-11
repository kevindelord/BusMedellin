//
//  ParkBenchTimer.swift
//  BusMedellin
//
//  Created by kevindelord on 11/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import CoreFoundation

// swiftlint:disable comments_capitalized_ignore_possible_code

/// Timer class based on CoreFoundation's CFAbsoluteTime.
///
/// This class is not actively used in the project but became very handy when integrating the new offline database.
///
/// ```
/// let timer = ParkBenchTimer()
///
/// ... your code ...
///
/// print("The task took \(timer.stop()) seconds.")
/// ```
///
/// StackOverFlow link: https://stackoverflow.com/a/26578191/2790648
class ParkBenchTimer {

	let startTime:CFAbsoluteTime
	var endTime:CFAbsoluteTime?

	init() {
		self.startTime = CFAbsoluteTimeGetCurrent()
	}

	func stop() -> CFAbsoluteTime {
		self.endTime = CFAbsoluteTimeGetCurrent()
		return (self.duration ?? 0.0)
	}

	var duration: CFAbsoluteTime? {
		guard let endTime = self.endTime else {
			return nil
		}

		return (endTime - self.startTime)
	}
}

// swiftlint:enable comments_capitalized_ignore_possible_code
