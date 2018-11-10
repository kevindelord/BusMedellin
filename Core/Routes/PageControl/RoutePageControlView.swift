//
//  RoutePageControlView.swift
//  BusMedellin
//
//  Created by kevindelord on 10/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class RoutePageControlView 					: UIView, RoutePageControl {

	@IBOutlet private weak var pageControl 	: UIPageControl?

	private var totalNumberOfPages			: Int = 0
}

// MARK: - RoutePageControl

extension RoutePageControlView {

	func reload(numberOfPages: Int) {
		self.pageControl?.pageIndicatorTintColor = .lightGray
		self.pageControl?.currentPageIndicatorTintColor = .black
		self.pageControl?.numberOfPages = min(numberOfPages, UIPageControl.maximumPageCount)
	}

	func update(currentPage: Int) {
		self.pageControl?.currentPage = (currentPage % UIPageControl.maximumPageCount)
	}
}
