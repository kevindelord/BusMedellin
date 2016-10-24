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

        // Firebase
        // Use Firebase library to configure APIs
        FIRApp.configure()

        // Google Analytics
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")

        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // Report uncaught exceptions
        #if RELEASE
            gai.logger.logLevel = .Error
        #else
            gai.logger.logLevel = (Verbose.Manager.Analytics == true ? .Verbose : .None)
        #endif
    }

    // MARK: - Send Actions

    private static func send(category: String, action: String, label: String?, value: NSNumber?) {
        // Google Analytics
        let event = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value)
        let dictionary = event.build() as [NSObject:AnyObject]
        GAI.sharedInstance().defaultTracker.send(dictionary)

        // Firebase
        var params : [String : NSObject] = [kFIRParameterContentType: action, kFIRParameterItemCategory: category]
        if let _label = label {
            params[kFIRParameterItemName] = _label
        }
        if let _value = value {
            params[kFIRParameterValue] = _value
        }
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: params)
    }

    static func sendScreenView(screen: Analytics.Screen) {
        // Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screen.rawValue)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])

        // Firebase
        let params = [kFIRParameterItemName: screen.rawValue, kFIRParameterItemCategory: kGAIScreenName]
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: params)
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
            Analytics.send(category, action: self.rawValue, label: nil, value: nil)
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
            Analytics.send(category, action: self.rawValue, label: nil, value: nil)
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

        func send(routeCode routeCode: String? = nil, rounteCount: Int? = 0) {
            let category = Analytics.Route.CategoryId
            switch self {
            case .DidDrawRoute, .DidSelectRoute:
                Analytics.send(category, action: self.rawValue, label: routeCode, value: rounteCount)
            case .DidSearchForMatchingRoutes, .DidSearchForStartRoutes, .DidSearchForDestinationRoutes:
                Analytics.send(category, action: self.rawValue, label: Analytics.Route.LabelSearch, value: rounteCount)
            }
        }
    }
}
