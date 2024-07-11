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
            return "drop.fill"
        case .diaper:
            return "toilet.fill"
        case .sleep:
            return "zzz"
        case .bath:
            return "bathtub.fill"
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
    
    static var mockData: [Care] = {
        var result = [Care]()
        for day in 0..<10 {
            let date = Date().addingTimeInterval(TimeInterval(-day * 3600 * 24))
            let startOfDay = Calendar.current.startOfDay(for: date)
            for _ in 0..<15 {
                ///random time in the day
                let date = startOfDay.addingTimeInterval(TimeInterval(Int.random(in: 0...86400)))
                let type = CareType.allCases.randomElement()!
                let feed = Feed(type: FeedType.allCases.randomElement()!, method: FeedMethod.allCases.randomElement()!, breastAmount: Int.random(in: 120...200), formulaAmount: Int.random(in: 120...200))
                let diaper = Diaper(type: DiaperType.allCases.randomElement()!, amount: DiaperAmount.allCases.randomElement()!)
                let care = Care(timestamp: date, type: type, feed: type == .feeding ? feed : nil, diaper: type == .diaper ? diaper : nil, duration: TimeInterval(Int.random(in: 60...1800)), note: type == .other ? "Some Note" : nil)
                result.append(care)
            }
        }
        return result
    }()
}
