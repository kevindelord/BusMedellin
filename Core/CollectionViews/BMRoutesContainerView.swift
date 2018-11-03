//
//  BMRoutesContainerView.swift
//  BusMedellin
//
//  Created by kevindelord on 03/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

class BMRoutesContainerView								: UIView {

	@IBOutlet private weak var totalRoutes				: UILabel?
	@IBOutlet private weak var collectionView			: UICollectionView?

	private var availableRoutes							= [Route]()

	var coordinator										: Coordinator?

	var delegate										: ContentViewDelegate?
}

// MARK: - UICollectionViewDataSource

extension BMRoutesContainerView: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.availableRoutes.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseId.routeCell, for: indexPath)

		guard let route = self.availableRoutes[safe: indexPath.item] else {
			return cell
		}

		(cell as? BMRouteView)?.updateContent(route: route)
		return cell
	}
}


extension BMRoutesContainerView : ContentView {

	func update(availableRoutes: [Route], selectedRoute: Route?) {
		self.availableRoutes = availableRoutes
		self.configureViewTitle()
		self.collectionView?.reloadData()
	}
}


extension BMRoutesContainerView {

	private func configureViewTitle() {
		guard (self.availableRoutes.isEmpty == false) else {
			self.totalRoutes?.text = "TODO"
			return
		}

		self.totalRoutes?.text = String(format: L("NUMBER_ROUTES_AVAILABLE"), self.availableRoutes.count)
	}
}
