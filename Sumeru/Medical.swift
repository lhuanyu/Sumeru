//
//  Medical.swift
//  Sumeru
//
//  Created by LuoHuanyu on 2024/6/30.
//

import SwiftUI

///医疗类型
enum MedicalType: String, CaseIterable, Codable {
    case vaccine
    case medicine
    case examination
    case other
}
