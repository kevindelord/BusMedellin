//
//  MBButtonState.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import UIKit

enum MBButtonState {
    case inactive
    case available
    
    var tintColor : UIColor {
        switch self {
        case .inactive:     return BMColor.gray
        case .available:    return BMColor.blue
        }
    }
}
