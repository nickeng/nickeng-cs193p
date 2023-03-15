//
//  Theme.swift
//  Memorize
//
//  Created by Eng, Nick on 1/1/23.
//

import Foundation

struct Theme: Identifiable, Codable, Hashable {
    let id: Int
    var name: String
    var emojis: Array<String>
    var cards: Int
    var fill: Fill
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && emojis.count >= Theme.MinCards
    }
    
    enum Fill: Codable, Equatable, Hashable {
        case solid(_ color: RGBAColor)
        case gradient(top: RGBAColor, bottom: RGBAColor)
    }
    
    static var MinCards = 2
}

struct RGBAColor: Codable, Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}
