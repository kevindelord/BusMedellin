//
//  RoutePageControlView.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutePageControlView					: UIView, RoutePageControl {

	@IBOutlet private weak var pageControl	: PageControl!

	private var totalNumberOfPages			: Int = 0
}

// MARK: - RoutePageControl

extension RoutePageControlView {

	func reload(numberOfPages: Int) {
		self.pageControl.radius = 5
		self.pageControl.padding = 10
		self.pageControl.tintColor = Color.lightGray
		self.pageControl.currentPageTintColor = Color.blue
		self.pageControl.numberOfPages = min(numberOfPages, self.pageControl.maximumPageCount)
		self.pageControl.set(progress: 0, animated: false)
	}

	func update(currentPage: Int) {
		let progress = (currentPage % self.pageControl.maximumPageCount)
		self.pageControl.set(progress: progress, animated: true)
	}
}
