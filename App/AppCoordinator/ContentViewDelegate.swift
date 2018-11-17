//
//  ContentViewDelegate.swift
//  BusMedellin
//
//  Created by kevindelord on 04/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

protocol ContentViewDelegate {

	/// Tells the delegate to reload all content views.
	func reloadContentViews()

	/// Tells the delegate to reload all content views with a specific selected route.
	func reloadContentViewsForSelectedRoute()
}

