//
//  Item.swift
//  Stickies
//
//  Created by 鈴木俊孝 on 2026/05/13.
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
