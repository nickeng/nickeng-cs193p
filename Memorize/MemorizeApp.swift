//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Eng, Nick on 12/7/22.
//

import SwiftUI

@main
struct MemorizeApp: App {
    private let game = EmojiMemoryGame()
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game)
        }
    }
}
