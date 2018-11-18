//
//  NSLayoutConstraint.swift
//  BusMedellin
//
//  Created by kevindelord on 18/11/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

	/// Add constraints to make sure the given subview always fit its superview container (and even when the device rotates).
	///
	/// - Parameters:
	///   - view: Subview to fit to its parent view.
	///   - superview: SUperview containing the given subview.
	class func fit(_ view: UIView, into superview: UIView) {
		let attributes: [NSLayoutConstraint.Attribute] = [.leading, .trailing, .top, .bottom]
		attributes.forEach({ (attribute: NSLayoutConstraint.Attribute) in
			NSLayoutConstraint.equal(attribute, view: view, superview: superview)
		})
	}

	/// Add an active constraint where the given attributes are related as `equal` between the given items.
	///
	/// - Parameters:
	///   - attribute: Layout attribute for the first item
	///   - view: First item to be related to the new constraint (usually the subview).
	///   - superview: Second item to be related to the new constraint (usually the superview).
	///   - secondAttribute: Optional second layout attribute; if nil the first layout attribute will be used again.
	class func equal(_ attribute: NSLayoutConstraint.Attribute,
					 view: UIView,
					 superview: Any?,
					 secondAttribute: NSLayoutConstraint.Attribute? = nil) {

		NSLayoutConstraint(item: view,
						   attribute: attribute,
						   relatedBy: .equal,
						   toItem: superview,
						   attribute: (secondAttribute ?? attribute),
						   multiplier: 1,
						   constant: 0).isActive = true
	}
}
