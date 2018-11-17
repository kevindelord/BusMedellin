//
//  NSError.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

extension NSError {

	func log() {
		print("Error: \(self) \(self.userInfo)")
	}
}
