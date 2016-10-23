//
//  DMDefines.swift
//  BusMedellin
//
//  Created by Kevin Delord on 13/10/16.
//  Copyright © 2016 Kevin Delord. All rights reserved.
//

import Foundation

#if DEBUG
    private let isDebug = true
#else
    private let isDebug = false
#endif

struct Configuration {

    static let DebugAppirater       : Bool = (false && isDebug)
}

struct Verbose {

    static let PinAddress           : Bool = false

    struct Manager {

        static let API              : Bool = false
    }
}
