//
//  Item.swift
//  DraggableTest
//
//  Created by David Caddy on 24/3/2024.
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
