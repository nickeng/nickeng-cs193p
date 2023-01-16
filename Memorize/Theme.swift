//
//  Theme.swift
//  Memorize
//
//  Created by Eng, Nick on 1/1/23.
//

import Foundation

struct Theme {
    let name: String
    let emojis: Array<String>
    let color: Fill
    
    
    enum Color {
        case purple, blue, green, yellow, orange, red
    }
    
    enum Fill {
        case solid(_ color: Color)
        case gradient(top: Color, bottom: Color)
    }
}
