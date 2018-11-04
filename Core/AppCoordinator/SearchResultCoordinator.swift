//
//  SearchResultCoordinator.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

protocol SearchResultCoordinator {

	/// View Height Constraint
	var searchResultConstraint: NSLayoutConstraint? { get set }

	/// Show the container view displaying the search results.
	func showSearchResults()

	/// Hide the container view displaying the search results.
	func hideSearchResults()
}