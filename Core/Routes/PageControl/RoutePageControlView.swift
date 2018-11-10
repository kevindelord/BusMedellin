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

	private func setupPageControl() {
		self.pageControl?.pageIndicatorTintColor = .lightGray
		self.pageControl?.currentPageIndicatorTintColor = .black
		// TODO: find an appropriate way to handle the UIPageControl
	}
}

// MARK: - RoutePageControl

extension RoutePageControlView {

	func reload(numberOfPages: Int) {
		self.pageControl?.numberOfPages = numberOfPages
	}

	func update(currentPage: Int) {
		self.pageControl?.currentPage = currentPage
	}
}
