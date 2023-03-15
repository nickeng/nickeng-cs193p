//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Eng, Nick on 1/1/23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    private static func createMemoryGame(theme: Theme) -> MemoryGame<String> {
        let emojis = theme.emojis.shuffled()
        return MemoryGame<String>(numberOfPairs: min(emojis.count, theme.cards)) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    init(theme: Theme) {
        self.theme = theme
        game = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
    
    @Published private var game: MemoryGame<String>
    @Published var theme: Theme {
        didSet {
            game = EmojiMemoryGame.createMemoryGame(theme: theme)
        }
    }
    
    var cards: Array<Card> {
        return game.cards
    }
    
    var title: String {
        return theme.name
    }
    
    var gradientBackground: Gradient {
        return theme.gradient
    }
    
    var score: Int {
        return game.score
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) {
        game.choose(card)
    }
    
    func shuffle() {
        game.shuffle()
    }
    
    func reset() {
        game = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
}
