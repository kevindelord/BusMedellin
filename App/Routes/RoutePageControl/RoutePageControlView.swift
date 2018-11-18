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
		self.pageControl.pageIndicatorTintColor = Color.lightGray.withAlphaComponent(0.5)
		self.pageControl.currentPageIndicatorTintColor = Color.blue
		self.pageControl.numberOfPages = min(numberOfPages, self.pageControl.maximumPageCount)
	}

	func update(currentPage: Int) {
		self.pageControl.currentPage = (currentPage % self.pageControl.maximumPageCount)
	}
}
