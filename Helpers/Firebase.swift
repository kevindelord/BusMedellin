//
//  Firebase.swift
//  BusMedellin
//
//  Created by kevindelord on 11/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//

import Firebase

struct Firebase {

	static func setup() {
		// Set the Firebase log to the minimum required.
		FirebaseConfiguration.shared.setLoggerLevel(.min)
		// Use Firebase library to configure APIs
		// Setup all frameworks: Analytics, Performance and Crashlytics.
		FirebaseApp.configure()
	}
}
