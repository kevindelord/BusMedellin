//
//  CollectionViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import CSStickyHeaderFlowLayout
import Reachability

class BMCollectionViewController: UICollectionViewController {

	var availableRoutes			: [Route]?
	var displayRouteOnMap		: ((_ routeCode: String, _ completion: (() -> Void)?) -> Void)?
	var drawnRoute				: Route?
	var statusBarHidden			: Bool = false

	private var layout : CSStickyHeaderFlowLayout? {
		return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 10.0, *) {
			self.collectionView?.isPrefetchingEnabled = false
		}

		self.collectionView?.backgroundColor = .white

		// Setup Cells: list of bus lines
		self.collectionView?.register(BMCollectionViewCell.self, forCellWithReuseIdentifier: ReuseId.resultCell)
		// Setup Header: map view
		self.collectionView?.register(BMCollectionMapView.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: ReuseId.parallaxHeader)
		// Setup Section Header: header with title "number of lines"
		self.collectionView?.register(BMCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ReuseId.sectionHeader)

		var headerHeight = (self.view.frame.size.height - StaticHeight.CollectionView.sectionHeader)

		if #available(iOS 11.0, *) {
			let windowInsets = ((UIApplication.shared.delegate as? AppDelegate)?.window?.safeAreaInsets ?? UIEdgeInsets.zero)
			headerHeight = (headerHeight - windowInsets.top - windowInsets.bottom)
		}

		self.layout?.itemSize = CGSize(width: self.view.frame.size.width, height: StaticHeight.CollectionView.cell)
		self.layout?.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: headerHeight)
		self.layout?.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: StaticHeight.CollectionView.sectionHeader)
		self.layout?.minimumLineSpacing = 0
		self.layout?.disableStickyHeaders = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		Analytics.send(screenView: .mapView)
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .slide
	}

	override var prefersStatusBarHidden: Bool {
		return self.statusBarHidden
	}
}

// MARK: - CollectionView

extension BMCollectionViewController {

	// Cells

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (self.availableRoutes?.count ?? 0)
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseId.resultCell, for: indexPath) as? BMCollectionViewCell,
			let route = self.availableRoutes?[safe: indexPath.row] else {
				return UICollectionViewCell()
		}

		cell.cellContainer?.updateContent(route: route)
		return cell
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		guard (Reachability.isConnected == true) else {
			UIAlertController.showErrorMessage(L("NO_INTERNET_CONNECTION"))
			return
		}

		guard let route = self.availableRoutes?[safe: indexPath.item] else {
			return
		}

		self.drawnRoute = route
		self.displayRouteOnMap?(route.code, nil)
		collectionView.setContentOffset(CGPoint.zero, animated: true)
		collectionView.reloadData()
	}

	// Parallax Header

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if (kind == CSStickyHeaderParallaxHeader) {
			guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseId.parallaxHeader, for: indexPath) as? BMCollectionMapView else {
				return UICollectionReusableView()
			}

			view.mapContainer?.didFetchAvailableRoutesBlock = self.reloadAvailableRoutes
			self.displayRouteOnMap = view.mapContainer?.fetchAndDrawRoute
			return view

		} else if (kind == UICollectionElementKindSectionHeader) {
			guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReuseId.sectionHeader, for: indexPath) as? BMCollectionViewSectionHeader else {
				return UICollectionReusableView()
			}

			view.headerContainer?.updateContent(availableRoutes: self.availableRoutes, drawnRoute: self.drawnRoute)
			view.headerContainer?.openSettingsBlock = {
				self.performSegue(withIdentifier: Segue.settings, sender: nil)
			}

			return view
		}

		return UICollectionReusableView()
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let limitHeight = (scrollView.contentOffset.y + StaticHeight.CollectionView.sectionHeader + UIApplication.shared.statusBarFrame.size.height)
		let isCurrentlyHidden = self.statusBarHidden

		if (self.statusBarHidden == false && limitHeight >= self.view.frame.height) {
			self.statusBarHidden = true

		} else if (self.statusBarHidden == true && limitHeight < self.view.frame.height) {
			self.statusBarHidden = false
		}

		if (isCurrentlyHidden != self.statusBarHidden) {
			// Update the status bar
			UIView.animate(withDuration: 0.25, animations: {
				self.setNeedsStatusBarAppearanceUpdate()
			})
		}
	}
}

// MARK: - Features

extension BMCollectionViewController {

	func reloadAvailableRoutes(routes: [Route]?) {
		self.availableRoutes = routes
		self.drawnRoute = routes?.first

		if (routes != nil && routes?.isEmpty == true) {
			UIAlertController.showErrorMessage(L("NO_ROUTE_FOUND"))
		}

		if (self.availableRoutes?.isEmpty == false) {
			// Reload the collection view to show the number of bus lines found.
			self.collectionView?.reloadData()
			// Scroll up a bit to indicate the user that he can scroll up.
			let indexPath = IndexPath(item: 0, section: 0)
			self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
		} else {
			// Reset the scroll if possible.
			self.collectionView?.setContentOffset(CGPoint.zero, animated: true)
			// And then, after the animation (0.3s) reload the collection view.
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
				self?.collectionView?.reloadData()
			}
		}
	}
}
