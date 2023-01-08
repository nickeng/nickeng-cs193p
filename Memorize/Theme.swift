//
//  Theme.swift
//  Memorize
//
//  Created by Eng, Nick on 1/1/23.
//

import Foundation

struct Theme {
    var name: String
    var emojis: Array<String>
    var color: Fill
    
    
    enum Color {
        case purple, blue, green, yellow, orange, red
    }
    
    enum Fill {
        case solid(_ color: Color)
        case gradient(top: Color, bottom: Color)
    }
}
