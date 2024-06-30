//
//  Item.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
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
