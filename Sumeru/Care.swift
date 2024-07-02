//
//  Care.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import Foundation
import SwiftData

enum CareType: String, CaseIterable, Codable, CustomStringConvertible, Identifiable {
    
    var id: String { rawValue }
    
    case feeding
    case diaper
    case sleep
    case bath
    case other
    
    var symbol: String {
        switch self {
        case .feeding:
            return "🍼"
        case .diaper:
            return "🚼"
        case .sleep:
            return "😴"
        case .bath:
            return "🛁"
        case .other:
            return "🧸"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .feeding:
            return "drop"
        case .diaper:
            return "square.and.pencil"
        case .sleep:
            return "zzz"
        case .bath:
            return "drop.triangle"
        case .other:
            return "square.and.pencil"
        }
    }
    
    ///localized description
    var description: String {
        switch self {
        case .feeding:
            return NSLocalizedString("Feeding", comment: "")
        case .diaper:
            return NSLocalizedString("Diaper", comment: "")
        case .sleep:
            return NSLocalizedString("Sleep", comment: "")
        case .bath:
            return NSLocalizedString("Bath", comment: "")
        case .other:
            return NSLocalizedString("Other", comment: "")
        }
    }
    
}


enum FeedType: String, CaseIterable, Codable, CustomStringConvertible {
    case breast
    case formula
    case breastAndFormula
    case solid
    
    ///localized description
    var description: String {
        switch self {
        case .breast:
            return NSLocalizedString("Breast", comment: "")
        case .formula:
            return NSLocalizedString("Formula", comment: "")
        case .breastAndFormula:
            return NSLocalizedString("Breast and Formula", comment: "")
        case .solid:
            return NSLocalizedString("Solid", comment: "")
        }
    }

}

enum FeedMethod: String, CaseIterable, Codable, CustomStringConvertible {
    case bottle
    case breast
    
    ///localized description
    var description: String {
        switch self {
        case .bottle:
            return NSLocalizedString("Bottle", comment: "")
        case .breast:
            return NSLocalizedString("Breast", comment: "")
        }
    }
    
    
    
}


@Model
final class Care: CustomStringConvertible {
    
    var timestamp: Date = Date()
    var type: CareType = CareType.feeding
    var feed: Feed?
    var diaper: Diaper?
    var duration: TimeInterval = 0
    var note: String?
    
    init(timestamp: Date, type: CareType, feed: Feed? = nil, diaper: Diaper? = nil, duration: TimeInterval = 0, note: String? = nil) {
        self.timestamp = timestamp
        self.type = type
        self.feed = feed
        self.diaper = diaper
        self.duration = duration
        self.note = note
    }
    
    ///localized description
    var description: String {
        switch type {
        case .feeding:
            return NSLocalizedString("Feeding", comment: "")
        case .diaper:
            return NSLocalizedString("Diaper", comment: "")
        case .sleep:
            return NSLocalizedString("Sleep", comment: "")
        case .bath:
            return NSLocalizedString("Bath", comment: "")
        case .other:
            return NSLocalizedString("Other", comment: "")
        }
    }
    
    
    ///detailed localized description
    var detailDescription: String {
        switch type {
        case .feeding:
            return feed?.description ?? NSLocalizedString("Unknown", comment: "")
        case .diaper:
            return diaper?.description ?? NSLocalizedString("Unknown", comment: "")
        case .sleep:
            return NSLocalizedString("Duration", comment: "") + "\(Int(duration/60))" + NSLocalizedString("Minutes", comment: "")
        case .bath:
            return NSLocalizedString("Duration", comment: "") + "\(Int(duration/60))" + NSLocalizedString("Minutes", comment: "")
        case .other:
            return note ?? NSLocalizedString("Unknown", comment: "")
        }
    }
}
