//
//  CollectionViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import CSStickyHeaderFlowLayout

class BMCollectionViewController: UICollectionViewController {

    var availableRoutes         : [Route]?
    var displayRouteOnMap       : ((route: Route) -> Void)?
    var drawnRoute              : Route?

    private var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.whiteColor()

        // Setup Cells: list of bus lines
        self.collectionView?.registerClass(BMCollectionViewCell.self, forCellWithReuseIdentifier: ReuseId.ResultCell)
        self.layout?.itemSize = CGSizeMake(self.view.frame.size.width, StaticHeight.CollectionView.Cell)

        // Setup Header: map view
        self.collectionView?.registerClass(BMMapCollectionView.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: ReuseId.ParallaxHeader)
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - StaticHeight.CollectionView.SectionHeader)

        // Setup Section Header: header with title "number of lines"
        self.collectionView?.registerClass(BMCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ReuseId.SectionHeader)
        self.layout?.headerReferenceSize = CGSizeMake(self.view.frame.size.width, StaticHeight.CollectionView.SectionHeader)

        self.layout?.minimumLineSpacing = 0
    }
}

// MARK: - CollectionView

extension BMCollectionViewController {

    // Cells

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.availableRoutes?.count ?? 0)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseId.ResultCell, forIndexPath: indexPath) as? BMCollectionViewCell
        if let route = self.availableRoutes?[safe: indexPath.row] {
            cell?.cellContainer?.updateContent(route)
        }
        return (cell ?? UICollectionViewCell())
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if let route = self.availableRoutes?[safe: indexPath.item] {
            self.displayRouteOnMap?(route: route)
            collectionView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    // Parallax Header

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if (kind == CSStickyHeaderParallaxHeader),
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ReuseId.ParallaxHeader, forIndexPath: indexPath) as? BMMapCollectionView {
                view.mapContainer?.didFetchAvailableRoutesBlock = self.reloadAvailableRoutes
                self.displayRouteOnMap = view.mapContainer?.fetchAndDrawRoute
                return view

        } else if (kind == UICollectionElementKindSectionHeader),
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ReuseId.SectionHeader, forIndexPath: indexPath) as? BMCollectionViewSectionHeader {
            view.headerContainer?.updateContent(self.availableRoutes, drawnRoute: self.drawnRoute)
            return view
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - Features

extension BMCollectionViewController {

    func reloadAvailableRoutes(routes: [Route]?) {
        self.availableRoutes = routes
        self.drawnRoute = routes?.first

        if (routes != nil && routes?.isEmpty == true) {
            UIAlertController.showErrorMessage("No routes available for the choosen locations.")
        }
        if (self.availableRoutes?.isEmpty == false) {
            // Reload the collection view to show the number of bus lines found.
            self.collectionView?.reloadData()
            // Scroll up a bit to indicate the user that he can scroll up.
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
        } else {
            // Reset the scroll if possible.
            self.collectionView?.setContentOffset(CGPoint.zero, animated: true)
            // And then, after the animation (0.3s) reload the collection view.
            self.performBlockAfterDelay(0.3, block: { 
                self.collectionView?.reloadData()
            })
        }
    }
}
