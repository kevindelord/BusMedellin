//
//  RoutePageControl.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

protocol RoutePageControl {

	/// Reload the page control with a total number of pages displayed.
	///
	/// - Parameter numberOfPages: The number of pages the receiver shows (as dots).
	func reload(numberOfPages: Int)

	/// Highlight the current active page.
	///
	/// - Parameter currentPage: The index of the current page highlighted in the UI.
	func update(currentPage: Int)
}
