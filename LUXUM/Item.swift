//
//  Item.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
