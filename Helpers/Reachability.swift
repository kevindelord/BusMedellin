//
//  Reachability.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation
import Reachability

extension Reachability {

    static var isConnected : Bool {
        let reachability = Reachability.forInternetConnection()
        let networkStatus = reachability?.currentReachabilityStatus()
        return (networkStatus == .ReachableViaWiFi || networkStatus == .ReachableViaWWAN)
    }
}
