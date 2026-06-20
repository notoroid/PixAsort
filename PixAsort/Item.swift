//
//  Item.swift
//  PixAsort
//
//  Created by 能登 要 on 2026/06/20.
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
