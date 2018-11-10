//
//  RoutePageControllerDataSource.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

// TODO: Document and extract protocols.

protocol RoutePageControllerDataSource {

	var initialRouteDetailPage: RouteDetailPage?  { get }

	var numberOfRouteDetailPages: Int { get }

	func index(of routeDetailPage: RouteDetailPage) -> Int?

	func routeDetailPage(before routeDetailPage: RouteDetailPage?) -> RouteDetailPage?

	func routeDetailPage(after routeDetailPage: RouteDetailPage?) -> RouteDetailPage?
}
