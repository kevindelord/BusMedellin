//
//  RoutePageController.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

protocol RoutePageController: AnyObject {

	/// PageViewController's DataSource handler.
	/// The exact type of the displayed page is not known to the controller, neither its DataSource.
	/// Protocols are used to improve stabitlity and code quality.
	var handler : RoutePageControllerHandler? { get set }

	/// Reload page view controller with a new handler (DataSource object).
	func reload(with handler: RoutePageControllerHandler?)
}
