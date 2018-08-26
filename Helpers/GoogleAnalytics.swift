//
//  Analytics.swift
//  BusMedellin
//
//  Created by Kevin Delord on 24/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import Firebase

struct Analytics {

     static func setup() {

        // Check if the analytics is enabled
        if (Configuration.AnalyticsEnabled == false) {
            return
        }

        // Firebase
        Firebase.setup()

        // Google Analytics
        GoogleAnalytics.setup()
    }

    // MARK: - Send Actions

    private static func send(category: String, action: String, label: String?, value: NSNumber?) {

        // Check if the analytics is enabled
        if (Configuration.AnalyticsEnabled == false) {
            return
        }

        // Google Analytics
        GoogleAnalytics.send(category: category, action: action, label: label, value: value)

        // Firebase
        Firebase.send(category: category, action: action, label: label, value: value)
    }

    static func sendScreenView(_ screen: Analytics.Screen) {

        // Check if the analytics is enabled
        if (Configuration.AnalyticsEnabled == false) {
            return
        }

        // Google Analytics
        GoogleAnalytics.sendScreenView(screen: screen)

        // Firebase
        Firebase.sendScreenView(screen: screen)
    }

    // MARK: - Actions type

    enum Screen                             : String {

        case MapView                        = "Screen_MapView"
        case Settings                       = "Screen_Settings"
    }

    enum PinLocation                        : String {

        static let CategoryId               = "PinLocation"
        case DidSetStart                    = "Pin_DidSetStart"
        case DidSetDestination              = "Pin_DidSetDestination"
        case DidCancelStart                 = "Pin_DidCancelStart"
        case DidCancelDestination           = "Pin_DidCancelDestination"

        func send() {
            let category = Analytics.PinLocation.CategoryId
            Analytics.send(category: category, action: self.rawValue, label: nil, value: nil)
        }
    }

    enum UserLocation                       : String {

        static let CategoryId               = "UserLocation"
        case DidLocateUser                  = "UserLocation_DidLocateUser"
        case DidLocateUserTooFar            = "UserLocation_DidLocateUserTooFar"
        case DidAskForSettings              = "UserLocation_DidAskForSettings"
        case DidAskForUserLocation          = "UserLocation_DidAskForUserLocation"

        func send() {
            let category = Analytics.UserLocation.CategoryId
            Analytics.send(category: category, action: self.rawValue, label: nil, value: nil)
        }
    }

    enum Route                              : String {

        static let CategoryId               = "Route"
        static let LabelSearch              = "Search"

        case DidDrawRoute                   = "Route_DidDrawRoute"
        case DidSelectRoute                 = "Route_DidSelectRoute"

        case DidSearchForMatchingRoutes     = "Route_DidSearchForMatchingRoutes"
        case DidSearchForStartRoutes        = "Route_DidSearchForStartRoutes"
        case DidSearchForDestinationRoutes  = "Route_DidSearchForDestinationRoutes"

        func send(routeCode: String? = nil, rounteCount: Int? = 0) {
            let category = Analytics.Route.CategoryId
            var value: NSNumber?
            if let rounteCount = rounteCount {
                value = NSNumber(value: rounteCount)
            }

            switch self {
            case .DidDrawRoute, .DidSelectRoute:
                Analytics.send(category: category, action: self.rawValue, label: routeCode, value: value)
            case .DidSearchForMatchingRoutes, .DidSearchForStartRoutes, .DidSearchForDestinationRoutes:
                Analytics.send(category: category, action: self.rawValue, label: Analytics.Route.LabelSearch, value: value)
            }
        }
    }
}

// MARK: - Google Analytics

private struct GoogleAnalytics {

    fileprivate static func setup() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")

        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true // Report uncaught exceptions
        #if RELEASE
            gai?.logger.logLevel = .Error
        #else
        gai?.logger.logLevel = (Verbose.Manager.Analytics == true ? .verbose : .none)
        #endif
    }

    // MARK: - Send Actions

    fileprivate static func send(category: String, action: String, label: String?, value: NSNumber?) {
        guard
            let event = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value),
            let dictionary = event.build() as? [AnyHashable: Any] else {
                return
        }

        GAI.sharedInstance().defaultTracker.send(dictionary)
    }

    static func sendScreenView(screen: Analytics.Screen) {
        guard
            let builder = GAIDictionaryBuilder.createScreenView(),
            let tracker = GAI.sharedInstance().defaultTracker,
            let info = builder.build() as? [AnyHashable: Any] else {
                return
        }
        
        tracker.set(kGAIScreenName, value: screen.rawValue)
        tracker.send(info)
    }
}

// MARK: - Firebase

private struct Firebase {

    fileprivate static func setup() {
        // Use Firebase library to configure APIs
        FIRApp.configure()
    }

    fileprivate static func send(category: String, action: String, label: String?, value: NSNumber?) {
        var params = [kFIRParameterContentType: action as NSObject, kFIRParameterItemCategory: category as NSObject]
        if let _label = label {
            params[kFIRParameterItemName] = _label as NSObject
        }
        if let _value = value {
            params[kFIRParameterValue] = _value as NSObject
        }
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: params)
    }

    static func sendScreenView(screen: Analytics.Screen) {
        let params = [kFIRParameterItemName: screen.rawValue as NSObject, kFIRParameterItemCategory: kGAIScreenName as NSObject]
        FIRAnalytics.logEvent(withName:kFIREventSelectContent, parameters: params)
    }
}
