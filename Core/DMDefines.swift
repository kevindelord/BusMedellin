//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

#if DEBUG
    private let isDebug     = true
    private let isRelease   = false
#else
    private let isDebug     = false
    private let isRelease   = true
#endif

struct Configuration {

    static let DebugAppirater       : Bool = (false && isDebug)
    static let AnalyticsEnabled     : Bool = (true && isRelease)
}

struct Verbose {

    static let PinAddress           : Bool = false

    struct Manager {

        static let API              : Bool = false
        static let Analytics        : Bool = false
    }
}
