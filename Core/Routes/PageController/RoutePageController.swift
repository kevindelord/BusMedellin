//
//  RoutePageController.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

// TODO: Document

protocol RoutePageController {

	var handler : RoutePageControllerHandler? { get set }

	func reload(with handler: RoutePageControllerHandler?)
}
