//
//  Diaper.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftData

enum DiaperType: String, CaseIterable, Codable, CustomStringConvertible {
    case wet
    case dirty
    case mixed
    case none
    
    ///中文描述
    var description: String {
        switch self {
        case .wet:
            return "嘘嘘"
        case .dirty:
            return "便便"
        case .mixed:
            return "嘘嘘和便便"
        case .none:
            return "干爽"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .wet:
            return "drop"
        case .dirty:
            return "poo"
        case .mixed:
            return "drop.and.poo"
        case .none:
            return "sun.max"
        }
    }
}


enum DiaperAmount: String, CaseIterable, Codable, CustomStringConvertible {
    case little
    case normal
    case much
    
    
    var description: String {
        switch self {
        case .little:
            return "少量"
        case .normal:
            return "一般"
        case .much:
            return "大量"
        }
    }
}

enum DiaperTexture: String, CaseIterable, Codable, CustomStringConvertible {
    case normal
    case watery
    case solid
    
    var description: String {
        switch self {
        case .normal:
            return "正常"
        case .watery:
            return "稀"
        case .solid:
            return "干"
        }
    }
}

enum DiaperColor: String, CaseIterable, Codable, CustomStringConvertible {
    case yellow
    case green
    case brown
    case red
    case black
    
    var description: String {
        switch self {
        case .yellow:
            return "黄色"
        case .green:
            return "绿色"
        case .brown:
            return "棕色"
        case .red:
            return "红色"
        case .black:
            return "黑色"
        }
    }
}

@Model
final class Diaper: CustomStringConvertible {
    
    weak var care: Care?
    var type: DiaperType = DiaperType.none
    var amount: DiaperAmount = DiaperAmount.normal
    var texture: DiaperTexture?
    var color: DiaperColor?
    
    init(type: DiaperType, amount: DiaperAmount, texture: DiaperTexture? = nil, color: DiaperColor? = nil, care: Care? = nil) {
        self.type = type
        self.amount = amount
        self.texture = texture
        self.color = color
        self.care = care
    }
    
    var description: String {
        if let texture = texture, let color = color {
            return "\(type.description) \(amount.description) \(texture.description) \(color.description)"
        }
        return "\(type.description) \(amount.description)"
    }
}
