//
//  HAProgressView.swift
//  HockeyApp-iOS
//
//  Created by Kevin Delord on 18.08.17.
//  Copyright © 2017 SMF. All rights reserved.
//
//  Code inspired from: https://github.com/lfarah/LinearProgressBar
//

import Foundation
import UIKit

struct HUD {

	static let standardHeight			= CGFloat(4.0)
	static let indicatorColor			= Color.blue
	static let reducedSizeRatio			= CGFloat(0.6)
	static let slidedOriginRatio		= CGFloat(0.3)
	static let firstSlideDuration		= TimeInterval(0.7)
	static let secondSlideDuration		= TimeInterval(0.7)
	static let secondSlideDelay			= TimeInterval(0.5)
	static let inBetweenInterval		= TimeInterval(0.3)
	static let lockQueueIdentifier		= "io.kevindelord.buspaisa.hudview"
}

// MARK: - ProgressView UI element

/// UIKit object representing an indeterminate progress view.
public class HUDView						: UIView {

	fileprivate var progressBarIndicator	: UIView?
	fileprivate var widthForLinearBar		: CGFloat = 0
	fileprivate var progressBarColor		= HUD.indicatorColor
	fileprivate var isAnimationRunning		= false {
		didSet {
			// Toggle the activity indicator in the status bar.
			UIApplication.shared.isNetworkActivityIndicatorVisible = self.isAnimationRunning
		}
	}

	// Lock Queue to avoid multi-threading problem for the anitmation.
	fileprivate let lockQueue = DispatchQueue(label: HUD.lockQueueIdentifier)

	convenience public init?(within superView: UIView?, layoutSupport: UILayoutSupport) {
		guard let superView = superView else {
			return nil
		}

		self.init(frame: CGRect(x: 0, y: 0, width: superView.frame.width, height: HUD.standardHeight))

		self.initViewPosition(within: superView, layoutSupport: layoutSupport)
		self.initProgressBarIndicator()
	}

	override private init(frame: CGRect) {
		// Override required to activate/enable the convenience init.
		super.init(frame: frame)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("Storyboard not supported")
	}

	/// Configure the current view into its superview.
	///
	/// - Parameters:
	///   - superView: Superview owning the current ProgressView.
	///   - layoutSupport: Bottom or Top Layout Support (for the navigation bar).
	///   - position: Position of the progress view within the superview (bottom or top).
	private func initViewPosition(within superView: UIView, layoutSupport: UILayoutSupport) {
		superView.addSubview(self)
		superView.bringSubviewToFront(self)

		self.backgroundColor = UIColor.clear
		self.translatesAutoresizingMaskIntoConstraints = false
		let height = HUD.standardHeight

		// Height
		NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height).isActive = true
		// X origin
		NSLayoutConstraint.equal(.leading, view: self, superview: superView)
		// Width
		NSLayoutConstraint.equal(.trailing, view: self, superview: superView)
		// Y origin
		NSLayoutConstraint.equal(.top, view: self, superview: layoutSupport, secondAttribute: .bottom)
	}

	/// Configure the indicator bar.
	private func initProgressBarIndicator() {
		self.progressBarIndicator = UIView(frame: CGRect.zero)
		self.progressBarIndicator?.backgroundColor = self.progressBarColor
		self.progressBarIndicator?.roundRect(radius: 2)
		self.addSubview(safe: self.progressBarIndicator)

		guard let subview = self.progressBarIndicator else {
			return
		}

		subview.translatesAutoresizingMaskIntoConstraints = false
		// X, Height
		NSLayoutConstraint.equal(.top, view: subview, superview: self)
		NSLayoutConstraint.equal(.bottom, view: subview, superview: self)
	}
}

// MARK: - Animation functions

extension HUDView {

	/// Start the animation
	public func startAnimation() {
		self.lockQueue.sync {
			guard (self.isAnimationRunning == false) else {
				return
			}

			self.isAnimationRunning = true
			DispatchQueue.main.async {
				self.configureAnimation()
			}
		}
	}

	/// Stop the animation
	public func stopAnimation() {
		self.lockQueue.sync {
			self.isAnimationRunning = false
		}
	}

	/// Configure and animate the UI elements.
	private func configureAnimation() {
		/// Bring (again) the progress view to the front.
		self.superview?.bringSubviewToFront(self)
		// (Re)configure the bar indicator.
		self.progressBarIndicator?.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height)
		let reduceSize = (self.frame.size.width * HUD.reducedSizeRatio)

		// First step animation
		UIView.animate(withDuration: HUD.firstSlideDuration, delay: 0, options: [], animations: {
			self.progressBarIndicator?.frame = CGRect(x: self.frame.size.width * HUD.slidedOriginRatio,
													  y: 0,
													  width: reduceSize,
													  height: self.frame.size.height)
		}, completion: nil)

		// Second step animation
		UIView.animate(withDuration: HUD.secondSlideDuration, delay: HUD.secondSlideDelay, options: [], animations: {
			self.progressBarIndicator?.frame = CGRect(x: self.frame.width, y: 0, width: reduceSize, height: self.frame.size.height)
		}, completion: { (animationFinished: Bool) in
			self.lockQueue.sync {
				if (self.isAnimationRunning == true) {
					DispatchQueue.main.asyncAfter(deadline: .now() + HUD.inBetweenInterval) { [weak self] in
						self?.configureAnimation()
					}
				}
			}
		})
	}
}

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

extension UIView {

	var viewController: UIViewController? {
		var responder: UIResponder? = self
		while (responder is UIViewController == false) {
			responder = responder?.next
			if (responder == nil) {
				break
			}
		}

		return (responder as? UIViewController)
	}
}
