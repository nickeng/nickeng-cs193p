//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Eng, Nick on 12/7/22.
//

import SwiftUI

@main
struct MemorizeApp: App {
    let game = EmojiMemoryGame()
    var body: some Scene {
        WindowGroup {
            ContentView(game: game)
        }
    }
}
