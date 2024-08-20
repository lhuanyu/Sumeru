//
//  Feed.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftData
import Foundation

@Model
class Feed: CustomStringConvertible {
    
    weak var care: Care?
    ///喂养类型
    var type: FeedType = FeedType.breast
    ///喂养方式
    var method: FeedMethod = FeedMethod.breast
    ///母乳量
    var breastAmount: Int = Int.zero
    ///配方奶量
    var formulaAmount: Int = Int.zero
    ///总量
    var amount: Int {
        switch method {
        case .breast:
            return breastAmount
        case .bottle:
            return breastAmount + formulaAmount
        }
    }
    
    @Transient var totalAmountInADay: Int = 0

    
    ///备注
    var note: String?
    
    init(type: FeedType, method: FeedMethod, breastAmount: Int, formulaAmount: Int, note: String? = nil, care: Care? = nil) {
        self.method = method
        self.type = type
        self.breastAmount = breastAmount
        self.formulaAmount = formulaAmount
        self.note = note
        self.care = care
    }
    
    ///localized description
    var description: String {
        switch method {
        case .bottle:
            if breastAmount > 0 {
                return NSLocalizedString("Breast and Formula", comment: "") + " \(amount)ml (" + NSLocalizedString("Breast", comment: "") + " \(breastAmount)ml " + NSLocalizedString("Formula", comment: "") + " \(formulaAmount)ml)"
            } else {
                return NSLocalizedString("Formula", comment: "") + " \(formulaAmount)ml"
            }
        case .breast:
            return NSLocalizedString("Breast", comment: "") + " \(breastAmount)ml"
        }
    }
}
