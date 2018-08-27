//
//  UIAlertController.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

@available(iOS 8.0, *)
extension UIAlertController {

	class func showErrorPopup(_ error: NSError?, presentingViewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) {
		// Log error
		error?.log()
		// Find a valid message to display
		var msg : String? = nil
		if let errorMessage : String = error?.userInfo["error"] as? String {
			msg = errorMessage
		} else if let errorMessage = error?.localizedFailureReason {
			msg = errorMessage
		} else if let errorMessage = error?.localizedDescription , (errorMessage.isEmpty == false) {
			msg = errorMessage
		}
		// Show a popup
		if let _msg = msg {
			self.showErrorMessage(_msg, presentingViewController: presentingViewController)
		}
	}

	class func showErrorMessage(_ message: String, presentingViewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) {
		self.showInfoMessage("Error", message: message, presentingViewController: presentingViewController)
	}

	class func showInfoMessage(_ title: String, message: String, presentingViewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		presentingViewController?.present(ac, animated: true, completion: nil)
	}
}