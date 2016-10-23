//
//  CollectionViewController.swift
//  BusMedellin
//
//  Created by Kevin Delord on 15/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import CSStickyHeaderFlowLayout
import DKHelper

class BMCollectionViewController: UICollectionViewController {

    var availableRoutes         : [Route]?
    var displayRouteOnMap       : ((route: Route, completion: (() -> Void)?) -> Void)?
    var drawnRoute              : Route?

    private var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = UIColor.whiteColor()

        // Setup Cells: list of bus lines
        self.collectionView?.registerClass(BMCollectionViewCell.self, forCellWithReuseIdentifier: ReuseId.ResultCell)
        self.layout?.itemSize = CGSize(width: self.view.frame.size.width, height: StaticHeight.CollectionView.Cell)

        // Setup Header: map view
        self.collectionView?.registerClass(BMCollectionMapView.self, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: ReuseId.ParallaxHeader)
        self.layout?.parallaxHeaderReferenceSize = CGSize(width: self.view.frame.size.width, height: (self.view.frame.size.height - StaticHeight.CollectionView.SectionHeader))

        // Setup Section Header: header with title "number of lines"
        self.collectionView?.registerClass(BMCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ReuseId.SectionHeader)
        self.layout?.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: StaticHeight.CollectionView.SectionHeader)

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
            self.drawnRoute = route
            self.displayRouteOnMap?(route: route, completion: nil)
            collectionView.setContentOffset(CGPoint.zero, animated: true)
            collectionView.reloadData()
        }
    }

    // Parallax Header

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if (kind == CSStickyHeaderParallaxHeader),
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ReuseId.ParallaxHeader, forIndexPath: indexPath) as? BMCollectionMapView {
                view.mapContainer?.didFetchAvailableRoutesBlock = self.reloadAvailableRoutes
                self.displayRouteOnMap = view.mapContainer?.fetchAndDrawRoute
                return view

        } else if (kind == UICollectionElementKindSectionHeader),
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: ReuseId.SectionHeader, forIndexPath: indexPath) as? BMCollectionViewSectionHeader {
            view.headerContainer?.updateContent(self.availableRoutes, drawnRoute: self.drawnRoute)
            view.headerContainer?.openSettingsBlock = {
                self.performSegueWithIdentifier(Segue.Settings, sender: nil)
            }
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
            UIAlertController.showErrorMessage(L("NO_ROUTE_FOUND"))
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
